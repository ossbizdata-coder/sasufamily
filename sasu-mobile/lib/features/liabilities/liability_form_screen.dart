import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/liability.dart';
import '../../data/services/api_service.dart';
import '../../core/utils/value_calculator.dart';

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
  bool _autoCalculate = false;

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
    _autoCalculate = widget.liability?.autoCalculate ?? false;

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

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);
    return formatter.format(amount);
  }

  /// Parse a number string that may contain commas
  double? _parseNumber(String text) {
    if (text.isEmpty) return null;
    // Remove commas and spaces
    final cleanText = text.replaceAll(',', '').replaceAll(' ', '').trim();
    return double.tryParse(cleanText);
  }

  // Build auto-calculate preview
  Widget _buildAutoCalculatePreview() {
    if (!_autoCalculate || _startDate == null) {
      return const SizedBox.shrink();
    }

    final originalAmount = _parseNumber(_originalAmountController.text) ?? 0;
    final monthlyPayment = _parseNumber(_monthlyPaymentController.text) ?? 0;
    final interestRate = _parseNumber(_interestRateController.text) ?? 0;

    if (originalAmount <= 0 || monthlyPayment <= 0) {
      return const SizedBox.shrink();
    }

    final status = ValueCalculator.calculateLiabilityStatus(
      originalAmount: originalAmount,
      interestRate: interestRate,
      monthlyPayment: monthlyPayment,
      startDate: _startDate!,
    );

    final progress = status.progressPercent(originalAmount);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate, color: Colors.orange[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Auto-Calculate Preview',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                status.isFullyPaid ? Colors.green : Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% paid off',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Original Amount:'),
              Text(_formatCurrency(originalAmount)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Remaining (Today):'),
              Text(
                _formatCurrency(status.remainingAmount),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: status.isFullyPaid ? Colors.green[700] : Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Paid:'),
              Text(
                _formatCurrency(status.totalPaid),
                style: const TextStyle(color: Colors.green),
              ),
            ],
          ),
          if (status.totalInterestPaid > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Interest Paid:'),
                Text(
                  _formatCurrency(status.totalInterestPaid),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Time Remaining:'),
              Text(
                status.remainingTimeFormatted,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: status.isFullyPaid ? Colors.green : Colors.orange[700],
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Text(
            '📊 Balance updates automatically based on monthly payments since ${DateFormat('MMM yyyy').format(_startDate!)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final liability = Liability(
        id: widget.liability?.id,
        name: _nameController.text.trim(),
        type: _selectedType,
        originalAmount: _parseNumber(_originalAmountController.text) ?? 0,
        remainingAmount: _parseNumber(_remainingAmountController.text) ?? 0,
        monthlyPayment: _parseNumber(_monthlyPaymentController.text),
        interestRate: _parseNumber(_interestRateController.text),
        startDate: _startDate?.toIso8601String(),
        endDate: _endDate?.toIso8601String(),
        description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
        active: true,
        autoCalculate: _autoCalculate,
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
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  // Remaining Amount - conditional based on auto-calculate
                  if (!_autoCalculate)
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

                  if (_autoCalculate)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withAlpha(40)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Remaining amount will be calculated automatically based on payments made since start date',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _monthlyPaymentController,
                    decoration: InputDecoration(
                      labelText: _autoCalculate ? 'Monthly Payment (Required)' : 'Monthly Payment (Optional)',
                      border: const OutlineInputBorder(),
                      prefixText: 'Rs. ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _autoCalculate
                      ? (v) => v == null || v.isEmpty ? 'Enter monthly payment for auto-calculate' : null
                      : null,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _interestRateController,
                    decoration: const InputDecoration(
                      labelText: 'Interest Rate % (Optional)',
                      border: OutlineInputBorder(),
                      suffixText: '%',
                      helperText: 'Annual interest rate for accurate calculations',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(context, true),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_startDate == null
                            ? _autoCalculate ? 'Start Date (Required)' : 'Start Date (Optional)'
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

                  // Auto-Calculate Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: _autoCalculate ? Colors.orange.withAlpha(15) : Colors.grey.withAlpha(10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _autoCalculate ? Colors.orange.withAlpha(50) : Colors.grey.withAlpha(30),
                      ),
                    ),
                    child: SwitchListTile(
                      title: Row(
                        children: [
                          Icon(
                            Icons.calculate,
                            color: _autoCalculate ? Colors.orange[700] : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text('Enable Auto-Calculate'),
                        ],
                      ),
                      subtitle: Text(
                        _autoCalculate
                          ? 'Balance automatically tracks payments since start date'
                          : 'Remaining amount is updated manually',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      value: _autoCalculate,
                      onChanged: (value) {
                        setState(() {
                          _autoCalculate = value;
                          if (value && _remainingAmountController.text.isEmpty) {
                            _remainingAmountController.text = _originalAmountController.text;
                          }
                        });
                      },
                      activeColor: Colors.orange,
                    ),
                  ),

                  // Auto-Calculate Preview
                  _buildAutoCalculatePreview(),

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
