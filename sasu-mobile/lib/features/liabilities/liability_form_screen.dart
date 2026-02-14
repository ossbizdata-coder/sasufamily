import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/liability.dart';
import '../../data/services/api_service.dart';

class LiabilityFormScreen extends StatefulWidget {
  final Liability? liability;
  const LiabilityFormScreen({Key? key, this.liability}) : super(key: key);

  @override
  State<LiabilityFormScreen> createState() => _LiabilityFormScreenState();
}

class _LiabilityFormScreenState extends State<LiabilityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _originalAmountController;
  late TextEditingController _remainingAmountController;
  late TextEditingController _monthlyPaymentController;
  late TextEditingController _interestRateController;
  late TextEditingController _descriptionController;

  String _selectedType = 'PERSONAL_LOAN';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  final List<Map<String, String>> _liabilityTypes = [
    {'value': 'HOME_LOAN', 'label': 'Home Loan'},
    {'value': 'VEHICLE_LOAN', 'label': 'Vehicle Loan'},
    {'value': 'PERSONAL_LOAN', 'label': 'Personal Loan'},
    {'value': 'EDUCATION_LOAN', 'label': 'Education Loan'},
    {'value': 'CREDIT_CARD', 'label': 'Credit Card'},
    {'value': 'OTHER', 'label': 'Other'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.liability?.name ?? '');
    _originalAmountController = TextEditingController(
      text: widget.liability?.originalAmount.toString() ?? '',
    );
    _remainingAmountController = TextEditingController(
      text: widget.liability?.remainingAmount.toString() ?? '',
    );
    _monthlyPaymentController = TextEditingController(
      text: widget.liability?.monthlyPayment?.toString() ?? '',
    );
    _interestRateController = TextEditingController(
      text: widget.liability?.interestRate?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.liability?.description ?? '',
    );

    if (widget.liability != null) {
      _selectedType = widget.liability!.type;
      if (widget.liability!.startDate != null) {
        _startDate = DateTime.parse(widget.liability!.startDate!);
      }
      if (widget.liability!.endDate != null) {
        _endDate = DateTime.parse(widget.liability!.endDate!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _originalAmountController.dispose();
    _remainingAmountController.dispose();
    _monthlyPaymentController.dispose();
    _interestRateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStartDate ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final liability = Liability(
        id: widget.liability?.id,
        name: _nameController.text.trim(),
        type: _selectedType,
        originalAmount: double.parse(_originalAmountController.text.trim()),
        remainingAmount: double.parse(_remainingAmountController.text.trim()),
        monthlyPayment: _monthlyPaymentController.text.isNotEmpty
          ? double.parse(_monthlyPaymentController.text.trim())
          : null,
        interestRate: _interestRateController.text.isNotEmpty
          ? double.parse(_interestRateController.text.trim())
          : null,
        startDate: _startDate?.toIso8601String(),
        endDate: _endDate?.toIso8601String(),
        description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
        active: true,
      );

      if (widget.liability == null) {
        await ApiService.createLiability(liability);
      } else {
        await ApiService.updateLiability(widget.liability!.id!, liability);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.liability == null
              ? 'Liability added successfully'
              : 'Liability updated successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.liability == null ? 'Add Liability' : 'Edit Liability'),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Liability Type',
                      border: OutlineInputBorder(),
                    ),
                    items: _liabilityTypes.map((type) {
                      return DropdownMenuItem(
                        value: type['value'],
                        child: Text(type['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedType = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Liability Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Enter liability name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _originalAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Original Amount',
                      border: OutlineInputBorder(),
                      prefixText: 'Rs. ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'Enter original amount' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _remainingAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Remaining Amount',
                      border: OutlineInputBorder(),
                      prefixText: 'Rs. ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'Enter remaining amount' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _monthlyPaymentController,
                    decoration: const InputDecoration(
                      labelText: 'Monthly Payment (Optional)',
                      border: OutlineInputBorder(),
                      prefixText: 'Rs. ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _interestRateController,
                    decoration: const InputDecoration(
                      labelText: 'Interest Rate % (Optional)',
                      border: OutlineInputBorder(),
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(context, true),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_startDate == null
                            ? 'Start Date (Optional)'
                            : DateFormat('dd/MM/yyyy').format(_startDate!)),
                        ),
                      ),
                      if (_startDate != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _startDate = null),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(context, false),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_endDate == null
                            ? 'End Date (Optional)'
                            : DateFormat('dd/MM/yyyy').format(_endDate!)),
                        ),
                      ),
                      if (_endDate != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _endDate = null),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: Text(
                      widget.liability == null ? 'Add Liability' : 'Save Changes',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

