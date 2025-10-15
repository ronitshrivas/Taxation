import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tax/core/constants/app_strings.dart';
import 'package:tax/core/utilis/formatters.dart';
import 'package:tax/core/utilis/tax_calculatore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/tax_rates.dart';
import '../../widgets/common_widgets.dart';

class TaxCalculatorScreen extends ConsumerStatefulWidget {
  const TaxCalculatorScreen({super.key});

  @override
  ConsumerState<TaxCalculatorScreen> createState() => _TaxCalculatorScreenState();
}

class _TaxCalculatorScreenState extends ConsumerState<TaxCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incomeController = TextEditingController(text: '1500000');
  final _pfController = TextEditingController(text: '150000');
  final _lifeInsController = TextEditingController(text: '0');
  final _medInsController = TextEditingController(text: '0');
  final _donationsController = TextEditingController(text: '0');

  bool _isMarried = false;
  TaxCalculationResult? _result;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _pfController.dispose();
    _lifeInsController.dispose();
    _medInsController.dispose();
    _donationsController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) return;

    final grossIncome = double.tryParse(_incomeController.text.replaceAll(',', '')) ?? 0;
    final pf = double.tryParse(_pfController.text.replaceAll(',', '')) ?? 0;
    final lifeIns = double.tryParse(_lifeInsController.text.replaceAll(',', '')) ?? 0;
    final medIns = double.tryParse(_medInsController.text.replaceAll(',', '')) ?? 0;
    final donations = double.tryParse(_donationsController.text.replaceAll(',', '')) ?? 0;

    setState(() {
      _result = TaxCalculator.calculateTax(
        grossIncome: grossIncome,
        isMarried: _isMarried,
        providentFund: pf,
        lifeInsurance: lifeIns,
        medicalInsurance: medIns,
        donations: donations,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.taxCalculator),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showTaxInfo,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Marital Status Switch
              Card(
                child: SwitchListTile(
                  title: const Text('Marital Status'),
                  subtitle: Text(_isMarried ? 'Married' : 'Unmarried'),
                  value: _isMarried,
                  onChanged: (value) {
                    setState(() => _isMarried = value);
                    _calculate();
                  },
                  activeColor: AppColors.primary,
                ),
              ),

              const SizedBox(height: 24),

              // Input Section
              const Text(
                'Income & Deductions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Gross Income
              CustomTextField(
                controller: _incomeController,
                label: 'Gross Annual Income (NPR)',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.currency_exchange),
                onChanged: (_) => _calculate(),
              ),

              const SizedBox(height: 16),

              // Provident Fund
              CustomTextField(
                controller: _pfController,
                label: 'Provident Fund Contribution',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.savings),
                onChanged: (_) => _calculate(),
              ),

              const SizedBox(height: 16),

              // Life Insurance
              CustomTextField(
                controller: _lifeInsController,
                label: 'Life Insurance Premium (Max 25,000)',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.shield),
                onChanged: (_) => _calculate(),
              ),

              const SizedBox(height: 16),

              // Medical Insurance
              CustomTextField(
                controller: _medInsController,
                label: 'Medical Insurance (Max 25,000)',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.medical_services),
                onChanged: (_) => _calculate(),
              ),

              const SizedBox(height: 16),

              // Donations
              CustomTextField(
                controller: _donationsController,
                label: 'Donations (Max 10% of income)',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.volunteer_activism),
                onChanged: (_) => _calculate(),
              ),

              const SizedBox(height: 32),

              // Results Section
              if (_result != null) ...[
                const Text(
                  'Tax Calculation Result',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Tax Summary Card
                _buildTaxSummaryCard(),

                const SizedBox(height: 16),

                // Breakdown Cards
                _buildBreakdownCards(),

                const SizedBox(height: 16),

                // Tax Brackets Visualization
                _buildTaxBracketsChart(),

                const SizedBox(height: 16),

                // Deductions Breakdown
                _buildDeductionsBreakdown(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaxSummaryCard() {
    return Container(
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
        children: [
          const Text(
            'Total Tax Liability',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.formatNPR(_result!.totalTax),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Effective Rate',
                Formatters.formatPercentage(_result!.effectiveTaxRate),
              ),
              Container(width: 1, height: 40, color: Colors.white30),
              _buildSummaryItem(
                'Net Income',
                Formatters.formatNPRCompact(_result!.netIncome),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownCards() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            'Gross Income',
            Formatters.formatNPRCompact(_result!.grossIncome),
            Icons.trending_up,
            AppColors.income,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            'Deductions',
            Formatters.formatNPRCompact(_result!.totalDeductions),
            Icons.remove_circle,
            AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxBracketsChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tax by Bracket',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _result!.bracketDetails.isEmpty
                  ? const Center(child: Text('No tax applicable'))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _result!.bracketDetails
                            .map((e) => e.taxAmount)
                            .reduce((a, b) => a > b ? a : b) * 1.2,
                        barGroups: _result!.bracketDetails.asMap().entries.map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.taxAmount,
                                color: AppColors.primary,
                                width: 20,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  Formatters.formatNPRCompact(value),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= _result!.bracketDetails.length) {
                                  return const SizedBox();
                                }
                                final bracket = _result!.bracketDetails[value.toInt()];
                                return Text(
                                  bracket.bracket.ratePercentage,
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            // Bracket details
            ..._result!.bracketDetails.map((detail) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${detail.bracket.ratePercentage} bracket',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      Formatters.formatNPRCompact(detail.taxAmount),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDeductionsBreakdown() {
    final deductions = _result!.deductionBreakdown;
    final items = deductions.itemizedList;

    if (items.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No deductions claimed'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deductions Claimed',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Formatters.formatNPRCompact(item.amount),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Deductions',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  Formatters.formatNPRCompact(deductions.totalDeductions),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTaxInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nepal Income Tax Rates'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isMarried ? 'Married Individual Rates:' : 'Unmarried Individual Rates:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...(_isMarried ? TaxRates.marriedBrackets : TaxRates.unmarriedBrackets).map((bracket) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          bracket.rangeDescription,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        bracket.ratePercentage,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              const Text(
                'Maximum Deductions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Provident Fund: No limit', style: TextStyle(fontSize: 13)),
              const Text('• Life Insurance: NPR 25,000', style: TextStyle(fontSize: 13)),
              const Text('• Medical Insurance: NPR 25,000', style: TextStyle(fontSize: 13)),
              const Text('• Donations: 10% of income', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}