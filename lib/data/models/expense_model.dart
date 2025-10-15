import 'package:hive/hive.dart';

part 'expense_model.g.dart'; // Generated file for Hive

/// Expense model with Hive annotations for local storage
@HiveType(typeId: 2)
class Expense extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String category; // office_rent, salaries, utilities, travel, etc.

  @HiveField(4)
  String description;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  bool isTaxDeductible;

  @HiveField(7)
  String? receiptPath; // Local file path

  @HiveField(8)
  String? receiptUrl; // Cloud URL

  @HiveField(9)
  String? merchantName;

  @HiveField(10)
  String? taxYear; // 2081/82

  @HiveField(11)
  DateTime createdAt;

  @HiveField(12)
  DateTime updatedAt;

  @HiveField(13)
  bool isRecurring;

  @HiveField(14)
  String? recurringFrequency; // monthly, quarterly, annually

  @HiveField(15)
  String? paymentMethod; // cash, card, bank_transfer, cheque

  @HiveField(16)
  double? vatAmount;

  @HiveField(17)
  String? panNumber; // Vendor PAN

  @HiveField(18)
  String? billNumber;

  @HiveField(19)
  String? notes;

  @HiveField(20)
  List<String>? tags;

  @HiveField(21)
  bool isVerified;

  @HiveField(22)
  bool isReimbursable;

  @HiveField(23)
  bool isReimbursed;

  @HiveField(24)
  Map<String, dynamic>? metadata;

  Expense({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.isTaxDeductible = true,
    this.receiptPath,
    this.receiptUrl,
    this.merchantName,
    this.taxYear,
    required this.createdAt,
    required this.updatedAt,
    this.isRecurring = false,
    this.recurringFrequency,
    this.paymentMethod,
    this.vatAmount,
    this.panNumber,
    this.billNumber,
    this.notes,
    this.tags,
    this.isVerified = false,
    this.isReimbursable = false,
    this.isReimbursed = false,
    this.metadata,
  });

  /// Create a copy with modified fields
  Expense copyWith({
    String? id,
    String? userId,
    double? amount,
    String? category,
    String? description,
    DateTime? date,
    bool? isTaxDeductible,
    String? receiptPath,
    String? receiptUrl,
    String? merchantName,
    String? taxYear,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRecurring,
    String? recurringFrequency,
    String? paymentMethod,
    double? vatAmount,
    String? panNumber,
    String? billNumber,
    String? notes,
    List<String>? tags,
    bool? isVerified,
    bool? isReimbursable,
    bool? isReimbursed,
    Map<String, dynamic>? metadata,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      isTaxDeductible: isTaxDeductible ?? this.isTaxDeductible,
      receiptPath: receiptPath ?? this.receiptPath,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      merchantName: merchantName ?? this.merchantName,
      taxYear: taxYear ?? this.taxYear,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      vatAmount: vatAmount ?? this.vatAmount,
      panNumber: panNumber ?? this.panNumber,
      billNumber: billNumber ?? this.billNumber,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      isVerified: isVerified ?? this.isVerified,
      isReimbursable: isReimbursable ?? this.isReimbursable,
      isReimbursed: isReimbursed ?? this.isReimbursed,
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
      'description': description,
      'date': date.toIso8601String(),
      'isTaxDeductible': isTaxDeductible,
      'receiptPath': receiptPath,
      'receiptUrl': receiptUrl,
      'merchantName': merchantName,
      'taxYear': taxYear,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isRecurring': isRecurring,
      'recurringFrequency': recurringFrequency,
      'paymentMethod': paymentMethod,
      'vatAmount': vatAmount,
      'panNumber': panNumber,
      'billNumber': billNumber,
      'notes': notes,
      'tags': tags,
      'isVerified': isVerified,
      'isReimbursable': isReimbursable,
      'isReimbursed': isReimbursed,
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      isTaxDeductible: json['isTaxDeductible'] as bool? ?? true,
      receiptPath: json['receiptPath'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      merchantName: json['merchantName'] as String?,
      taxYear: json['taxYear'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringFrequency: json['recurringFrequency'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      vatAmount: (json['vatAmount'] as num?)?.toDouble(),
      panNumber: json['panNumber'] as String?,
      billNumber: json['billNumber'] as String?,
      notes: json['notes'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      isVerified: json['isVerified'] as bool? ?? false,
      isReimbursable: json['isReimbursable'] as bool? ?? false,
      isReimbursed: json['isReimbursed'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Check if expense has receipt
  bool get hasReceipt => receiptPath != null || receiptUrl != null;

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

  /// Check if expense is from current month
  bool get isCurrentMonth {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Check if expense is from current year
  bool get isCurrentYear {
    return date.year == DateTime.now().year;
  }

  /// Get amount without VAT
  double get amountWithoutVAT {
    if (vatAmount == null || vatAmount == 0) return amount;
    return amount - vatAmount!;
  }

  @override
  String toString() {
    return 'Expense(id: $id, amount: $amount, category: $category, date: $date)';
  }
}

/// Expense category helper
class ExpenseCategoryHelper {
  static const String officeRent = 'office_rent';
  static const String salaries = 'salaries';
  static const String utilities = 'utilities';
  static const String travel = 'travel';
  static const String professionalFees = 'professional_fees';
  static const String insurance = 'insurance';
  static const String marketing = 'marketing';
  static const String training = 'training';
  static const String repairs = 'repairs';
  static const String communication = 'communication';
  static const String interest = 'interest';
  static const String depreciation = 'depreciation';
  static const String officeSupplies = 'office_supplies';
  static const String entertainment = 'entertainment';
  static const String personal = 'personal';
  static const String other = 'other';

  static const List<String> all = [
    officeRent,
    salaries,
    utilities,
    travel,
    professionalFees,
    insurance,
    marketing,
    training,
    repairs,
    communication,
    interest,
    depreciation,
    officeSupplies,
    entertainment,
    personal,
    other,
  ];

  static String getDisplayName(String category) {
    switch (category) {
      case officeRent:
        return 'Office Rent';
      case salaries:
        return 'Employee Salaries';
      case utilities:
        return 'Utilities';
      case travel:
        return 'Travel & Transport';
      case professionalFees:
        return 'Professional Fees';
      case insurance:
        return 'Insurance';
      case marketing:
        return 'Marketing & Advertising';
      case training:
        return 'Training';
      case repairs:
        return 'Repairs & Maintenance';
      case communication:
        return 'Communication';
      case interest:
        return 'Interest Payments';
      case depreciation:
        return 'Depreciation';
      case officeSupplies:
        return 'Office Supplies';
      case entertainment:
        return 'Entertainment';
      case personal:
        return 'Personal';
      case other:
        return 'Other';
      default:
        return category;
    }
  }

  static bool isTaxDeductible(String category) {
    return category != entertainment && category != personal;
  }
}

/// Expense statistics helper
class ExpenseStats {
  final double totalExpense;
  final double averageExpense;
  final int count;
  final double taxDeductibleAmount;
  final double nonDeductibleAmount;
  final Map<String, double> byCategory;
  final Map<String, double> byMonth;
  final double totalVAT;

  ExpenseStats({
    required this.totalExpense,
    required this.averageExpense,
    required this.count,
    required this.taxDeductibleAmount,
    required this.nonDeductibleAmount,
    required this.byCategory,
    required this.byMonth,
    required this.totalVAT,
  });

  /// Calculate statistics from list of expenses
  factory ExpenseStats.fromList(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return ExpenseStats(
        totalExpense: 0,
        averageExpense: 0,
        count: 0,
        taxDeductibleAmount: 0,
        nonDeductibleAmount: 0,
        byCategory: {},
        byMonth: {},
        totalVAT: 0,
      );
    }

    final total = expenses.fold<double>(0, (sum, exp) => sum + exp.amount);
    final avg = total / expenses.length;

    final deductible = expenses
        .where((e) => e.isTaxDeductible)
        .fold<double>(0, (sum, exp) => sum + exp.amount);

    final nonDeductible = total - deductible;

    final totalVAT = expenses.fold<double>(
      0,
      (sum, exp) => sum + (exp.vatAmount ?? 0),
    );

    // Group by category
    final byCategory = <String, double>{};
    for (final expense in expenses) {
      byCategory[expense.category] = 
          (byCategory[expense.category] ?? 0) + expense.amount;
    }

    // Group by month
    final byMonth = <String, double>{};
    for (final expense in expenses) {
      final monthKey = '${expense.year}-${expense.date.month.toString().padLeft(2, '0')}';
      byMonth[monthKey] = (byMonth[monthKey] ?? 0) + expense.amount;
    }

    return ExpenseStats(
      totalExpense: total,
      averageExpense: avg,
      count: expenses.length,
      taxDeductibleAmount: deductible,
      nonDeductibleAmount: nonDeductible,
      byCategory: byCategory,
      byMonth: byMonth,
      totalVAT: totalVAT,
    );
  }

  /// Get percentage of deductible expenses
  double get deductiblePercentage {
    if (totalExpense == 0) return 0;
    return (taxDeductibleAmount / totalExpense) * 100;
  }
}