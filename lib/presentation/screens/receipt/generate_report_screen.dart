import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tax/core/constants/app_colors.dart';
import 'package:tax/core/constants/app_strings.dart';
import 'package:tax/core/utilis/formatters.dart';
import 'package:tax/presentation/widgets/common_widgets.dart';
import 'package:tax/presentation/providers/app_providers.dart';

class GenerateReportScreen extends ConsumerWidget {
  const GenerateReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalIncome = ref.watch(totalIncomeProvider);
    final totalExpense = ref.watch(totalExpenseProvider);
    final netIncome = ref.watch(netIncomeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.generateReport),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implement share functionality
              Clipboard.setData(ClipboardData(
                text: 'Income: ${Formatters.formatNPR(totalIncome)}\n'
                      'Expenses: ${Formatters.formatNPR(totalExpense)}\n'
                      'Net: ${Formatters.formatNPR(netIncome)}',
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildReportItem('Total Income', Formatters.formatNPR(totalIncome), AppColors.success),
                    const Divider(),
                    _buildReportItem('Total Expenses', Formatters.formatNPR(totalExpense), AppColors.error),
                    const Divider(),
                    _buildReportItem('Net Income', Formatters.formatNPR(netIncome), AppColors.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Generate PDF',
              onPressed: () {
                // Implement PDF generation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PDF generation coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}