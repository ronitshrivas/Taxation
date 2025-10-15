import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tax/core/utilis/formatters.dart';
import 'package:tax/core/utilis/tax_calculatore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/tax_rates.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common_widgets.dart';

class AIOptimizerScreen extends ConsumerStatefulWidget {
  const AIOptimizerScreen({super.key});

  @override
  ConsumerState<AIOptimizerScreen> createState() => _AIOptimizerScreenState();
}

class _AIOptimizerScreenState extends ConsumerState<AIOptimizerScreen> {
  bool _isAnalyzing = false;
  TaxOptimization? _optimization;
  List<OptimizationSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _analyzeExpenses();
  }

  Future<void> _analyzeExpenses() async {
    setState(() => _isAnalyzing = true);

    // Simulate AI analysis delay
    await Future.delayed(const Duration(seconds: 2));

    try {
      final totalIncome = ref.read(totalIncomeProvider);
      final totalExpense = ref.read(totalExpenseProvider);
      final taxDeductible = ref.read(taxDeductibleExpensesProvider);
      final user = ref.read(currentUserProvider);

      // Calculate optimization
      final optimization = TaxCalculator.calculateOptimization(
        grossIncome: totalIncome,
        isMarried: user?.isMarried ?? false,
        currentDeductions: taxDeductible,
      );

      // Generate AI suggestions based on expense patterns
      final suggestions = await _generateAISuggestions(totalIncome, totalExpense, taxDeductible);

      setState(() {
        _optimization = optimization;
        _suggestions = suggestions;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() => _isAnalyzing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<List<OptimizationSuggestion>> _generateAISuggestions(
    double income,
    double expense,
    double currentDeductions,
  ) async {
    final suggestions = <OptimizationSuggestion>[];

    // Analyze current situation
    final deductionPercentage = income > 0 ? (currentDeductions / income) * 100 : 0;

    // Suggestion 1: Provident Fund
    if (deductionPercentage < 10) {
      final recommendedPF = income * 0.10;
      final potentialSaving = (recommendedPF - currentDeductions) * 0.30; // Assuming 30% tax bracket
      suggestions.add(OptimizationSuggestion(
        title: 'Maximize Provident Fund Contributions',
        description: 'Contributing 10% of your salary to PF can significantly reduce your tax burden. '
            'PF contributions are fully tax-deductible with no upper limit.',
        potentialSaving: potentialSaving,
        priority: 'high',
        action: 'Contribute NPR ${Formatters.formatNPRCompact(recommendedPF)} to PF',
      ));
    }

    // Suggestion 2: Life Insurance
    if (currentDeductions < TaxRates.lifeInsuranceMaxDeduction) {
      final saving = (TaxRates.lifeInsuranceMaxDeduction) * 0.30;
      suggestions.add(OptimizationSuggestion(
        title: 'Get Life Insurance Coverage',
        description: 'Life insurance premiums up to NPR 25,000 are tax-deductible. '
            'This provides both financial protection and tax benefits.',
        potentialSaving: saving,
        priority: 'high',
        action: 'Get life insurance policy',
      ));
    }

    // Suggestion 3: Health Insurance
    suggestions.add(OptimizationSuggestion(
      title: 'Purchase Health/Medical Insurance',
      description: 'Medical insurance premiums up to NPR 25,000 are tax-deductible. '
          'Protect your health while saving on taxes.',
      potentialSaving: TaxRates.medicalInsuranceFamilyMax * 0.30,
      priority: 'high',
      action: 'Get health insurance for family',
    ));

    // Suggestion 4: Document Missing Expenses
    final undocumentedExpenses = expense - currentDeductions;
    if (undocumentedExpenses > 50000) {
      suggestions.add(OptimizationSuggestion(
        title: 'Document Business Expenses',
        description: 'You have significant expenses without receipts. '
            'Ensure all business expenses are properly documented with bills/receipts.',
        potentialSaving: undocumentedExpenses * 0.25,
        priority: 'medium',
        action: 'Collect missing receipts',
      ));
    }

    // Suggestion 5: Charitable Donations
    final maxDonation = income * 0.10;
    if (maxDonation > 10000) {
      suggestions.add(OptimizationSuggestion(
        title: 'Make Tax-Deductible Donations',
        description: 'Donations to approved charitable organizations are tax-deductible '
            'up to 10% of your adjusted income.',
        potentialSaving: maxDonation * 0.30,
        priority: 'low',
        action: 'Donate to approved charities',
      ));
    }

    // Suggestion 6: Remote Area Allowance
    suggestions.add(OptimizationSuggestion(
      title: 'Claim Remote Area Allowance',
      description: 'If you work in a remote area, you can claim up to 50% of your '
          'basic salary as tax-free allowance.',
      potentialSaving: income * 0.25 * 0.30,
      priority: 'medium',
      action: 'Check eligibility for remote area allowance',
    ));

    // Sort by priority and potential saving
    suggestions.sort((a, b) {
      final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
      final priorityCompare = (priorityOrder[a.priority] ?? 3)
          .compareTo(priorityOrder[b.priority] ?? 3);
      if (priorityCompare != 0) return priorityCompare;
      return b.potentialSaving.compareTo(a.potentialSaving);
    });

    return suggestions.take(5).toList(); // Return top 5 suggestions
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tax Optimizer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _analyzeExpenses,
          ),
        ],
      ),
      body: _isAnalyzing
          ? const LoadingIndicator(message: 'Analyzing your finances...')
          : _optimization == null
              ? const EmptyState(
                  icon: Icons.analytics,
                  title: 'No Analysis Yet',
                  message: 'Start tracking income and expenses to get optimization suggestions',
                )
              : RefreshIndicator(
                  onRefresh: _analyzeExpenses,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Optimization Score Card
                      _buildScoreCard(),

                      const SizedBox(height: 24),

                      // Savings Summary
                      _buildSavingsSummary(),

                      const SizedBox(height: 24),

                      // AI Suggestions
                      const Text(
                        'AI-Powered Suggestions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Based on your financial data, here are personalized tax optimization strategies:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Suggestion Cards
                      ..._suggestions.asMap().entries.map((entry) {
                        return _buildSuggestionCard(entry.value, entry.key + 1);
                      }),
                    ],
                  ),
                ),
    );
  }

  Widget _buildScoreCard() {
    final score = _optimization!.optimizationScore;
    final color = score >= 80
        ? AppColors.success
        : score >= 50
            ? AppColors.warning
            : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Optimization Score',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$score',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'out of 100',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            score >= 80
                ? '🎉 Excellent! Your tax strategy is well optimized'
                : score >= 50
                    ? '👍 Good, but there\'s room for improvement'
                    : '⚠️ You can save much more on taxes!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Tax',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatNPRCompact(_optimization!.currentTax),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_forward, color: AppColors.textSecondary),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Optimized Tax',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatNPRCompact(_optimization!.optimizedTax),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.savings,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Potential Savings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    Formatters.formatNPRCompact(_optimization!.potentialSavings),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(OptimizationSuggestion suggestion, int index) {
    final priorityColor = suggestion.priority == 'high'
        ? AppColors.error
        : suggestion.priority == 'medium'
            ? AppColors.warning
            : AppColors.info;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: TextStyle(
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    suggestion.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    suggestion.priority.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: priorityColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              suggestion.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.trending_up,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Potential Savings: ${Formatters.formatNPRCompact(suggestion.potentialSaving)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.lightbulb, size: 16, color: AppColors.warning),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    suggestion.action,
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}