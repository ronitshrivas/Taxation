import '../constants/tax_rates.dart';

/// Comprehensive Tax Calculator for Nepal Income Tax
class TaxCalculator {
  TaxCalculator._();

  /// Calculate total income tax based on Nepal Income Tax Act 2058
  static TaxCalculationResult calculateTax({
    required double grossIncome,
    required bool isMarried,
    double providentFund = 0.0,
    double lifeInsurance = 0.0,
    double medicalInsurance = 0.0,
    double remoteAreaAllowance = 0.0,
    double donations = 0.0,
    double medicalExpenses = 0.0,
    double parentInsurance = 0.0,
  }) {
    // Select appropriate tax brackets
    final brackets = isMarried 
        ? TaxRates.marriedBrackets 
        : TaxRates.unmarriedBrackets;

    // Calculate total deductions
    final deductions = _calculateDeductions(
      providentFund: providentFund,
      lifeInsurance: lifeInsurance,
      medicalInsurance: medicalInsurance,
      remoteAreaAllowance: remoteAreaAllowance,
      donations: donations,
      medicalExpenses: medicalExpenses,
      parentInsurance: parentInsurance,
      grossIncome: grossIncome,
    );

    // Calculate taxable income
    final taxableIncome = (grossIncome - deductions.totalDeductions).clamp(0.0, double.infinity);

    // Calculate tax for each bracket
    double totalTax = 0.0;
    final List<BracketTaxDetail> bracketDetails = [];

    for (final bracket in brackets) {
      if (taxableIncome <= bracket.min.toDouble()) {
        break;
      }

      final amountInBracket = _getAmountInBracket(taxableIncome, bracket);
      final taxInBracket = amountInBracket * bracket.rate;
      totalTax += taxInBracket;

      bracketDetails.add(BracketTaxDetail(
        bracket: bracket,
        amountInBracket: amountInBracket,
        taxAmount: taxInBracket,
      ));
    }

    // Calculate effective tax rate
    final effectiveTaxRate = grossIncome > 0 ? totalTax / grossIncome : 0.0;

    // Calculate marginal tax rate (highest bracket reached)
    final marginalTaxRate = bracketDetails.isNotEmpty 
        ? bracketDetails.last.bracket.rate 
        : 0.0;

    return TaxCalculationResult(
      grossIncome: grossIncome,
      totalDeductions: deductions.totalDeductions,
      taxableIncome: taxableIncome,
      totalTax: totalTax,
      effectiveTaxRate: effectiveTaxRate,
      marginalTaxRate: marginalTaxRate,
      netIncome: grossIncome - totalTax,
      bracketDetails: bracketDetails,
      deductionBreakdown: deductions,
      isMarried: isMarried,
    );
  }

  /// Calculate amount of income in a specific tax bracket
  static double _getAmountInBracket(double taxableIncome, TaxBracket bracket) {
    if (taxableIncome <= bracket.min.toDouble()) {
      return 0.0;
    }

    final maxIncome = bracket.max.toDouble();
    if (taxableIncome >= maxIncome) {
      return maxIncome - bracket.min.toDouble();
    }

    return taxableIncome - bracket.min.toDouble();
  }

  /// Calculate all deductions with limits
  static DeductionBreakdown _calculateDeductions({
    required double providentFund,
    required double lifeInsurance,
    required double medicalInsurance,
    required double remoteAreaAllowance,
    required double donations,
    required double medicalExpenses,
    required double parentInsurance,
    required double grossIncome,
  }) {
    // Provident Fund (No limit)
    final pfDeduction = providentFund;

    // Life Insurance (Max NPR 25,000)
    final liDeduction = lifeInsurance.clamp(
      0.0, 
      TaxRates.lifeInsuranceMaxDeduction.toDouble(),
    );

    // Medical Insurance (Max NPR 20,000 individual, 25,000 family)
    final miDeduction = medicalInsurance.clamp(
      0.0, 
      TaxRates.medicalInsuranceFamilyMax.toDouble(),
    );

    // Remote Area Allowance (Max 50% of basic salary)
    final raDeduction = remoteAreaAllowance;

    // Donations (Max 10% of adjusted taxable income)
    final maxDonation = grossIncome * TaxRates.donationMaxPercentage;
    final donationDeduction = donations.clamp(0.0, maxDonation);

    // Medical Expenses (Max NPR 750 individual, 1,000 family)
    final meDeduction = medicalExpenses.clamp(
      0.0, 
      TaxRates.medicalExpenseFamilyMax.toDouble(),
    );

    // Parent Insurance (Max NPR 25,000)
    final piDeduction = parentInsurance.clamp(
      0.0, 
      TaxRates.medicalInsuranceFamilyMax.toDouble(),
    );

    final totalDeductions = pfDeduction + liDeduction + miDeduction + 
                           raDeduction + donationDeduction + meDeduction + piDeduction;

    return DeductionBreakdown(
      providentFund: pfDeduction,
      lifeInsurance: liDeduction,
      medicalInsurance: miDeduction,
      remoteAreaAllowance: raDeduction,
      donations: donationDeduction,
      medicalExpenses: meDeduction,
      parentInsurance: piDeduction,
      totalDeductions: totalDeductions,
    );
  }

  /// Calculate Social Security Fund (SSF) contribution
  static SSFContribution calculateSSF({
    required double monthlySalary,
    bool includeEmployer = true,
  }) {
    final baseSalary = monthlySalary.clamp(0.0, TaxRates.ssfMaximumContributionBase.toDouble());
    
    final employeeContribution = baseSalary * TaxRates.ssfEmployeeContributionRate;
    final employerContribution = includeEmployer 
        ? baseSalary * TaxRates.ssfEmployerContributionRate 
        : 0.0;
    
    return SSFContribution(
      monthlySalary: monthlySalary,
      baseSalary: baseSalary,
      employeeContribution: employeeContribution,
      employerContribution: employerContribution,
      totalContribution: employeeContribution + employerContribution,
    );
  }

  /// Calculate Citizens Investment Trust (CIT) contribution
  static CITContribution calculateCIT({
    required double annualSalary,
    bool includeEmployer = true,
  }) {
    final maxContribution = TaxRates.citMaxContribution.toDouble();
    final employeeContribution = (annualSalary * TaxRates.citEmployeeContributionRate)
        .clamp(0.0, maxContribution);
    final employerContribution = includeEmployer 
        ? (annualSalary * TaxRates.citEmployerContributionRate).clamp(0.0, maxContribution)
        : 0.0;
    
    return CITContribution(
      annualSalary: annualSalary,
      employeeContribution: employeeContribution,
      employerContribution: employerContribution,
      totalContribution: employeeContribution + employerContribution,
      maxContribution: maxContribution,
    );
  }

  /// Calculate potential tax savings with optimizations
  static TaxOptimization calculateOptimization({
    required double grossIncome,
    required bool isMarried,
    required double currentDeductions,
  }) {
    // Current tax with existing deductions
    final currentTax = calculateTax(
      grossIncome: grossIncome,
      isMarried: isMarried,
      providentFund: currentDeductions,
    );

    // Calculate maximum possible PF contribution (example: 10% of salary)
    final maxPFContribution = grossIncome * 0.10;
    
    // Calculate tax with maximum deductions
    final optimizedTax = calculateTax(
      grossIncome: grossIncome,
      isMarried: isMarried,
      providentFund: maxPFContribution,
      lifeInsurance: TaxRates.lifeInsuranceMaxDeduction.toDouble(),
      medicalInsurance: TaxRates.medicalInsuranceFamilyMax.toDouble(),
    );

    final potentialSavings = currentTax.totalTax - optimizedTax.totalTax;

    return TaxOptimization(
      currentTax: currentTax.totalTax,
      optimizedTax: optimizedTax.totalTax,
      potentialSavings: potentialSavings,
      savingsPercentage: currentTax.totalTax > 0 
          ? (potentialSavings / currentTax.totalTax) 
          : 0.0,
      suggestions: _generateOptimizationSuggestions(
        currentTax,
        optimizedTax,
        grossIncome,
      ),
    );
  }

  /// Generate optimization suggestions
  static List<OptimizationSuggestion> _generateOptimizationSuggestions(
    TaxCalculationResult current,
    TaxCalculationResult optimized,
    double grossIncome,
  ) {
    final suggestions = <OptimizationSuggestion>[];

    // PF Contribution Suggestion
    if (current.deductionBreakdown.providentFund < grossIncome * 0.10) {
      suggestions.add(OptimizationSuggestion(
        title: 'Increase Provident Fund Contribution',
        description: 'Contribute 10% of your salary to PF for maximum tax benefits',
        potentialSaving: current.totalTax - optimized.totalTax,
        priority: 'high',
        action: 'Increase PF contribution',
      ));
    }

    // Life Insurance Suggestion
    if (current.deductionBreakdown.lifeInsurance < TaxRates.lifeInsuranceMaxDeduction.toDouble()) {
      final saving = (TaxRates.lifeInsuranceMaxDeduction.toDouble() - 
                     current.deductionBreakdown.lifeInsurance) * 
                     current.marginalTaxRate;
      suggestions.add(OptimizationSuggestion(
        title: 'Get Life Insurance',
        description: 'Life insurance premium up to NPR 25,000 is tax deductible',
        potentialSaving: saving,
        priority: 'medium',
        action: 'Purchase life insurance',
      ));
    }

    // Medical Insurance Suggestion
    if (current.deductionBreakdown.medicalInsurance < TaxRates.medicalInsuranceFamilyMax.toDouble()) {
      final saving = (TaxRates.medicalInsuranceFamilyMax.toDouble() - 
                     current.deductionBreakdown.medicalInsurance) * 
                     current.marginalTaxRate;
      suggestions.add(OptimizationSuggestion(
        title: 'Get Health Insurance',
        description: 'Health insurance premium up to NPR 25,000 is tax deductible',
        potentialSaving: saving,
        priority: 'medium',
        action: 'Purchase health insurance',
      ));
    }

    return suggestions;
  }

  /// Calculate VAT amount
  static double calculateVAT(double amount) {
    return amount * TaxRates.vatRate;
  }

  /// Calculate amount with VAT
  static double addVAT(double amount) {
    return amount * (1 + TaxRates.vatRate);
  }

  /// Calculate amount without VAT
  static double removeVAT(double amountWithVAT) {
    return amountWithVAT / (1 + TaxRates.vatRate);
  }

  /// Compare tax scenarios
  static TaxComparison compareTaxScenarios({
    required double grossIncome,
    required bool isMarried,
    required DeductionScenario scenario1,
    required DeductionScenario scenario2,
  }) {
    final result1 = calculateTax(
      grossIncome: grossIncome,
      isMarried: isMarried,
      providentFund: scenario1.providentFund,
      lifeInsurance: scenario1.lifeInsurance,
      medicalInsurance: scenario1.medicalInsurance,
      remoteAreaAllowance: scenario1.remoteAreaAllowance,
      donations: scenario1.donations,
      medicalExpenses: scenario1.medicalExpenses,
      parentInsurance: scenario1.parentInsurance,
    );

    final result2 = calculateTax(
      grossIncome: grossIncome,
      isMarried: isMarried,
      providentFund: scenario2.providentFund,
      lifeInsurance: scenario2.lifeInsurance,
      medicalInsurance: scenario2.medicalInsurance,
      remoteAreaAllowance: scenario2.remoteAreaAllowance,
      donations: scenario2.donations,
      medicalExpenses: scenario2.medicalExpenses,
      parentInsurance: scenario2.parentInsurance,
    );

    return TaxComparison(
      scenario1Name: scenario1.name,
      scenario2Name: scenario2.name,
      scenario1Result: result1,
      scenario2Result: result2,
      taxDifference: result1.totalTax - result2.totalTax,
      netIncomeDifference: result1.netIncome - result2.netIncome,
    );
  }
}

// ============================================================================
// DATA MODELS
// ============================================================================

/// Complete tax calculation result
class TaxCalculationResult {
  final double grossIncome;
  final double totalDeductions;
  final double taxableIncome;
  final double totalTax;
  final double effectiveTaxRate;
  final double marginalTaxRate;
  final double netIncome;
  final List<BracketTaxDetail> bracketDetails;
  final DeductionBreakdown deductionBreakdown;
  final bool isMarried;

  TaxCalculationResult({
    required this.grossIncome,
    required this.totalDeductions,
    required this.taxableIncome,
    required this.totalTax,
    required this.effectiveTaxRate,
    required this.marginalTaxRate,
    required this.netIncome,
    required this.bracketDetails,
    required this.deductionBreakdown,
    required this.isMarried,
  });

  /// Get tax summary as string
  String get summary {
    return '''
Tax Calculation Summary
-----------------------
Gross Income: NPR ${grossIncome.toStringAsFixed(2)}
Total Deductions: NPR ${totalDeductions.toStringAsFixed(2)}
Taxable Income: NPR ${taxableIncome.toStringAsFixed(2)}
Total Tax: NPR ${totalTax.toStringAsFixed(2)}
Effective Tax Rate: ${(effectiveTaxRate * 100).toStringAsFixed(2)}%
Net Income: NPR ${netIncome.toStringAsFixed(2)}
''';
  }
}

/// Tax details for a specific bracket
class BracketTaxDetail {
  final TaxBracket bracket;
  final double amountInBracket;
  final double taxAmount;

  BracketTaxDetail({
    required this.bracket,
    required this.amountInBracket,
    required this.taxAmount,
  });
}

/// Breakdown of all deductions
class DeductionBreakdown {
  final double providentFund;
  final double lifeInsurance;
  final double medicalInsurance;
  final double remoteAreaAllowance;
  final double donations;
  final double medicalExpenses;
  final double parentInsurance;
  final double totalDeductions;

  DeductionBreakdown({
    required this.providentFund,
    required this.lifeInsurance,
    required this.medicalInsurance,
    required this.remoteAreaAllowance,
    required this.donations,
    required this.medicalExpenses,
    required this.parentInsurance,
    required this.totalDeductions,
  });

  /// Get list of non-zero deductions
  List<DeductionItem> get itemizedList {
    final items = <DeductionItem>[];

    if (providentFund > 0) {
      items.add(DeductionItem('Provident Fund', providentFund));
    }
    if (lifeInsurance > 0) {
      items.add(DeductionItem('Life Insurance', lifeInsurance));
    }
    if (medicalInsurance > 0) {
      items.add(DeductionItem('Medical Insurance', medicalInsurance));
    }
    if (remoteAreaAllowance > 0) {
      items.add(DeductionItem('Remote Area Allowance', remoteAreaAllowance));
    }
    if (donations > 0) {
      items.add(DeductionItem('Donations', donations));
    }
    if (medicalExpenses > 0) {
      items.add(DeductionItem('Medical Expenses', medicalExpenses));
    }
    if (parentInsurance > 0) {
      items.add(DeductionItem('Parent Insurance', parentInsurance));
    }

    return items;
  }
}

/// Individual deduction item
class DeductionItem {
  final String name;
  final double amount;

  DeductionItem(this.name, this.amount);
}

/// SSF contribution calculation result
class SSFContribution {
  final double monthlySalary;
  final double baseSalary;
  final double employeeContribution;
  final double employerContribution;
  final double totalContribution;

  SSFContribution({
    required this.monthlySalary,
    required this.baseSalary,
    required this.employeeContribution,
    required this.employerContribution,
    required this.totalContribution,
  });

  double get annualEmployeeContribution => employeeContribution * 12;
  double get annualEmployerContribution => employerContribution * 12;
  double get annualTotalContribution => totalContribution * 12;
}

/// CIT contribution calculation result
class CITContribution {
  final double annualSalary;
  final double employeeContribution;
  final double employerContribution;
  final double totalContribution;
  final double maxContribution;

  CITContribution({
    required this.annualSalary,
    required this.employeeContribution,
    required this.employerContribution,
    required this.totalContribution,
    required this.maxContribution,
  });

  bool get isMaxedOut => employeeContribution >= maxContribution;
}

/// Tax optimization analysis
class TaxOptimization {
  final double currentTax;
  final double optimizedTax;
  final double potentialSavings;
  final double savingsPercentage;
  final List<OptimizationSuggestion> suggestions;

  TaxOptimization({
    required this.currentTax,
    required this.optimizedTax,
    required this.potentialSavings,
    required this.savingsPercentage,
    required this.suggestions,
  });

  /// Get optimization score (0-100)
  int get optimizationScore {
    final score = ((1 - (optimizedTax / currentTax)) * 100).clamp(0.0, 100.0);
    return score.toInt();
  }
}

/// Individual optimization suggestion
class OptimizationSuggestion {
  final String title;
  final String description;
  final double potentialSaving;
  final String priority; // 'high', 'medium', 'low'
  final String action;

  OptimizationSuggestion({
    required this.title,
    required this.description,
    required this.potentialSaving,
    required this.priority,
    required this.action,
  });
}

/// Deduction scenario for comparison
class DeductionScenario {
  final String name;
  final double providentFund;
  final double lifeInsurance;
  final double medicalInsurance;
  final double remoteAreaAllowance;
  final double donations;
  final double medicalExpenses;
  final double parentInsurance;

  DeductionScenario({
    required this.name,
    this.providentFund = 0.0,
    this.lifeInsurance = 0.0,
    this.medicalInsurance = 0.0,
    this.remoteAreaAllowance = 0.0,
    this.donations = 0.0,
    this.medicalExpenses = 0.0,
    this.parentInsurance = 0.0,
  });

  double get totalDeductions =>
      providentFund +
      lifeInsurance +
      medicalInsurance +
      remoteAreaAllowance +
      donations +
      medicalExpenses +
      parentInsurance;
}

/// Tax comparison result
class TaxComparison {
  final String scenario1Name;
  final String scenario2Name;
  final TaxCalculationResult scenario1Result;
  final TaxCalculationResult scenario2Result;
  final double taxDifference;
  final double netIncomeDifference;

  TaxComparison({
    required this.scenario1Name,
    required this.scenario2Name,
    required this.scenario1Result,
    required this.scenario2Result,
    required this.taxDifference,
    required this.netIncomeDifference,
  });

  /// Get better scenario name
  String get betterScenario {
    return taxDifference > 0 ? scenario2Name : scenario1Name;
  }

  /// Get savings amount
  double get savings => taxDifference.abs();
}