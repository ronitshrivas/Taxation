import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:tax/presentation/screens/expenses/add_expenses_screen.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/common_widgets.dart';

class ReceiptScannerScreen extends ConsumerStatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  ConsumerState<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends ConsumerState<ReceiptScannerScreen> {
  CameraController? _cameraController;
  final ImagePicker _imagePicker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();
  
  bool _isProcessing = false;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _captureAndProcess() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final image = await _cameraController!.takePicture();
      await _processImage(image.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isProcessing = true);

    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _processImage(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _processImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Extract receipt data
      final receiptData = _extractReceiptData(recognizedText.text);

      if (mounted) {
        // Show preview dialog
        await _showReceiptPreview(imagePath, receiptData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OCR Error: ${e.toString()}')),
        );
      }
    }
  }

  Map<String, dynamic> _extractReceiptData(String text) {
    // Simple extraction logic - can be enhanced with ML
    final lines = text.split('\n');
    
    String? merchantName;
    double? amount;
    double? vatAmount;
    DateTime? date;
    String? billNumber;

    // Extract merchant name (usually first line)
    if (lines.isNotEmpty) {
      merchantName = lines[0].trim();
    }

    // Extract amount (look for NPR, Rs, or large numbers)
    final amountRegex = RegExp(r'(?:NPR|Rs\.?|रु\.?)\s*(\d+(?:,\d+)*(?:\.\d+)?)', caseSensitive: false);
    final amountMatch = amountRegex.firstMatch(text);
    if (amountMatch != null) {
      amount = double.tryParse(amountMatch.group(1)!.replaceAll(',', ''));
    }

    // If no prefix, look for largest number
    if (amount == null) {
      final numberRegex = RegExp(r'\b(\d+(?:,\d+)*(?:\.\d+)?)\b');
      final numbers = numberRegex.allMatches(text).map((m) {
        return double.tryParse(m.group(1)!.replaceAll(',', '')) ?? 0;
      }).toList()..sort((a, b) => b.compareTo(a));
      
      if (numbers.isNotEmpty) {
        amount = numbers.first;
      }
    }

    // Extract VAT (usually 13% in Nepal)
    final vatRegex = RegExp(r'VAT|Tax.*?(\d+(?:,\d+)*(?:\.\d+)?)', caseSensitive: false);
    final vatMatch = vatRegex.firstMatch(text);
    if (vatMatch != null) {
      vatAmount = double.tryParse(vatMatch.group(1)!.replaceAll(',', ''));
    }

    // Extract date (various formats)
    final dateRegex = RegExp(r'(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})|\b(\d{4}-\d{2}-\d{2})\b');
    final dateMatch = dateRegex.firstMatch(text);
    if (dateMatch != null) {
      try {
        final dateStr = dateMatch.group(0)!;
        // Try to parse different date formats
        if (dateStr.contains('-')) {
          date = DateTime.tryParse(dateStr);
        } else {
          final parts = dateStr.split('/');
          if (parts.length == 3) {
            date = DateTime(
              int.parse(parts[2].length == 2 ? '20${parts[2]}' : parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        }
      } catch (e) {
        // Date parsing failed, use current date
      }
    }

    // Extract bill/invoice number
    final billRegex = RegExp(r'(?:Bill|Invoice|Receipt).*?#?\s*(\w+[-\d]+)', caseSensitive: false);
    final billMatch = billRegex.firstMatch(text);
    if (billMatch != null) {
      billNumber = billMatch.group(1);
    }

    return {
      'merchantName': merchantName,
      'amount': amount,
      'vatAmount': vatAmount,
      'date': date ?? DateTime.now(),
      'billNumber': billNumber,
      'fullText': text,
    };
  }

  Future<void> _showReceiptPreview(String imagePath, Map<String, dynamic> data) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Receipt Scanned'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Receipt image preview
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(imagePath),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Extracted Information:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildDataRow('Merchant', data['merchantName'] ?? 'Not found'),
              _buildDataRow('Amount', data['amount'] != null 
                  ? 'NPR ${data['amount']!.toStringAsFixed(2)}' 
                  : 'Not found'),
              if (data['vatAmount'] != null)
                _buildDataRow('VAT', 'NPR ${data['vatAmount']!.toStringAsFixed(2)}'),
              _buildDataRow('Date', '${data['date'].day}/${data['date'].month}/${data['date'].year}'),
              if (data['billNumber'] != null)
                _buildDataRow('Bill #', data['billNumber']),
              const SizedBox(height: 8),
              const Text(
                'You can edit this information in the expense form.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to previous screen
              // Navigate to add expense with pre-filled data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddExpenseScreen(
                    // TODO: Pass scanned data to pre-fill form
                  ),
                ),
              );
            },
            child: const Text('Add Expense'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.receiptScanner),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _pickFromGallery,
            tooltip: 'Pick from gallery',
          ),
        ],
      ),
      body: _isProcessing
          ? const LoadingIndicator(message: 'Processing receipt...')
          : _cameraController == null || !_cameraController!.value.isInitialized
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 80, color: AppColors.textSecondary),
                      SizedBox(height: 16),
                      Text('Initializing camera...'),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    // Camera Preview
                    SizedBox.expand(
                      child: CameraPreview(_cameraController!),
                    ),

                    // Overlay guidelines
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.5,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    // Instructions
                    Positioned(
                      top: 40,
                      left: 0,
                      right: 0,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Position receipt within the frame\nEnsure good lighting and focus',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    // Capture button
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: _captureAndProcess,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Tips button
                    Positioned(
                      bottom: 40,
                      right: 40,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.white,
                        onPressed: () {
                          _showTipsDialog();
                        },
                        child: const Icon(Icons.help_outline, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
    );
  }

  void _showTipsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lightbulb, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Scanning Tips'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✓ Use good lighting'),
            SizedBox(height: 8),
            Text('✓ Keep receipt flat and straight'),
            SizedBox(height: 8),
            Text('✓ Fill the frame with the receipt'),
            SizedBox(height: 8),
            Text('✓ Avoid shadows and glare'),
            SizedBox(height: 8),
            Text('✓ Ensure text is in focus'),
            SizedBox(height: 8),
            Text('✓ You can edit extracted data later'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}