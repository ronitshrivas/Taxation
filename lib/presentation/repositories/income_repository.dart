import 'package:hive/hive.dart';
import 'package:tax/data/models/income_model.dart';

class IncomeRepository {
  final Box<Income> _box;

  IncomeRepository(this._box);

  Stream<List<Income>> watchIncomes(String userId) {
    return _box.watch().map((_) => getIncomes(userId));
  }

  List<Income> getIncomes(String userId) {
    return _box.values.where((income) => income.userId == userId).toList();
  }

  List<Income> getRecentIncomes(String userId, {int limit = 5}) {
    return getIncomes(userId)
        ..sort((a, b) => b.date.compareTo(a.date))
        ..take(limit)
        ..toList();
  }

  Future<void> addIncome({
    required String userId,
    required double amount,
    required String source,
    required String description,
    required String category,
    required DateTime date,
    bool isTaxable = true,
    bool isRecurring = false,
    String? recurringFrequency,
  }) async {
    final income = Income(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      amount: amount,
      source: source,
      description: description,
      category: category,
      date: date,
      isTaxable: isTaxable,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isRecurring: isRecurring,
      recurringFrequency: recurringFrequency,
    );
    await _box.add(income);
  }

  Future<void> updateIncome(Income income) async {
    await income.save();
  }

  Future<void> deleteIncome(String id) async {
    final income = _box.values.firstWhere((i) => i.id == id);
    await income.delete();
  }
}