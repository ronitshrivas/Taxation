import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tax/presentation/repositories/expense_repository.dart';
import 'package:tax/presentation/repositories/income_repository.dart';
import '../../data/datasources/local/hive_database.dart';
import '../../data/models/user_model.dart';
import '../../data/models/income_model.dart';
import '../../data/models/expense_model.dart';

// ============================================================================
// DATABASE PROVIDERS
// ============================================================================

/// Hive database provider
final hiveDatabaseProvider = Provider<HiveDatabase>((ref) => HiveDatabase());

// Repository Providers
final incomeRepositoryProvider = Provider<IncomeRepository>((ref) {
  final database = ref.watch(hiveDatabaseProvider);
  return IncomeRepository(database.incomes);
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final database = ref.watch(hiveDatabaseProvider);
  return ExpenseRepository(database.expenses);
});

// Auth Providers
final currentUserProvider = StateProvider<User?>((ref) => null);

final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

// Income Providers
final incomesProvider = StreamProvider<List<Income>>((ref) {
  final user = ref.watch(currentUserProvider);
  final repository = ref.watch(incomeRepositoryProvider);
  
  if (user == null) {
    return Stream.value([]);
  }
  
  return repository.watchIncomes(user.id);
});

final totalIncomeProvider = Provider<double>((ref) {
  final incomesAsync = ref.watch(incomesProvider);
  
  return incomesAsync.when(
    data: (incomes) => incomes.fold<double>(0, (sum, income) => sum + income.amount),
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Income statistics provider
final incomeStatsProvider = Provider<IncomeStats>((ref) {
  final incomesAsync = ref.watch(incomesProvider);
  
  return incomesAsync.when(
    data: (incomes) => IncomeStats.fromList(incomes),
    loading: () => IncomeStats.fromList([]),
    error: (_, __) => IncomeStats.fromList([]),
  );
});

/// Recent incomes provider
final recentIncomesProvider = Provider<List<Income>>((ref) {
  final user = ref.watch(currentUserProvider);
  final repository = ref.watch(incomeRepositoryProvider);
  
  if (user == null) return [];
  
  return repository.getRecentIncomes(user.id, limit: 5);
});

// ============================================================================
// EXPENSE PROVIDERS
// ============================================================================

/// All expenses for current user
final expensesProvider = StreamProvider<List<Expense>>((ref) {
  final user = ref.watch(currentUserProvider);
  final repository = ref.watch(expenseRepositoryProvider);
  
  if (user == null) {
    return Stream.value([]);
  }
  
  return repository.watchExpenses(user.id);
});

/// Total expense provider
final totalExpenseProvider = Provider<double>((ref) {
  final expensesAsync = ref.watch(expensesProvider);
  
  return expensesAsync.when(
    data: (expenses) => expenses.fold<double>(0, (sum, expense) => sum + expense.amount),
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Expense statistics provider
final expenseStatsProvider = Provider<ExpenseStats>((ref) {
  final expensesAsync = ref.watch(expensesProvider);
  
  return expensesAsync.when(
    data: (expenses) => ExpenseStats.fromList(expenses),
    loading: () => ExpenseStats.fromList([]),
    error: (_, __) => ExpenseStats.fromList([]),
  );
});

/// Recent expenses provider
final recentExpensesProvider = Provider<List<Expense>>((ref) {
  final user = ref.watch(currentUserProvider);
  final repository = ref.watch(expenseRepositoryProvider);
  
  if (user == null) return [];
  
  return repository.getRecentExpenses(user.id, limit: 5);
});

/// Tax deductible expenses provider
final taxDeductibleExpensesProvider = Provider<double>((ref) {
  final user = ref.watch(currentUserProvider);
  final repository = ref.watch(expenseRepositoryProvider);
  
  if (user == null) return 0;
  
  return repository.getTotalTaxDeductible(user.id);
});

// ============================================================================
// TAX CALCULATION PROVIDERS
// ============================================================================

/// Net income provider (Income - Expenses)
final netIncomeProvider = Provider<double>((ref) {
  final totalIncome = ref.watch(totalIncomeProvider);
  final totalExpense = ref.watch(totalExpenseProvider);
  
  return totalIncome - totalExpense;
});

/// Tax liability provider
final taxLiabilityProvider = Provider<double>((ref) {
  // Will be implemented with actual tax calculation
  // For now, returning 0
  return 0.0;
});

/// Tax savings provider
final taxSavingsProvider = Provider<double>((ref) {
  // Will be implemented with optimization calculation
  // For now, returning 0
  return 0.0;
});

// ============================================================================
// UI STATE PROVIDERS
// ============================================================================

/// Selected date range provider
final selectedDateRangeProvider = StateProvider<DateRange?>((ref) => null);

/// Selected category filter provider
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Theme mode provider
final themeModeProvider = StateProvider<bool>((ref) {
  // false = light, true = dark
  return false;
});

/// Language provider
final languageProvider = StateProvider<String>((ref) => 'en');

/// Date format provider (BS/AD)
final dateFormatProvider = StateProvider<String>((ref) => 'AD');

// ============================================================================
// LOADING STATE PROVIDERS
// ============================================================================

/// Is loading provider
final isLoadingProvider = StateProvider<bool>((ref) => false);

/// Error message provider
final errorMessageProvider = StateProvider<String?>((ref) => null);

/// Success message provider
final successMessageProvider = StateProvider<String?>((ref) => null);

// ============================================================================
// FILTERED DATA PROVIDERS
// ============================================================================

/// Filtered incomes based on search and category
final filteredIncomesProvider = Provider<List<Income>>((ref) {
  final incomesAsync = ref.watch(incomesProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  
  return incomesAsync.when(
    data: (incomes) {
      var filtered = incomes;
      
      // Apply search filter
      if (searchQuery.isNotEmpty) {
        filtered = filtered.where((income) {
          return income.source.toLowerCase().contains(searchQuery.toLowerCase()) ||
                 income.description.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();
      }
      
      // Apply category filter
      if (selectedCategory != null) {
        filtered = filtered.where((income) => income.category == selectedCategory).toList();
      }
      
      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Filtered expenses based on search and category
final filteredExpensesProvider = Provider<List<Expense>>((ref) {
  final expensesAsync = ref.watch(expensesProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  
  return expensesAsync.when(
    data: (expenses) {
      var filtered = expenses;
      
      // Apply search filter
      if (searchQuery.isNotEmpty) {
        filtered = filtered.where((expense) {
          return expense.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
                 (expense.merchantName?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
        }).toList();
      }
      
      // Apply category filter
      if (selectedCategory != null) {
        filtered = filtered.where((expense) => expense.category == selectedCategory).toList();
      }
      
      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// ============================================================================
// CHART DATA PROVIDERS
// ============================================================================

/// Income by category chart data
final incomeByCategoryProvider = Provider<Map<String, double>>((ref) {
  final stats = ref.watch(incomeStatsProvider);
  return stats.byCategory;
});

/// Expense by category chart data
final expenseByCategoryProvider = Provider<Map<String, double>>((ref) {
  final stats = ref.watch(expenseStatsProvider);
  return stats.byCategory;
});

/// Monthly trend data
final monthlyTrendProvider = Provider<Map<String, Map<String, double>>>((ref) {
  final incomeStats = ref.watch(incomeStatsProvider);
  final expenseStats = ref.watch(expenseStatsProvider);
  
  // Combine income and expense monthly data
  final months = <String>{
    ...incomeStats.byMonth.keys,
    ...expenseStats.byMonth.keys,
  }.toList()..sort();
  
  final Map<String, Map<String, double>> result = {};
  
  for (final month in months) {
    result[month] = {
      'income': incomeStats.byMonth[month] ?? 0,
      'expense': expenseStats.byMonth[month] ?? 0,
    };
  }
  
  return result;
});

// ============================================================================
// DASHBOARD PROVIDERS
// ============================================================================

/// Dashboard summary provider
final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final totalIncome = ref.watch(totalIncomeProvider);
  final totalExpense = ref.watch(totalExpenseProvider);
  final netIncome = ref.watch(netIncomeProvider);
  final taxLiability = ref.watch(taxLiabilityProvider);
  final taxSavings = ref.watch(taxSavingsProvider);
  final incomeCount = ref.watch(incomesProvider).value?.length ?? 0;
  final expenseCount = ref.watch(expensesProvider).value?.length ?? 0;
  
  return DashboardSummary(
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    netIncome: netIncome,
    taxLiability: taxLiability,
    taxSavings: taxSavings,
    incomeCount: incomeCount,
    expenseCount: expenseCount,
  );
});

// ============================================================================
// HELPER CLASSES
// ============================================================================

/// Date range class
class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});
}

/// Dashboard summary class
class DashboardSummary {
  final double totalIncome;
  final double totalExpense;
  final double netIncome;
  final double taxLiability;
  final double taxSavings;
  final int incomeCount;
  final int expenseCount;

  DashboardSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netIncome,
    required this.taxLiability,
    required this.taxSavings,
    required this.incomeCount,
    required this.expenseCount,
  });

  double get savingsRate {
    if (totalIncome == 0) return 0;
    return ((totalIncome - totalExpense) / totalIncome) * 100;
  }

  double get expenseRatio {
    if (totalIncome == 0) return 0;
    return (totalExpense / totalIncome) * 100;
  }
}