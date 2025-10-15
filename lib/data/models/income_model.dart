import 'package:hive/hive.dart';

part 'income_model.g.dart'; // Generated file for Hive

/// Income model with Hive annotations for local storage
@HiveType(typeId: 1)
class Income extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String category; // salary, business, investment, rental, other

  @HiveField(4)
  String source; // Company name, business name, etc.

  @HiveField(5)
  String description;

  @HiveField(6)
  DateTime date;

  @HiveField(7)
  bool isTaxable;

  @HiveField(8)
  String? taxYear; // 2081/82

  @HiveField(9)
  List<String>? attachments; // File paths

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime updatedAt;

  @HiveField(12)
  bool isRecurring;

  @HiveField(13)
  String? recurringFrequency; // monthly, quarterly, annually

  @HiveField(14)
  String? paymentMethod; // bank_transfer, cash, cheque

  @HiveField(15)
  String? accountNumber;

  @HiveField(16)
  bool isVerified;

  @HiveField(17)
  Map<String, dynamic>? metadata; // Additional info

  Income({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.source,
    required this.description,
    required this.date,
    this.isTaxable = true,
    this.taxYear,
    this.attachments,
    required this.createdAt,
    required this.updatedAt,
    this.isRecurring = false,
    this.recurringFrequency,
    this.paymentMethod,
    this.accountNumber,
    this.isVerified = false,
    this.metadata,
  });

  /// Create a copy with modified fields
  Income copyWith({
    String? id,
    String? userId,
    double? amount,
    String? category,
    String? source,
    String? description,
    DateTime? date,
    bool? isTaxable,
    String? taxYear,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRecurring,
    String? recurringFrequency,
    String? paymentMethod,
    String? accountNumber,
    bool? isVerified,
    Map<String, dynamic>? metadata,
  }) {
    return Income(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      source: source ?? this.source,
      description: description ?? this.description,
      date: date ?? this.date,
      isTaxable: isTaxable ?? this.isTaxable,
      taxYear: taxYear ?? this.taxYear,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      accountNumber: accountNumber ?? this.accountNumber,
      isVerified: isVerified ?? this.isVerified,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'category': category,
      'source': source,
      'description': description,
      'date': date.toIso8601String(),
      'isTaxable': isTaxable,
      'taxYear': taxYear,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isRecurring': isRecurring,
      'recurringFrequency': recurringFrequency,
      'paymentMethod': paymentMethod,
      'accountNumber': accountNumber,
      'isVerified': isVerified,
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      source: json['source'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      isTaxable: json['isTaxable'] as bool? ?? true,
      taxYear: json['taxYear'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)?.cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringFrequency: json['recurringFrequency'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      accountNumber: json['accountNumber'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Get month name
  String get monthName {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[date.month - 1];
  }

  /// Get year
  int get year => date.year;

  /// Check if income is from current month
  bool get isCurrentMonth {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Check if income is from current year
  bool get isCurrentYear {
    return date.year == DateTime.now().year;
  }

  @override
  String toString() {
    return 'Income(id: $id, amount: $amount, category: $category, date: $date)';
  }
}

/// Income category enum helper
class IncomeCategory {
  static const String salary = 'salary';
  static const String business = 'business';
  static const String investment = 'investment';
  static const String rental = 'rental';
  static const String other = 'other';

  static const List<String> all = [
    salary,
    business,
    investment,
    rental,
    other,
  ];

  static String getDisplayName(String category) {
    switch (category) {
      case salary:
        return 'Salary';
      case business:
        return 'Business Income';
      case investment:
        return 'Investment Income';
      case rental:
        return 'Rental Income';
      case other:
        return 'Other Income';
      default:
        return category;
    }
  }
}

/// Income statistics helper
class IncomeStats {
  final double totalIncome;
  final double averageIncome;
  final int count;
  final Map<String, double> byCategory;
  final Map<String, double> byMonth;

  IncomeStats({
    required this.totalIncome,
    required this.averageIncome,
    required this.count,
    required this.byCategory,
    required this.byMonth,
  });

  /// Calculate statistics from list of incomes
  factory IncomeStats.fromList(List<Income> incomes) {
    if (incomes.isEmpty) {
      return IncomeStats(
        totalIncome: 0,
        averageIncome: 0,
        count: 0,
        byCategory: {},
        byMonth: {},
      );
    }

    final total = incomes.fold<double>(0, (sum, income) => sum + income.amount);
    final avg = total / incomes.length;

    // Group by category
    final byCategory = <String, double>{};
    for (final income in incomes) {
      byCategory[income.category] = (byCategory[income.category] ?? 0) + income.amount;
    }

    // Group by month
    final byMonth = <String, double>{};
    for (final income in incomes) {
      final monthKey = '${income.year}-${income.date.month.toString().padLeft(2, '0')}';
      byMonth[monthKey] = (byMonth[monthKey] ?? 0) + income.amount;
    }

    return IncomeStats(
      totalIncome: total,
      averageIncome: avg,
      count: incomes.length,
      byCategory: byCategory,
      byMonth: byMonth,
    );
  }
}