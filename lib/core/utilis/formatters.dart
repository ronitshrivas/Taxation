import 'package:intl/intl.dart';

/// Utility class for formatting numbers, currency, dates, etc.
class Formatters {
  Formatters._();

  // Currency Formatters
  static final NumberFormat _nprFormat = NumberFormat.currency(
    locale: 'en_NP',
    symbol: 'NPR ',
    decimalDigits: 2,
  );

  static final NumberFormat _nprCompactFormat = NumberFormat.compact(
    locale: 'en_NP',
  );

  /// Format amount to NPR currency with symbol
  /// Example: 50000 -> "NPR 50,000.00"
  static String formatNPR(double amount) {
    return _nprFormat.format(amount);
  }

  /// Format amount to NPR currency without decimals
  /// Example: 50000 -> "NPR 50,000"
  static String formatNPRWithoutDecimals(double amount) {
    return 'NPR ${NumberFormat('#,##,###', 'en_NP').format(amount)}';
  }

  /// Format amount to compact NPR format
  /// Example: 5000000 -> "NPR 50L" or "NPR 5M"
  static String formatNPRCompact(double amount) {
    if (amount >= 10000000) {
      // Crores
      return 'NPR ${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      // Lakhs
      return 'NPR ${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      // Thousands
      return 'NPR ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return formatNPRWithoutDecimals(amount);
  }

  /// Format number with commas (Indian number system)
  /// Example: 50000 -> "50,000"
  static String formatNumber(double number) {
    return NumberFormat('#,##,###', 'en_NP').format(number);
  }

  /// Format percentage
  /// Example: 0.1356 -> "13.56%"
  static String formatPercentage(double value, {int decimals = 2}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  /// Format decimal to fixed places
  /// Example: 123.456789 -> "123.46"
  static String formatDecimal(double value, {int decimals = 2}) {
    return value.toStringAsFixed(decimals);
  }

  // Date Formatters
  
  /// Format date to "Jan 15, 2025"
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format date to "15 January 2025"
  static String formatDateLong(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  /// Format date to "15/01/2025"
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format date to "2025-01-15" (ISO format)
  static String formatDateISO(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format time to "02:30 PM"
  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  /// Format date and time to "Jan 15, 2025 02:30 PM"
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
  }

  /// Format date relative to now
  /// Example: "Today", "Yesterday", "2 days ago", "Jan 15"
  static String formatDateRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference < 365) {
      final months = (difference / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      return formatDate(date);
    }
  }

  /// Format month and year
  /// Example: "January 2025"
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  /// Get fiscal year string from date
  /// Example: DateTime(2025, 8, 15) -> "2082/83" (BS)
  static String getFiscalYear(DateTime date) {
    // Fiscal year in Nepal starts from Shrawan (mid-July)
    // If date is before mid-July, it belongs to previous fiscal year
    if (date.month < 7 || (date.month == 7 && date.day < 16)) {
      return '${date.year - 1}/${date.year.toString().substring(2)}';
    }
    return '${date.year}/${(date.year + 1).toString().substring(2)}';
  }

  // PAN Number Formatter
  
  /// Format PAN number with spaces
  /// Example: "123456789" -> "123 456 789"
  static String formatPAN(String pan) {
    if (pan.length != 9) return pan;
    return '${pan.substring(0, 3)} ${pan.substring(3, 6)} ${pan.substring(6)}';
  }

  /// Remove PAN formatting
  /// Example: "123 456 789" -> "123456789"
  static String unformatPAN(String formattedPAN) {
    return formattedPAN.replaceAll(' ', '');
  }

  // Phone Number Formatter
  
  /// Format phone number
  /// Example: "9841234567" -> "+977-9841234567"
  static String formatPhoneNumber(String phone) {
    if (phone.startsWith('+977')) return phone;
    return '+977-$phone';
  }

  // File Size Formatter
  
  /// Format file size in bytes to human readable
  /// Example: 1024 -> "1 KB", 1048576 -> "1 MB"
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  // Duration Formatter
  
  /// Format duration to human readable
  /// Example: Duration(hours: 2, minutes: 30) -> "2h 30m"
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  // Tax Rate Formatter
  
  /// Format tax rate for display
  /// Example: 0.36 -> "36%", 0.1 -> "10%"
  static String formatTaxRate(double rate) {
    return '${(rate * 100).toStringAsFixed(0)}%';
  }

  // Input Masks
  
  /// Create currency input mask for TextField
  static String maskCurrencyInput(String input) {
    // Remove non-digit characters
    final cleaned = input.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.isEmpty) return '';
    
    // Convert to number and format
    final number = double.tryParse(cleaned) ?? 0;
    return formatNumber(number);
  }

  /// Parse formatted currency back to double
  static double parseCurrency(String formatted) {
    final cleaned = formatted.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  // Text Truncation
  
  /// Truncate text with ellipsis
  /// Example: truncate("Hello World", 8) -> "Hello..."
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Truncate text to words
  /// Example: truncateWords("Hello world from Nepal", 3) -> "Hello world from..."
  static String truncateWords(String text, int maxWords) {
    final words = text.split(' ');
    if (words.length <= maxWords) return text;
    return '${words.take(maxWords).join(' ')}...';
  }

  // Capitalize
  
  /// Capitalize first letter
  /// Example: "hello" -> "Hello"
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Capitalize each word
  /// Example: "hello world" -> "Hello World"
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  // Ordinal Numbers
  
  /// Convert number to ordinal
  /// Example: 1 -> "1st", 2 -> "2nd", 3 -> "3rd", 4 -> "4th"
  static String ordinal(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  // Pluralization
  
  /// Simple pluralization
  /// Example: pluralize("item", 5) -> "5 items"
  static String pluralize(String word, int count) {
    if (count == 1) return '$count $word';
    return '$count ${word}s';
  }

  // Color to Hex
  
  /// Convert integer color to hex string
  /// Example: 0xFF1565C0 -> "#1565C0"
  static String colorToHex(int color) {
    return '#${color.toRadixString(16).substring(2).toUpperCase()}';
  }
}