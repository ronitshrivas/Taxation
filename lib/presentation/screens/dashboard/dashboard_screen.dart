import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tax/core/utilis/formatters.dart';
import 'package:tax/presentation/screens/expenses/add_expenses_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common_widgets.dart';
import '../income/add_income_screen.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _selectedIndex == 0 ? _buildDashboard() : _buildPlaceholder(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _selectedIndex == 0 ? _buildFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final user = ref.watch(currentUserProvider);

    return AppBar(
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, ${user?.name ?? "User"}! 👋',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const Text(
            'Welcome back',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: Navigate to notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh data
        ref.invalidate(incomesProvider);
        ref.invalidate(expensesProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Summary Cards
            _buildSummaryCards(),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            _buildQuickActions(),
            
            const SizedBox(height: 24),
            
            // Income vs Expense Chart
            _buildIncomeExpenseChart(),
            
            const SizedBox(height: 24),
            
            // Recent Transactions
            _buildRecentTransactions(),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final summary = ref.watch(dashboardSummaryProvider);

    return Column(
      children: [
        // Tax Liability Card (Large)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.account_balance, color: Colors.white, size: 28),
                    SizedBox(width: 8),
                    Text(
                      AppStrings.taxLiability,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  Formatters.formatNPRWithoutDecimals(summary.taxLiability),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Fiscal Year ${DateTime.now().year}/${DateTime.now().year + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Small Summary Cards Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              SummaryCard(
                title: AppStrings.totalIncome,
                value: Formatters.formatNPRCompact(summary.totalIncome),
                icon: Icons.arrow_downward,
                color: AppColors.income,
                subtitle: '${summary.incomeCount} transactions',
              ),
              SummaryCard(
                title: AppStrings.totalExpenses,
                value: Formatters.formatNPRCompact(summary.totalExpense),
                icon: Icons.arrow_upward,
                color: AppColors.expense,
                subtitle: '${summary.expenseCount} transactions',
              ),
              SummaryCard(
                title: 'Net Income',
                value: Formatters.formatNPRCompact(summary.netIncome),
                icon: Icons.account_balance_wallet,
                color: summary.netIncome >= 0 ? AppColors.success : AppColors.error,
                subtitle: '${summary.savingsRate.toStringAsFixed(1)}% savings',
              ),
              SummaryCard(
                title: AppStrings.taxSavings,
                value: Formatters.formatNPRCompact(summary.taxSavings),
                icon: Icons.trending_up,
                color: AppColors.taxSavings,
                subtitle: 'Optimized',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        const SectionHeader(
          title: AppStrings.quickActions,
          icon: Icons.flash_on,
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildActionButton(
                icon: Icons.add_circle,
                label: AppStrings.addIncome,
                color: AppColors.income,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddIncomeScreen()),
                  );
                },
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.remove_circle,
                label: AppStrings.addExpense,
                color: AppColors.expense,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                  );
                },
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.camera_alt,
                label: AppStrings.scanReceipt,
                color: AppColors.secondary,
                onTap: () {
                  // TODO: Navigate to receipt scanner
                },
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.calculate,
                label: AppStrings.calculateTax,
                color: AppColors.primary,
                onTap: () {
                  // TODO: Navigate to tax calculator
                },
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.description,
                label: AppStrings.generateReport,
                color: AppColors.warning,
                onTap: () {
                  // TODO: Navigate to reports
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseChart() {
    final summary = ref.watch(dashboardSummaryProvider);

    return Column(
      children: [
        const SectionHeader(
          title: 'Income vs Expenses',
          icon: Icons.pie_chart,
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: summary.totalIncome == 0 && summary.totalExpense == 0
                ? const Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: summary.totalIncome,
                            title: '${((summary.totalIncome / (summary.totalIncome + summary.totalExpense)) * 100).toStringAsFixed(0)}%',
                            color: AppColors.income,
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: summary.totalExpense,
                            title: '${((summary.totalExpense / (summary.totalIncome + summary.totalExpense)) * 100).toStringAsFixed(0)}%',
                            color: AppColors.expense,
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Income', AppColors.income),
              _buildLegendItem('Expenses', AppColors.expense),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    final recentIncomes = ref.watch(recentIncomesProvider);
    final recentExpenses = ref.watch(recentExpensesProvider);

    // Combine and sort by date
    final allTransactions = [
      ...recentIncomes.map((i) => {'type': 'income', 'data': i, 'date': i.date}),
      ...recentExpenses.map((e) => {'type': 'expense', 'data': e, 'date': e.date}),
    ]..sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    return Column(
      children: [
        SectionHeader(
          title: AppStrings.recentTransactions,
          action: AppStrings.viewAll,
          onActionTap: () {
            setState(() => _selectedIndex = 1);
          },
          icon: Icons.history,
        ),
        if (allTransactions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: EmptyState(
              icon: Icons.receipt_long,
              title: 'No Transactions Yet',
              message: 'Start adding your income and expenses',
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allTransactions.take(5).length,
            itemBuilder: (context, index) {
              final transaction = allTransactions[index];
              final isIncome = transaction['type'] == 'income';
              final data = transaction['data'];
              final date = transaction['date'] as DateTime;
              final amount = (isIncome ? (data as dynamic).amount : (data as dynamic).amount) as double;

              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isIncome ? AppColors.income : AppColors.expense).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isIncome ? AppColors.income : AppColors.expense,
                  ),
                ),
                title: Text(
                  isIncome 
                      ? (data as dynamic).source ?? 'Unknown Income'
                      : (data as dynamic).description ?? 'Unknown Expense',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  Formatters.formatDate(date),
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Text(
                  '${isIncome ? '+' : '-'} ${Formatters.formatNPRCompact(amount)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isIncome ? AppColors.income : AppColors.expense,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Text('Feature coming soon...'),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calculate),
          label: 'Tax',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Reports',
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {
        _showAddTransactionDialog();
      },
      child: const Icon(Icons.add),
    );
  }

  void _showAddTransactionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Add Transaction',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAddButton(
                    icon: Icons.add_circle,
                    label: 'Add Income',
                    color: AppColors.income,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddIncomeScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickAddButton(
                    icon: Icons.remove_circle,
                    label: 'Add Expense',
                    color: AppColors.expense,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}