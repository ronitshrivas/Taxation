import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tax/core/utilis/formatters.dart';
import 'package:tax/presentation/screens/expenses/add_expenses_screen.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/expense_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common_widgets.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  String? _selectedCategory;
  bool? _filterTaxDeductible;
  String _sortBy = 'date';
  bool _sortAscending = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Expense> _getSortedExpenses(List<Expense> expenses) {
    var sorted = List<Expense>.from(expenses);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      sorted = sorted.where((expense) {
        return expense.description.toLowerCase().contains(query) ||
               (expense.merchantName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      sorted = sorted.where((expense) => expense.category == _selectedCategory).toList();
    }

    // Apply tax deductible filter
    if (_filterTaxDeductible != null) {
      sorted = sorted.where((expense) => expense.isTaxDeductible == _filterTaxDeductible).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'date':
        sorted.sort((a, b) => _sortAscending 
            ? a.date.compareTo(b.date)
            : b.date.compareTo(a.date));
        break;
      case 'amount':
        sorted.sort((a, b) => _sortAscending 
            ? a.amount.compareTo(b.amount)
            : b.amount.compareTo(a.amount));
        break;
      case 'category':
        sorted.sort((a, b) => _sortAscending 
            ? a.category.compareTo(b.category)
            : b.category.compareTo(a.category));
        break;
    }

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);
    final totalExpense = ref.watch(totalExpenseProvider);
    final taxDeductible = ref.watch(taxDeductibleExpensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.expenseList),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _searchController.clear());
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Summary Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.expense, AppColors.expense.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Expenses',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.formatNPRCompact(totalExpense),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.successGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tax Deductible',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.formatNPRCompact(taxDeductible),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Active Filters
          if (_selectedCategory != null || _filterTaxDeductible != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedCategory != null)
                    Chip(
                      label: Text(ExpenseCategoryHelper.getDisplayName(_selectedCategory!)),
                      onDeleted: () => setState(() => _selectedCategory = null),
                      deleteIcon: const Icon(Icons.close, size: 18),
                    ),
                  if (_filterTaxDeductible != null)
                    Chip(
                      label: Text(_filterTaxDeductible! ? 'Deductible' : 'Non-deductible'),
                      onDeleted: () => setState(() => _filterTaxDeductible = null),
                      deleteIcon: const Icon(Icons.close, size: 18),
                    ),
                ],
              ),
            ),

          // Expense List
          Expanded(
            child: expensesAsync.when(
              data: (expenses) {
                final sortedExpenses = _getSortedExpenses(expenses);

                if (sortedExpenses.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long,
                    title: _searchController.text.isNotEmpty 
                        ? 'No Results Found'
                        : AppStrings.noExpenses,
                    message: _searchController.text.isNotEmpty
                        ? 'Try different search terms'
                        : AppStrings.startAddingExpenses,
                    actionText: AppStrings.addExpense,
                    onAction: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                      );
                    },
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sortedExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = sortedExpenses[index];
                    return _buildExpenseItem(expense);
                  },
                );
              },
              loading: () => ListView.builder(
                itemCount: 5,
                itemBuilder: (_, __) => const ShimmerLoadingCard(),
              ),
              error: (error, stack) => ErrorState(
                message: error.toString(),
                onRetry: () => ref.invalidate(expensesProvider),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
        backgroundColor: AppColors.expense,
      ),
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    return Slidable(
      key: ValueKey(expense.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _editExpense(expense),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) => _deleteExpense(expense),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.expense.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: expense.hasReceipt
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: expense.receiptPath != null
                        ? Image.file(
                            File(expense.receiptPath!),
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.receipt, color: AppColors.expense),
                  )
                : const Icon(Icons.arrow_upward, color: AppColors.expense),
          ),
          title: Text(
            expense.description,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                ExpenseCategoryHelper.getDisplayName(expense.category),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              if (expense.merchantName != null) ...[
                const SizedBox(height: 2),
                Text(
                  expense.merchantName!,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    Formatters.formatDate(expense.date),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  if (expense.isTaxDeductible) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 10,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Deductible',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (expense.hasReceipt) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.attach_file,
                      size: 12,
                      color: AppColors.primary,
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.formatNPRCompact(expense.amount),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.expense,
                ),
              ),
              if (expense.vatAmount != null && expense.vatAmount! > 0)
                Text(
                  'VAT: ${Formatters.formatNPRCompact(expense.vatAmount!)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
            ],
          ),
          onTap: () => _editExpense(expense),
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter & Sort',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Category Filter
            const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                CategoryChip(
                  label: 'All',
                  isSelected: _selectedCategory == null,
                  onTap: () {
                    setState(() => _selectedCategory = null);
                    Navigator.pop(context);
                  },
                ),
                ...ExpenseCategoryHelper.all.map((category) {
                  return CategoryChip(
                    label: ExpenseCategoryHelper.getDisplayName(category),
                    isSelected: _selectedCategory == category,
                    color: AppColors.expense,
                    onTap: () {
                      setState(() => _selectedCategory = category);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Tax Deductible Filter
            const Text('Tax Deductible', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                CategoryChip(
                  label: 'All',
                  isSelected: _filterTaxDeductible == null,
                  onTap: () {
                    setState(() => _filterTaxDeductible = null);
                    Navigator.pop(context);
                  },
                ),
                CategoryChip(
                  label: 'Deductible',
                  isSelected: _filterTaxDeductible == true,
                  color: AppColors.success,
                  onTap: () {
                    setState(() => _filterTaxDeductible = true);
                    Navigator.pop(context);
                  },
                ),
                CategoryChip(
                  label: 'Non-deductible',
                  isSelected: _filterTaxDeductible == false,
                  color: AppColors.warning,
                  onTap: () {
                    setState(() => _filterTaxDeductible = false);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Sort By
            const Text('Sort By', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _sortBy,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'date', child: Text('Date')),
                      DropdownMenuItem(value: 'amount', child: Text('Amount')),
                      DropdownMenuItem(value: 'category', child: Text('Category')),
                    ],
                    onChanged: (value) {
                      setState(() => _sortBy = value!);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  ),
                  onPressed: () {
                    setState(() => _sortAscending = !_sortAscending);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editExpense(Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(expense: expense),
      ),
    );
  }

  Future<void> _deleteExpense(Expense expense) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Expense'),
      content: const Text('Are you sure you want to delete this expense?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    try {
      final repository = ref.read(expenseRepositoryProvider);
      await repository.deleteExpense(expense.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}
}