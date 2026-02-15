/// Income Form Screen
///
/// Add or edit income source

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/income.dart';
import '../../data/services/api_service.dart';

class IncomeFormScreen extends StatefulWidget {
  final Income? income;

  const IncomeFormScreen({Key? key, this.income}) : super(key: key);

  @override
  State<IncomeFormScreen> createState() => _IncomeFormScreenState();
}

class _IncomeFormScreenState extends State<IncomeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sourceController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _type = 'SALARY';
  String _frequency = 'MONTHLY';
  bool _active = true;
  bool _isSubmitting = false;

  final List<String> _types = [
    'SALARY',
    'BUSINESS',
    'RENTAL',
    'INVESTMENT',
    'PENSION',
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
    if (widget.income != null) {
      _sourceController.text = widget.income!.source;
      _amountController.text = widget.income!.amount.toString();
      _descriptionController.text = widget.income!.description ?? '';
      _type = widget.income!.type;
      _frequency = widget.income!.frequency;
      _active = widget.income!.active;
    }
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Parse amount - remove commas
    final amountText = _amountController.text.replaceAll(',', '').replaceAll(' ', '').trim();
    final amount = double.tryParse(amountText) ?? 0;

    try {
      final income = Income(
        id: widget.income?.id,
        source: _sourceController.text,
        amount: amount,
        type: _type,
        frequency: _frequency,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        active: _active,
      );

      if (widget.income == null) {
        await ApiService.createIncome(income);
      } else {
        await ApiService.updateIncome(widget.income!.id!, income);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.income == null
                ? 'Income added successfully'
                : 'Income updated successfully'),
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
        title: Text(widget.income == null ? 'Add Income' : 'Edit Income'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _sourceController,
              decoration: const InputDecoration(
                labelText: 'Income Source *',
                hintText: 'e.g., Monthly Salary, Rental Income',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter income source';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'Type *',
                border: OutlineInputBorder(),
              ),
              items: _types.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _type = value!);
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
                hintText: 'Add notes about this income',
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.income == null ? 'Add Income' : 'Update Income'),
            ),
          ],
        ),
      ),
    );
  }
}

