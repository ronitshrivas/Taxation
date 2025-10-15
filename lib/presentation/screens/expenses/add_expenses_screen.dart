import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tax/core/utilis/formatters.dart';
import 'package:tax/core/utilis/validators.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/expense_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common_widgets.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final Expense? expense; // For editing

  const AddExpenseScreen({super.key, this.expense});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _merchantController = TextEditingController();
  final _vatController = TextEditingController();
  final _billNumberController = TextEditingController();
  final _notesController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String _selectedCategory = ExpenseCategoryHelper.officeRent;
  DateTime _selectedDate = DateTime.now();
  bool _isTaxDeductible = true;
  bool _isRecurring = false;
  String? _recurringFrequency;
  String? _receiptPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _loadExpenseData();
    }
  }

  void _loadExpenseData() {
    final expense = widget.expense!;
    _amountController.text = expense.amount.toString();
    _descriptionController.text = expense.description;
    _merchantController.text = expense.merchantName ?? '';
    _vatController.text = expense.vatAmount?.toString() ?? '';
    _billNumberController.text = expense.billNumber ?? '';
    _notesController.text = expense.notes ?? '';
    _selectedCategory = expense.category;
    _selectedDate = expense.date;
    _isTaxDeductible = expense.isTaxDeductible;
    _isRecurring = expense.isRecurring;
    _recurringFrequency = expense.recurringFrequency;
    _receiptPath = expense.receiptPath;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _merchantController.dispose();
    _vatController.dispose();
    _billNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('User not found');

      final repository = ref.read(expenseRepositoryProvider);
      final amount = double.parse(_amountController.text.replaceAll(',', ''));
      final vatAmount = _vatController.text.isEmpty 
          ? null 
          : double.parse(_vatController.text);

      if (widget.expense != null) {
        // Update existing expense
        final updatedExpense = widget.expense!.copyWith(
          amount: amount,
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          date: _selectedDate,
          isTaxDeductible: _isTaxDeductible,
          merchantName: _merchantController.text.trim().isEmpty 
              ? null 
              : _merchantController.text.trim(),
          vatAmount: vatAmount,
          billNumber: _billNumberController.text.trim().isEmpty 
              ? null 
              : _billNumberController.text.trim(),
          notes: _notesController.text.trim().isEmpty 
              ? null 
              : _notesController.text.trim(),
          isRecurring: _isRecurring,
          recurringFrequency: _recurringFrequency,
          receiptPath: _receiptPath,
          updatedAt: DateTime.now(),
        );
        await repository.updateExpense(updatedExpense);
      } else {
        // Add new expense
        await repository.addExpense(
          userId: user.id,
          amount: amount,
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          date: _selectedDate,
          isTaxDeductible: _isTaxDeductible,
          merchantName: _merchantController.text.trim().isEmpty 
              ? null 
              : _merchantController.text.trim(),
          vatAmount: vatAmount,
          billNumber: _billNumberController.text.trim().isEmpty 
              ? null 
              : _billNumberController.text.trim(),
          notes: _notesController.text.trim().isEmpty 
              ? null 
              : _notesController.text.trim(),
          isRecurring: _isRecurring,
          recurringFrequency: _recurringFrequency,
          receiptPath: _receiptPath,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.expense != null ? 'Expense updated!' : 'Expense added!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickReceipt() async {
    try {
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Receipt'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        final image = await _imagePicker.pickImage(source: source);
        if (image != null) {
          setState(() => _receiptPath = image.path);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Receipt attached!')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense != null ? 'Edit Expense' : AppStrings.addExpense),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Amount Field
            CustomTextField(
              controller: _amountController,
              label: 'Amount (NPR) *',
              hint: '5,000',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.currency_exchange),
              validator: Validators.validateAmount,
              onChanged: (value) {
                final formatted = Formatters.maskCurrencyInput(value);
                if (formatted != value) {
                  _amountController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
            ),

            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category *',
                prefixIcon: Icon(Icons.category),
              ),
              items: ExpenseCategoryHelper.all.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(ExpenseCategoryHelper.getDisplayName(category)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                    _isTaxDeductible = ExpenseCategoryHelper.isTaxDeductible(value);
                  });
                }
              },
              validator: (value) => Validators.validateRequired(value),
            ),

            const SizedBox(height: 16),

            // Description Field
            CustomTextField(
              controller: _descriptionController,
              label: 'Description *',
              hint: 'What was this expense for?',
              prefixIcon: const Icon(Icons.description),
              maxLines: 2,
              validator: (value) => Validators.validateRequired(value, fieldName: 'Description'),
            ),

            const SizedBox(height: 16),

            // Merchant Name
            CustomTextField(
              controller: _merchantController,
              label: 'Merchant/Vendor Name',
              hint: 'Where did you spend?',
              prefixIcon: const Icon(Icons.store),
            ),

            const SizedBox(height: 16),

            // Date Picker
            CustomTextField(
              controller: TextEditingController(
                text: Formatters.formatDate(_selectedDate),
              ),
              label: 'Date *',
              prefixIcon: const Icon(Icons.calendar_today),
              readOnly: true,
              onTap: _selectDate,
            ),

            const SizedBox(height: 16),

            // VAT Amount
            CustomTextField(
              controller: _vatController,
              label: 'VAT Amount (Optional)',
              hint: '650',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.percent),
            ),

            const SizedBox(height: 16),

            // Bill Number
            CustomTextField(
              controller: _billNumberController,
              label: 'Bill/Invoice Number',
              hint: 'INV-12345',
              prefixIcon: const Icon(Icons.receipt),
            ),

            const SizedBox(height: 16),

            // Notes
            CustomTextField(
              controller: _notesController,
              label: 'Additional Notes',
              hint: 'Any additional information...',
              prefixIcon: const Icon(Icons.note),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Receipt Attachment
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.attach_file, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Receipt Attachment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_receiptPath != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Receipt attached',
                            style: TextStyle(
                              color: AppColors.success.withOpacity(0.8),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => setState(() => _receiptPath = null),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  CustomButton(
                    text: _receiptPath == null ? 'Attach Receipt' : 'Change Receipt',
                    onPressed: _pickReceipt,
                    icon: Icons.camera_alt,
                    isOutlined: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tax Deductible Switch
            SwitchListTile(
              title: const Text('Tax Deductible'),
              subtitle: const Text('Can be claimed for tax deduction'),
              value: _isTaxDeductible,
              onChanged: (value) => setState(() => _isTaxDeductible = value),
              activeColor: AppColors.primary,
            ),

            const Divider(),

            // Recurring Expense Switch
            SwitchListTile(
              title: const Text('Recurring Expense'),
              subtitle: const Text('This expense repeats regularly'),
              value: _isRecurring,
              onChanged: (value) => setState(() => _isRecurring = value),
              activeColor: AppColors.primary,
            ),

            if (_isRecurring) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _recurringFrequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: const [
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(value: 'quarterly', child: Text('Quarterly')),
                  DropdownMenuItem(value: 'annually', child: Text('Annually')),
                ],
                onChanged: (value) {
                  setState(() => _recurringFrequency = value);
                },
                validator: (value) {
                  if (_isRecurring && value == null) {
                    return 'Please select frequency';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 32),

            // Save Button
            CustomButton(
              text: widget.expense != null ? 'Update Expense' : 'Add Expense',
              onPressed: _saveExpense,
              isLoading: _isLoading,
              icon: Icons.check,
              height: 54,
            ),

            const SizedBox(height: 16),

            // Cancel Button
            CustomButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(context),
              isOutlined: true,
              height: 54,
            ),
          ],
        ),
      ),
    );
  }
}