import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tax/core/utilis/formatters.dart';
import 'package:tax/core/utilis/validators.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/income_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common_widgets.dart';

class AddIncomeScreen extends ConsumerStatefulWidget {
  final Income? income; // For editing

  const AddIncomeScreen({super.key, this.income});

  @override
  ConsumerState<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends ConsumerState<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _sourceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = IncomeCategory.salary;
  DateTime _selectedDate = DateTime.now();
  bool _isTaxable = true;
  bool _isRecurring = false;
  String? _recurringFrequency;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.income != null) {
      _loadIncomeData();
    }
  }

  void _loadIncomeData() {
    final income = widget.income!;
    _amountController.text = income.amount.toString();
    _sourceController.text = income.source;
    _descriptionController.text = income.description;
    _selectedCategory = income.category;
    _selectedDate = income.date;
    _isTaxable = income.isTaxable;
    _isRecurring = income.isRecurring;
    _recurringFrequency = income.recurringFrequency;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _sourceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveIncome() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('User not found');

      final repository = ref.read(incomeRepositoryProvider);
      final amount = double.parse(_amountController.text.replaceAll(',', ''));

      if (widget.income != null) {
        // Update existing income
        final updatedIncome = widget.income!.copyWith(
          amount: amount,
          source: _sourceController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          date: _selectedDate,
          isTaxable: _isTaxable,
          isRecurring: _isRecurring,
          recurringFrequency: _recurringFrequency,
          updatedAt: DateTime.now(),
        );
        await repository.updateIncome(updatedIncome);
      } else {
        // Add new income
        await repository.addIncome(
          userId: user.id,
          amount: amount,
          source: _sourceController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          date: _selectedDate,
          isTaxable: _isTaxable,
          isRecurring: _isRecurring,
          recurringFrequency: _recurringFrequency,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.income != null ? 'Income updated!' : 'Income added!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.income != null ? 'Edit Income' : AppStrings.addIncome),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Amount Field
            CustomTextField(
              controller: _amountController,
              label: 'Amount (NPR) *',
              hint: '50,000',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.currency_exchange),
              validator: Validators.validateAmount,
              onChanged: (value) {
                // Format as user types
                final formatted = Formatters.maskCurrencyInput(value);
                if (formatted != value) {
                  _amountController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
            ),

            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category *',
                prefixIcon: Icon(Icons.category),
              ),
              items: IncomeCategory.all.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(IncomeCategory.getDisplayName(category)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
              validator: (value) => Validators.validateRequired(value),
            ),

            const SizedBox(height: 16),

            // Source Field
            CustomTextField(
              controller: _sourceController,
              label: 'Source *',
              hint: 'Company name, client name, etc.',
              prefixIcon: const Icon(Icons.business),
              validator: (value) => Validators.validateRequired(value, fieldName: 'Source'),
            ),

            const SizedBox(height: 16),

            // Description Field
            CustomTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Additional details...',
              prefixIcon: const Icon(Icons.notes),
              maxLines: 3,
              validator: Validators.validateDescription,
            ),

            const SizedBox(height: 16),

            // Date Picker
            CustomTextField(
              controller: TextEditingController(
                text: Formatters.formatDate(_selectedDate),
              ),
              label: 'Date *',
              prefixIcon: const Icon(Icons.calendar_today),
              readOnly: true,
              onTap: _selectDate,
            ),

            const SizedBox(height: 24),

            // Tax Deductible Switch
            SwitchListTile(
              title: const Text('Taxable Income'),
              subtitle: const Text('Include this in tax calculations'),
              value: _isTaxable,
              onChanged: (value) => setState(() => _isTaxable = value),
              activeColor: AppColors.primary,
            ),

            const Divider(),

            // Recurring Income Switch
            SwitchListTile(
              title: const Text('Recurring Income'),
              subtitle: const Text('This income repeats regularly'),
              value: _isRecurring,
              onChanged: (value) => setState(() => _isRecurring = value),
              activeColor: AppColors.primary,
            ),

            if (_isRecurring) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _recurringFrequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: const [
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(value: 'quarterly', child: Text('Quarterly')),
                  DropdownMenuItem(value: 'annually', child: Text('Annually')),
                ],
                onChanged: (value) {
                  setState(() => _recurringFrequency = value);
                },
                validator: (value) {
                  if (_isRecurring && value == null) {
                    return 'Please select frequency';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 32),

            // Save Button
            CustomButton(
              text: widget.income != null ? 'Update Income' : 'Add Income',
              onPressed: _saveIncome,
              isLoading: _isLoading,
              icon: Icons.check,
              height: 54,
            ),

            const SizedBox(height: 16),

            // Cancel Button
            CustomButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(context),
              isOutlined: true,
              height: 54,
            ),
          ],
        ),
      ),
    );
  }
}