/// Expense Form Screen
///
/// Add or edit expense

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/expense.dart';
import '../../data/services/api_service.dart';

class ExpenseFormScreen extends StatefulWidget {
  final Expense? expense;

  const ExpenseFormScreen({Key? key, this.expense}) : super(key: key);

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _category = 'HOUSING';
  String _frequency = 'MONTHLY';
  bool _active = true;
  bool _isNeed = true; // Needs vs Wants
  bool _isSubmitting = false;

  final List<String> _categories = [
    'HOUSING',
    'UTILITIES',
    'FOOD',
    'TRANSPORT',
    'HEALTHCARE',
    'EDUCATION',
    'INSURANCE',
    'LOAN_EMI',
    'ENTERTAINMENT',
    'SHOPPING',
    'SAVINGS',
    'OTHER',
  ];

  final List<String> _frequencies = [
    'MONTHLY',
    'QUARTERLY',
    'YEARLY',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _nameController.text = widget.expense!.name;
      _amountController.text = widget.expense!.amount.toString();
      _descriptionController.text = widget.expense!.description ?? '';
      _category = widget.expense!.category;
      _frequency = widget.expense!.frequency;
      _active = widget.expense!.active;
      _isNeed = widget.expense!.isNeed;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final expense = Expense(
        id: widget.expense?.id,
        name: _nameController.text,
        amount: double.parse(_amountController.text),
        category: _category,
        frequency: _frequency,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        active: _active,
        isNeed: _isNeed,
      );

      if (widget.expense == null) {
        await ApiService.createExpense(expense);
      } else {
        await ApiService.updateExpense(widget.expense!.id!, expense);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.expense == null
                ? 'Expense added successfully'
                : 'Expense updated successfully'),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Expense Name *',
                hintText: 'e.g., Rent, Groceries, Electricity',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter expense name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat.replaceAll('_', ' ')),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _category = value!);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount *',
                hintText: '0.00',
                border: OutlineInputBorder(),
                prefixText: 'Rs. ',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _frequency,
              decoration: const InputDecoration(
                labelText: 'Frequency *',
                border: OutlineInputBorder(),
              ),
              items: _frequencies.map((freq) {
                return DropdownMenuItem(
                  value: freq,
                  child: Text(freq),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _frequency = value!);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Add notes about this expense',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active'),
              subtitle: const Text('Include in calculations'),
              value: _active,
              onChanged: (value) {
                setState(() => _active = value);
              },
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  RadioListTile<bool>(
                    title: const Text('Need'),
                    subtitle: const Text('Essential expense (for emergency fund calculation)'),
                    value: true,
                    groupValue: _isNeed,
                    onChanged: (value) {
                      setState(() => _isNeed = value!);
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<bool>(
                    title: const Text('Want'),
                    subtitle: const Text('Discretionary expense'),
                    value: false,
                    groupValue: _isNeed,
                    onChanged: (value) {
                      setState(() => _isNeed = value!);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.expense == null ? 'Add Expense' : 'Update Expense'),
            ),
          ],
        ),
      ),
    );
  }
}

