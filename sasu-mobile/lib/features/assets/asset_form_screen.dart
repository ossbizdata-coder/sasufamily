import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/asset.dart';
import '../../data/services/api_service.dart';
import '../../core/utils/value_calculator.dart';

class AssetFormScreen extends StatefulWidget {
  final Map<String, dynamic>? asset;
  const AssetFormScreen({Key? key, this.asset}) : super(key: key);

  @override
  State<AssetFormScreen> createState() => _AssetFormScreenState();
}

class _AssetFormScreenState extends State<AssetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _valueController;
  late TextEditingController _typeController;
  late TextEditingController _purchaseYearController;
  late TextEditingController _growthRateController;
  int? _editingId;
  bool _isLiquid = false;
  bool _isInvestment = false;
  bool _autoGrowth = false;
  DateTime? _purchaseDate;
  String _currency = 'LKR';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.asset?['name'] ?? '');
    _valueController = TextEditingController(text: widget.asset?['currentValue']?.toString() ?? widget.asset?['value']?.toString() ?? '');
    _typeController = TextEditingController(text: widget.asset?['type'] ?? '');
    _purchaseYearController = TextEditingController(text: widget.asset?['purchaseYear']?.toString() ?? '');
    _growthRateController = TextEditingController(text: widget.asset?['yearlyGrowthRate']?.toString() ?? '');
    _editingId = widget.asset?['id'];
    _isLiquid = widget.asset?['isLiquid'] ?? false;
    _isInvestment = widget.asset?['isInvestment'] ?? false;
    _autoGrowth = widget.asset?['autoGrowth'] ?? false;
    _currency = widget.asset?['currency'] ?? 'LKR';

    // Parse purchase date if available
    if (widget.asset?['purchaseDate'] != null) {
      try {
        _purchaseDate = DateTime.parse(widget.asset!['purchaseDate']);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _typeController.dispose();
    _purchaseYearController.dispose();
    _growthRateController.dispose();
    super.dispose();
  }

  Future<void> _selectPurchaseDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _purchaseDate = picked;
        _purchaseYearController.text = picked.year.toString();
      });
    }
  }

  void _updateDefaultGrowthRate() {
    if (_typeController.text.isNotEmpty && _growthRateController.text.isEmpty) {
      final defaultRate = ValueCalculator.getDefaultGrowthRate(_typeController.text);
      if (defaultRate != 0) {
        _growthRateController.text = defaultRate.toString();
      }
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

  // Calculate and show projected value
  Widget _buildProjectionPreview() {
    if (!_autoGrowth || _purchaseDate == null) {
      return const SizedBox.shrink();
    }

    final value = _parseNumber(_valueController.text) ?? 0;
    final rate = _parseNumber(_growthRateController.text) ?? 0;

    if (value <= 0 || rate == 0) {
      return const SizedBox.shrink();
    }

    final currentValue = ValueCalculator.calculateCompoundGrowth(
      principalValue: value,
      yearlyGrowthRate: rate,
      startDate: _purchaseDate!,
    );

    final gain = currentValue - value;
    final gainPercent = (gain / value) * 100;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.green[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Auto-Growth Preview',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Purchase Value:'),
              Text(_formatCurrency(value), style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Current Value (Today):'),
              Text(
                _formatCurrency(currentValue),
                style: TextStyle(fontWeight: FontWeight.w700, color: Colors.green[700]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Gain:'),
              Text(
                '+${_formatCurrency(gain)} (+${gainPercent.toStringAsFixed(1)}%)',
                style: TextStyle(color: Colors.green[600], fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Divider(height: 16),
          Text(
            '📈 Value updates automatically every day based on ${rate.toStringAsFixed(1)}% annual growth',
            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final asset = Asset(
        id: _editingId,
        name: _nameController.text,
        type: _typeController.text,
        currentValue: _parseNumber(_valueController.text) ?? 0,
        purchaseValue: _parseNumber(_valueController.text),
        purchaseYear: int.tryParse(_purchaseYearController.text),
        purchaseDate: _purchaseDate?.toIso8601String(),
        yearlyGrowthRate: _parseNumber(_growthRateController.text),
        active: true,
        isLiquid: _isLiquid,
        isInvestment: _isInvestment,
        autoGrowth: _autoGrowth,
        currency: _currency,
      );
      try {
        if (_editingId == null) {
          await ApiService.createAsset(asset);
        } else {
          await ApiService.updateAsset(_editingId!, asset);
        }
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save asset: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editingId == null ? 'Add Asset' : 'Edit Asset')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Asset Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter asset name' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _typeController.text.isNotEmpty ? _typeController.text : null,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'LAND',
                  'HOUSE',
                  'VEHICLE',
                  'FIXED_DEPOSIT',
                  'SAVINGS',
                  'SHARES',
                  'EPF',
                  'RETIREMENT_FUND',
                  'GOLD',
                  'CASH',
                  'BANK_DEPOSIT',
                  'INSURANCE_INVESTMENT',
                  'OTHER',
                ].map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.replaceAll('_', ' ')),
                )).toList(),
                onChanged: (val) {
                  setState(() {
                    _typeController.text = val ?? '';
                    _updateDefaultGrowthRate();
                  });
                },
                validator: (v) => v == null || v.isEmpty ? 'Select asset type' : null,
              ),
              const SizedBox(height: 16),

              // Currency selector and Value input
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Currency dropdown
                  SizedBox(
                    width: 100,
                    child: DropdownButtonFormField<String>(
                      value: _currency,
                      decoration: const InputDecoration(
                        labelText: 'Currency',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'LKR',
                          child: Text('Rs.', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        DropdownMenuItem(
                          value: 'USD',
                          child: Text('USD', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.amber.shade800)),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _currency = val ?? 'LKR';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Value input
                  Expanded(
                    child: TextFormField(
                      controller: _valueController,
                      decoration: InputDecoration(
                        labelText: 'Purchase/Initial Value',
                        border: const OutlineInputBorder(),
                        prefixText: _currency == 'USD' ? 'USD ' : 'Rs. ',
                        helperText: _currency == 'USD'
                          ? 'Value in USD (will show LKR equivalent)'
                          : 'Enter the value when you purchased/started this asset',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Enter value' : null,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Purchase Date Picker
              InkWell(
                onTap: _selectPurchaseDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Purchase Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _purchaseDate != null
                      ? DateFormat('yyyy-MM-dd').format(_purchaseDate!)
                      : 'Select date for auto-growth calculation',
                    style: TextStyle(
                      color: _purchaseDate != null ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Auto-Growth Toggle
              Container(
                decoration: BoxDecoration(
                  color: _autoGrowth ? Colors.green.withAlpha(15) : Colors.grey.withAlpha(10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _autoGrowth ? Colors.green.withAlpha(50) : Colors.grey.withAlpha(30),
                  ),
                ),
                child: SwitchListTile(
                  title: Row(
                    children: [
                      Icon(
                        Icons.auto_graph,
                        color: _autoGrowth ? Colors.green[700] : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text('Enable Auto-Growth'),
                    ],
                  ),
                  subtitle: Text(
                    _autoGrowth
                      ? 'Value will automatically increase based on growth rate'
                      : 'Value stays fixed unless manually updated',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  value: _autoGrowth,
                  onChanged: (value) {
                    setState(() {
                      _autoGrowth = value;
                      if (value) {
                        _isInvestment = true; // Auto-growth assets are investments
                        _updateDefaultGrowthRate();
                      }
                    });
                  },
                  activeColor: Colors.green,
                ),
              ),

              // Growth Rate (shown when auto-growth is enabled)
              if (_autoGrowth) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _growthRateController,
                  decoration: InputDecoration(
                    labelText: 'Yearly Growth Rate (%)',
                    border: const OutlineInputBorder(),
                    suffixText: '% per year',
                    helperText: _typeController.text.isNotEmpty
                      ? 'Default for ${_typeController.text}: ${ValueCalculator.getDefaultGrowthRate(_typeController.text)}%'
                      : 'e.g., 11 for EPF, 8 for Land',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                ),

                // Projection Preview
                _buildProjectionPreview(),
              ],

              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Liquid Asset'),
                subtitle: const Text('Can be converted to cash quickly (3-6 months)'),
                value: _isLiquid,
                onChanged: (value) {
                  setState(() {
                    _isLiquid = value ?? false;
                  });
                },
                activeColor: Colors.green,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                title: const Text('Investment Asset'),
                subtitle: const Text('Generates returns or appreciates in value'),
                value: _isInvestment,
                onChanged: (value) {
                  setState(() {
                    _isInvestment = value ?? false;
                  });
                },
                activeColor: Colors.purple,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _editingId == null ? 'Add Asset' : 'Save Changes',
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
