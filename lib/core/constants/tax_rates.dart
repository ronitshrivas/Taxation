/// Nepal Income Tax Rates and Constants
/// Based on Nepal Income Tax Act 2058 (FY 2081/82)
class TaxRates {
  TaxRates._();

  // Tax Brackets for Individual - Unmarried (FY 2081/82)
  static const List<TaxBracket> unmarriedBrackets = [
    TaxBracket(min: 0, max: 500000, rate: 0.01),
    TaxBracket(min: 500001, max: 700000, rate: 0.10),
    TaxBracket(min: 700001, max: 1000000, rate: 0.20),
    TaxBracket(min: 1000001, max: 2000000, rate: 0.30),
    TaxBracket(min: 2000001, max: double.infinity, rate: 0.36),
  ];

  // Tax Brackets for Individual - Married (FY 2081/82)
  static const List<TaxBracket> marriedBrackets = [
    TaxBracket(min: 0, max: 600000, rate: 0.01),
    TaxBracket(min: 600001, max: 800000, rate: 0.10),
    TaxBracket(min: 800001, max: 1100000, rate: 0.20),
    TaxBracket(min: 1100001, max: 2100000, rate: 0.30),
    TaxBracket(min: 2100001, max: double.infinity, rate: 0.36),
  ];

  // Deduction Limits
  static const double providentFundMaxDeduction = double.infinity; // No limit
  static const double lifeInsuranceMaxDeduction = 25000; // NPR 25,000
  static const double medicalInsuranceIndividualMax = 20000; // NPR 20,000
  static const double medicalInsuranceFamilyMax = 25000; // NPR 25,000
  static const double medicalExpenseIndividualMax = 750; // NPR 750
  static const double medicalExpenseFamilyMax = 1000; // NPR 1,000
  static const double remoteAreaAllowanceMaxPercentage = 0.50; // 50% of basic salary
  static const double donationMaxPercentage = 0.10; // 10% of adjusted taxable income

  // Social Security Fund (SSF) Rates
  static const double ssfEmployeeContributionRate = 0.11; // 11%
  static const double ssfEmployerContributionRate = 0.20; // 20%
  static const double ssfMaximumContributionBase = 50000; // NPR 50,000 per month

  // Citizens Investment Trust (CIT) Rates
  static const double citMaxContribution = 300000; // NPR 300,000 per year
  static const double citEmployeeContributionRate = 0.10; // 10%
  static const double citEmployerContributionRate = 0.10; // 10%

  // Employees Provident Fund (EPF) Rates
  static const double epfEmployeeContributionRate = 0.10; // 10%
  static const double epfEmployerContributionRate = 0.10; // 10%

  // VAT (Value Added Tax)
  static const double vatRate = 0.13; // 13%

  // Excise Duty Rates (examples)
  static const double exciseDutyAlcohol = 0.35; // 35%
  static const double exciseDutyTobacco = 0.16; // 16%
  static const double exciseDutyVehicle = 0.60; // 60%

  // Corporate Tax Rates
  static const double corporateTaxRate = 0.25; // 25%
  static const double bankingInstitutionTaxRate = 0.30; // 30%
  static const double specialIndustryTaxRate = 0.20; // 20%

  // Tax Exemption Limits
  static const double basicExemptionLimit = 500000; // NPR 5 lakh for unmarried
  static const double marriedExemptionLimit = 600000; // NPR 6 lakh for married

  // Fiscal Year
  static const String currentFiscalYear = '2081/82';
  static const String fiscalYearStartMonth = 'Shrawan'; // July/August
  static const String fiscalYearEndMonth = 'Ashadh'; // June/July

  // Tax Filing Deadlines
  static const String annualTaxDeadline = 'Magh End'; // Mid-January to Mid-February
  static const String quarterlyVATDeadline = '25th of next month';
  static const String monthlyTDSDeadline = '25th of next month';

  // Penalties
  static const double lateFilingPenalty = 10000; // NPR 10,000
  static const double latePaymentInterestRate = 0.15; // 15% per annum

  // Tax Identification
  static const int panLength = 9; // 9 digits
  static const int vatNumberLength = 9; // 9 digits

  // Remote Area Categories
  static const List<String> remoteAreaCategories = [
    'Very Remote (50% allowance)',
    'Remote (30% allowance)',
    'Normal Area (No allowance)',
  ];

  // Tax Payment Methods
  static const List<String> paymentMethods = [
    'eSewa',
    'Khalti',
    'Bank Transfer',
    'IRD Portal',
    'Connect IPS',
  ];
}

/// Tax Bracket Model
class TaxBracket {
  final double min;
  final double max;
  final double rate;

  const TaxBracket({
    required this.min,
    required this.max,
    required this.rate,
  });

  String get ratePercentage => '${(rate * 100).toStringAsFixed(0)}%';

  String get rangeDescription {
    if (max == double.infinity) {
      return 'Above NPR ${min.toStringAsFixed(0)}';
    }
    return 'NPR ${min.toStringAsFixed(0)} - ${max.toStringAsFixed(0)}';
  }

  bool isInBracket(double amount) {
    return amount > min && amount <= max;
  }
}

/// Deduction Categories
class DeductionCategory {
  final String id;
  final String name;
  final String nameNepali;
  final double? maxLimit;
  final String description;
  final String legalReference;

  const DeductionCategory({
    required this.id,
    required this.name,
    required this.nameNepali,
    this.maxLimit,
    required this.description,
    required this.legalReference,
  });
}

/// Predefined Deduction Categories
class DeductionCategories {
  static const providentFund = DeductionCategory(
    id: 'provident_fund',
    name: 'Provident Fund',
    nameNepali: 'भविष्य कोष',
    maxLimit: null, // No limit
    description: 'Contributions to CIT, EPF, or SSF',
    legalReference: 'Section 12(2)(kha)',
  );

  static const lifeInsurance = DeductionCategory(
    id: 'life_insurance',
    name: 'Life Insurance Premium',
    nameNepali: 'जीवन बीमा प्रिमियम',
    maxLimit: 25000,
    description: 'Premium paid for life insurance',
    legalReference: 'Section 12(2)(kha)',
  );

  static const medicalInsurance = DeductionCategory(
    id: 'medical_insurance',
    name: 'Medical Insurance Premium',
    nameNepali: 'चिकित्सा बीमा प्रिमियम',
    maxLimit: 25000,
    description: 'Health/accident insurance for self and family',
    legalReference: 'Section 12(2)(kha)',
  );

  static const remoteAreaAllowance = DeductionCategory(
    id: 'remote_area',
    name: 'Remote Area Allowance',
    nameNepali: 'दुर्गम क्षेत्र भत्ता',
    maxLimit: null, // 50% of basic salary
    description: 'Allowance for working in remote areas',
    legalReference: 'Section 12(2)(ga)',
  );

  static const donations = DeductionCategory(
    id: 'donations',
    name: 'Donations',
    nameNepali: 'दान',
    maxLimit: null, // 10% of adjusted income
    description: 'Donations to approved organizations',
    legalReference: 'Section 12(2)(cha)',
  );

  static const medicalExpenses = DeductionCategory(
    id: 'medical_expenses',
    name: 'Medical Expenses',
    nameNepali: 'चिकित्सा खर्च',
    maxLimit: 1000,
    description: 'Medical treatment expenses',
    legalReference: 'Section 12(2)(ta)',
  );

  static const parentInsurance = DeductionCategory(
    id: 'parent_insurance',
    name: 'Parent Health Insurance',
    nameNepali: 'आमाबाबुको स्वास्थ्य बीमा',
    maxLimit: 25000,
    description: 'Health/accident insurance for dependent parents',
    legalReference: 'Section 12(2)(kha)',
  );

  static List<DeductionCategory> get all => [
        providentFund,
        lifeInsurance,
        medicalInsurance,
        remoteAreaAllowance,
        donations,
        medicalExpenses,
        parentInsurance,
      ];
}

/// Expense Categories with Tax Deductibility
class ExpenseCategory {
  final String id;
  final String name;
  final String nameNepali;
  final bool taxDeductible;
  final String description;

  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.nameNepali,
    required this.taxDeductible,
    required this.description,
  });
}

/// Business Expense Categories
class BusinessExpenseCategories {
  static const officeRent = ExpenseCategory(
    id: 'office_rent',
    name: 'Office Rent',
    nameNepali: 'कार्यालय भाडा',
    taxDeductible: true,
    description: 'Rent paid for business premises',
  );

  static const salaries = ExpenseCategory(
    id: 'salaries',
    name: 'Employee Salaries',
    nameNepali: 'कर्मचारी तलब',
    taxDeductible: true,
    description: 'Wages and salaries paid to employees',
  );

  static const utilities = ExpenseCategory(
    id: 'utilities',
    name: 'Utilities',
    nameNepali: 'उपयोगिताहरू',
    taxDeductible: true,
    description: 'Electricity, water, internet, phone',
  );

  static const travel = ExpenseCategory(
    id: 'travel',
    name: 'Travel & Transport',
    nameNepali: 'यात्रा र यातायात',
    taxDeductible: true,
    description: 'Business travel and transportation costs',
  );

  static const professionalFees = ExpenseCategory(
    id: 'professional_fees',
    name: 'Professional Fees',
    nameNepali: 'व्यावसायिक शुल्क',
    taxDeductible: true,
    description: 'Legal, accounting, consulting fees',
  );

  static const insurance = ExpenseCategory(
    id: 'insurance',
    name: 'Insurance Premiums',
    nameNepali: 'बीमा प्रिमियम',
    taxDeductible: true,
    description: 'Business insurance premiums',
  );

  static const marketing = ExpenseCategory(
    id: 'marketing',
    name: 'Marketing & Advertising',
    nameNepali: 'मार्केटिंग र विज्ञापन',
    taxDeductible: true,
    description: 'Advertising and promotional expenses',
  );

  static const training = ExpenseCategory(
    id: 'training',
    name: 'Training & Development',
    nameNepali: 'प्रशिक्षण र विकास',
    taxDeductible: true,
    description: 'Employee training and development',
  );

  static const repairs = ExpenseCategory(
    id: 'repairs',
    name: 'Repairs & Maintenance',
    nameNepali: 'मर्मत र रखरखाव',
    taxDeductible: true,
    description: 'Maintenance of equipment and premises',
  );

  static const communication = ExpenseCategory(
    id: 'communication',
    name: 'Communication',
    nameNepali: 'संचार',
    taxDeductible: true,
    description: 'Phone, internet, postal services',
  );

  static const interest = ExpenseCategory(
    id: 'interest',
    name: 'Interest Payments',
    nameNepali: 'ब्याज भुक्तानी',
    taxDeductible: true,
    description: 'Interest on business loans',
  );

  static const depreciation = ExpenseCategory(
    id: 'depreciation',
    name: 'Depreciation',
    nameNepali: 'ह्रास',
    taxDeductible: true,
    description: 'Asset depreciation',
  );

  static const officeSupplies = ExpenseCategory(
    id: 'office_supplies',
    name: 'Office Supplies',
    nameNepali: 'कार्यालय सामग्री',
    taxDeductible: true,
    description: 'Stationery and office materials',
  );

  static const entertainment = ExpenseCategory(
    id: 'entertainment',
    name: 'Entertainment',
    nameNepali: 'मनोरञ्जन',
    taxDeductible: false,
    description: 'Business entertainment (limited deductibility)',
  );

  static const personal = ExpenseCategory(
    id: 'personal',
    name: 'Personal',
    nameNepali: 'व्यक्तिगत',
    taxDeductible: false,
    description: 'Non-deductible personal expenses',
  );

  static List<ExpenseCategory> get all => [
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
      ];

  static List<ExpenseCategory> get deductibleOnly =>
      all.where((cat) => cat.taxDeductible).toList();
}