import 'package:hive/hive.dart';
import 'package:tax/data/models/expense_model.dart';

class ExpenseRepository {
  final Box<Expense> _box;

  ExpenseRepository(this._box);

  Stream<List<Expense>> watchExpenses(String userId) {
    return _box.watch().map((_) => getExpenses(userId));
  }

  List<Expense> getExpenses(String userId) {
    return _box.values.where((expense) => expense.userId == userId).toList();
  }

  List<Expense> getRecentExpenses(String userId, {int limit = 5}) {
    return getExpenses(userId)
        ..sort((a, b) => b.date.compareTo(a.date))
        ..take(limit)
        ..toList();
  }

  double getTotalTaxDeductible(String userId) {
    return getExpenses(userId)
        .where((e) => e.isTaxDeductible)
        .fold<double>(0, (sum, e) => sum + e.amount);
  }

  Future<void> addExpense({
    required String userId,
    required double amount,
    required String description,
    required String category,
    required DateTime date,
    bool isTaxDeductible = true,
    String? merchantName,
    double? vatAmount,
    String? billNumber,
    String? notes,
    bool isRecurring = false,
    String? recurringFrequency,
    String? receiptPath,
  }) async {
    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      amount: amount,
      description: description,
      category: category,
      date: date,
      isTaxDeductible: isTaxDeductible,
      merchantName: merchantName,
      vatAmount: vatAmount,
      billNumber: billNumber,
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isRecurring: isRecurring,
      recurringFrequency: recurringFrequency,
      receiptPath: receiptPath,
    );
    await _box.add(expense);
  }

  Future<void> updateExpense(Expense expense) async {
    await expense.save();
  }

  Future<void> deleteExpense(String id) async {
    final expense = _box.values.firstWhere((e) => e.id == id);
    await expense.delete();
  }
}