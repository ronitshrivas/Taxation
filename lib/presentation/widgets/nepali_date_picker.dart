import 'package:flutter/material.dart';
import 'package:nepali_utils/nepali_utils.dart';
import '../../core/constants/app_colors.dart';

/// Nepali Date Picker Widget with BS/AD support
class NepaliDatePickerWidget extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime) onDateSelected;
  final bool useNepaliCalendar;

  const NepaliDatePickerWidget({
    super.key,
    this.initialDate,
    required this.onDateSelected,
    this.useNepaliCalendar = false,
  });

  @override
  State<NepaliDatePickerWidget> createState() => _NepaliDatePickerWidgetState();

  /// Show date picker dialog
  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? initialDate,
    bool useNepaliCalendar = false,
  }) async {
    DateTime? selectedDate;

    if (useNepaliCalendar) {
      final nepaliDate = NepaliDateTime.fromDateTime(initialDate ?? DateTime.now());
      
      final result = await showDialog<NepaliDateTime>(
        context: context,
        builder: (context) => NepaliDatePickerDialog(initialDate: nepaliDate),
      );

      if (result != null) {
        selectedDate = result.toDateTime();
      }
    } else {
      selectedDate = await showDatePicker(
        context: context,
        initialDate: initialDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
    }

    return selectedDate;
  }
}

class _NepaliDatePickerWidgetState extends State<NepaliDatePickerWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.useNepaliCalendar ? 'Select Nepali Date (BS)' : 'Select Date (AD)',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Calendar widget would go here
          // For now using simple date display
        ],
      ),
    );
  }
}

/// Nepali Date Picker Dialog
class NepaliDatePickerDialog extends StatefulWidget {
  final NepaliDateTime initialDate;

  const NepaliDatePickerDialog({
    super.key,
    required this.initialDate,
  });

  @override
  State<NepaliDatePickerDialog> createState() => _NepaliDatePickerDialogState();
}

class _NepaliDatePickerDialogState extends State<NepaliDatePickerDialog> {
  late NepaliDateTime _selectedDate;
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedYear = _selectedDate.year;
    _selectedMonth = _selectedDate.month;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with year and month selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      if (_selectedMonth > 1) {
                        _selectedMonth--;
                      } else {
                        _selectedMonth = 12;
                        _selectedYear--;
                      }
                    });
                  },
                ),
                Column(
                  children: [
                    Text(
                      NepaliDateFormat.MMMM().format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _selectedYear.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      if (_selectedMonth < 12) {
                        _selectedMonth++;
                      } else {
                        _selectedMonth = 1;
                        _selectedYear++;
                      }
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Calendar grid would go here
            // For simplicity, showing month selector
            _buildMonthGrid(),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _selectedDate);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthGrid() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['आइत', 'सोम', 'मंगल', 'बुध', 'बिही', 'शुक्र', 'शनि']
                .map((day) => SizedBox(
                      width: 40,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          
          // Simple date selector (simplified version)
          Text(
            'Selected: ${NepaliDateFormat.yMd().format(_selectedDate)}',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

/// Nepali Date Formatter Helper
class NepaliDateFormatter {
  /// Format DateTime to Nepali format
  static String formatNepali(DateTime date) {
    final nepaliDate = NepaliDateTime.fromDateTime(date);
    return NepaliDateFormat.yMd().format(nepaliDate);
  }

  /// Format DateTime to long Nepali format
  static String formatNepaliLong(DateTime date) {
    final nepaliDate = NepaliDateTime.fromDateTime(date);
    return NepaliDateFormat.yMMMMd().format(nepaliDate);
  }

  /// Get fiscal year in BS format
  static String getFiscalYearBS(DateTime date) {
    final nepaliDate = NepaliDateTime.fromDateTime(date);
    // Fiscal year in Nepal starts from Shrawan
    if (nepaliDate.month >= 4) {
      // After Shrawan
      return '${nepaliDate.year}/${(nepaliDate.year + 1).toString().substring(2)}';
    } else {
      return '${nepaliDate.year - 1}/${nepaliDate.year.toString().substring(2)}';
    }
  }

  /// Convert BS date string to AD
  static DateTime? parseBStoAD(String bsDate) {
    try {
      final nepaliDate = NepaliDateTime.parse(bsDate);
      return nepaliDate.toDateTime();
    } catch (e) {
      return null;
    }
  }

  /// Get Nepali month names
  static List<String> get nepaliMonths => [
        'बैशाख',
        'जेठ',
        'असार',
        'साउन',
        'भदौ',
        'असोज',
        'कार्तिक',
        'मंसिर',
        'पुष',
        'माघ',
        'फागुन',
        'चैत',
      ];

  /// Get tax deadline dates
  static Map<String, String> getTaxDeadlines() {
    return {
      'Annual Income Tax': 'Magh End (Mid-February)',
      'Q1 VAT': 'Kartik 25',
      'Q2 VAT': 'Magh 25',
      'Q3 VAT': 'Ashadh 25',
      'Monthly TDS': '25th of following month',
    };
  }

  /// Check if date is near tax deadline
  static bool isNearDeadline(DateTime date, {int daysThreshold = 7}) {
    final nepaliDate = NepaliDateTime.fromDateTime(date);
    
    // Check for Magh end (annual tax deadline)
    if (nepaliDate.month == 10) {
      // Magh month
      final daysInMonth = NepaliDateTime(nepaliDate.year, 10).totalDays;
      if (daysInMonth - nepaliDate.day <= daysThreshold) {
        return true;
      }
    }

    // Check for monthly TDS (25th of every month)
    if (nepaliDate.day >= 25 - daysThreshold && nepaliDate.day <= 25) {
      return true;
    }

    return false;
  }

  /// Get upcoming tax deadline
  static String getNextDeadline() {
    final now = NepaliDateTime.now();
    
    // Annual tax deadline (Magh end)
    if (now.month <= 10) {
      return 'Annual Income Tax: Magh End (${2081 + (now.month > 3 ? 1 : 0)})';
    }

    // Next monthly TDS
    final nextMonth = now.month < 12 ? now.month + 1 : 1;
    final nextYear = nextMonth == 1 ? now.year + 1 : now.year;
    return 'Monthly TDS: $nextMonth/$nextYear 25';
  }
}

/// Fiscal Year Helper
class FiscalYearHelper {
  /// Get current fiscal year
  static String getCurrentFiscalYear() {
    final now = DateTime.now();
    return NepaliDateFormatter.getFiscalYearBS(now);
  }

  /// Get fiscal year start date
  static DateTime getFiscalYearStart(String fiscalYear) {
    final year = int.parse(fiscalYear.split('/')[0]);
    // Shrawan 1 in BS
    final nepaliDate = NepaliDateTime(year, 4, 1);
    return nepaliDate.toDateTime();
  }

  /// Get fiscal year end date
  static DateTime getFiscalYearEnd(String fiscalYear) {
    final year = int.parse(fiscalYear.split('/')[0]);
    // Ashadh end in BS
    final nepaliDate = NepaliDateTime(year + 1, 3, 32); // Last day of Ashadh
    return nepaliDate.toDateTime();
  }

  /// Get list of recent fiscal years
  static List<String> getRecentFiscalYears({int count = 5}) {
    final current = getCurrentFiscalYear();
    final currentYear = int.parse(current.split('/')[0]);
    
    return List.generate(count, (index) {
      final year = currentYear - index;
      return '$year/${(year + 1).toString().substring(2)}';
    });
  }
}