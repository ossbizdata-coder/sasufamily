import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/insurance.dart';
import '../../data/services/api_service.dart';

class InsuranceFormScreen extends StatefulWidget {
  final Insurance? insurance;
  const InsuranceFormScreen({Key? key, this.insurance}) : super(key: key);

  @override
  State<InsuranceFormScreen> createState() => _InsuranceFormScreenState();
}

class _InsuranceFormScreenState extends State<InsuranceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _policyNameController;
  late TextEditingController _providerController;
  late TextEditingController _coverageAmountController;
  late TextEditingController _premiumAmountController;
  late TextEditingController _maturityYearController;
  late TextEditingController _maturityBenefitController;
  late TextEditingController _beneficiaryController;
  late TextEditingController _descriptionController;

  String _selectedType = 'LIFE';
  String _selectedPremiumFrequency = 'MONTHLY';
  DateTime? _startDate;
  bool _isLoading = false;

  final List<Map<String, String>> _insuranceTypes = [
    {'value': 'LIFE', 'label': 'Life Insurance'},
    {'value': 'MEDICAL', 'label': 'Medical Insurance'},
    {'value': 'EDUCATION', 'label': 'Education Insurance'},
    {'value': 'VEHICLE', 'label': 'Vehicle Insurance'},
    {'value': 'HOME', 'label': 'Home Insurance'},
    {'value': 'OTHER', 'label': 'Other'},
  ];

  final List<Map<String, String>> _premiumFrequencies = [
    {'value': 'MONTHLY', 'label': 'Monthly'},
    {'value': 'QUARTERLY', 'label': 'Quarterly'},
    {'value': 'HALF_YEARLY', 'label': 'Semi-Annual'},
    {'value': 'YEARLY', 'label': 'Annual'},
  ];

  @override
  void initState() {
    super.initState();
    _policyNameController = TextEditingController(text: widget.insurance?.policyName ?? '');
    _providerController = TextEditingController(text: widget.insurance?.provider ?? '');
    _coverageAmountController = TextEditingController(
      text: widget.insurance?.coverageAmount.toString() ?? '',
    );
    _premiumAmountController = TextEditingController(
      text: widget.insurance?.premiumAmount?.toString() ?? '',
    );
    _maturityYearController = TextEditingController(
      text: widget.insurance?.maturityYear?.toString() ?? '',
    );
    _maturityBenefitController = TextEditingController(
      text: widget.insurance?.maturityBenefit?.toString() ?? '',
    );
    _beneficiaryController = TextEditingController(
      text: widget.insurance?.beneficiary ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.insurance?.description ?? '',
    );

    if (widget.insurance != null) {
      _selectedType = widget.insurance!.type;
      if (widget.insurance!.premiumFrequency != null) {
        _selectedPremiumFrequency = widget.insurance!.premiumFrequency!;
      }
      if (widget.insurance!.startDate != null) {
        _startDate = DateTime.parse(widget.insurance!.startDate!);
      }
    }
  }

  @override
  void dispose() {
    _policyNameController.dispose();
    _providerController.dispose();
    _coverageAmountController.dispose();
    _premiumAmountController.dispose();
    _maturityYearController.dispose();
    _maturityBenefitController.dispose();
    _beneficiaryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  /// Parse a number string that may contain commas
  double? _parseNumber(String text) {
    if (text.isEmpty) return null;
    // Remove commas and spaces
    final cleanText = text.replaceAll(',', '').replaceAll(' ', '').trim();
    return double.tryParse(cleanText);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final insurance = Insurance(
        id: widget.insurance?.id,
        policyName: _policyNameController.text.trim(),
        type: _selectedType,
        provider: _providerController.text.trim(),
        coverageAmount: _parseNumber(_coverageAmountController.text) ?? 0,
        premiumAmount: _parseNumber(_premiumAmountController.text),
        premiumFrequency: _premiumAmountController.text.isNotEmpty
          ? _selectedPremiumFrequency
          : null,
        startDate: _startDate?.toIso8601String(),
        maturityYear: _maturityYearController.text.isNotEmpty
          ? int.tryParse(_maturityYearController.text.trim())
          : null,
        maturityBenefit: _parseNumber(_maturityBenefitController.text),
        beneficiary: _beneficiaryController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
        active: true,
      );

      if (widget.insurance == null) {
        await ApiService.createInsurance(insurance);
      } else {
        await ApiService.updateInsurance(widget.insurance!.id!, insurance);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.insurance == null
              ? 'Insurance added successfully'
              : 'Insurance updated successfully'),
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
        title: Text(widget.insurance == null ? 'Add Insurance' : 'Edit Insurance'),
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
                      labelText: 'Insurance Type',
                      border: OutlineInputBorder(),
                    ),
                    items: _insuranceTypes.map((type) {
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
                    controller: _policyNameController,
                    decoration: const InputDecoration(
                      labelText: 'Policy Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Enter policy name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _providerController,
                    decoration: const InputDecoration(
                      labelText: 'Provider',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Enter provider name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _coverageAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Coverage Amount',
                      border: OutlineInputBorder(),
                      prefixText: 'Rs. ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'Enter coverage amount' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _premiumAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Premium Amount (Optional)',
                      border: OutlineInputBorder(),
                      prefixText: 'Rs. ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedPremiumFrequency,
                    decoration: const InputDecoration(
                      labelText: 'Premium Frequency',
                      border: OutlineInputBorder(),
                    ),
                    items: _premiumFrequencies.map((freq) {
                      return DropdownMenuItem(
                        value: freq['value'],
                        child: Text(freq['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedPremiumFrequency = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(context),
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
                  TextFormField(
                    controller: _maturityYearController,
                    decoration: const InputDecoration(
                      labelText: 'Maturity Year (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _maturityBenefitController,
                    decoration: const InputDecoration(
                      labelText: 'Maturity Benefit (Optional)',
                      border: OutlineInputBorder(),
                      prefixText: 'Rs. ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _beneficiaryController,
                    decoration: const InputDecoration(
                      labelText: 'Beneficiary',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Enter beneficiary' : null,
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
                      widget.insurance == null ? 'Add Insurance' : 'Save Changes',
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

