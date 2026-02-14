import 'package:flutter/material.dart';
import '../../data/models/asset.dart';
import '../../data/services/api_service.dart';

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
  int? _editingId;
  bool _isLiquid = false;
  bool _isInvestment = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.asset?['name'] ?? widget.asset?['name'] ?? '');
    _valueController = TextEditingController(text: widget.asset?['currentValue']?.toString() ?? widget.asset?['value']?.toString() ?? '');
    _typeController = TextEditingController(text: widget.asset?['type'] ?? '');
    _purchaseYearController = TextEditingController(text: widget.asset?['purchaseYear']?.toString() ?? '');
    _editingId = widget.asset?['id'];
    _isLiquid = widget.asset?['isLiquid'] ?? false;
    _isInvestment = widget.asset?['isInvestment'] ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _typeController.dispose();
    _purchaseYearController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final asset = Asset(
        id: _editingId,
        name: _nameController.text,
        type: _typeController.text,
        currentValue: double.tryParse(_valueController.text) ?? 0,
        purchaseYear: int.tryParse(_purchaseYearController.text),
        active: true,
        isLiquid: _isLiquid,
        isInvestment: _isInvestment,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Asset Name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter asset name' : null,
              ),
              DropdownButtonFormField<String>(
                value: _typeController.text.isNotEmpty ? _typeController.text : null,
                decoration: const InputDecoration(labelText: 'Type'),
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
                  child: Text(type.replaceAll('_', ' ').toUpperCase()),
                )).toList(),
                onChanged: (val) {
                  _typeController.text = val ?? '';
                },
                validator: (v) => v == null || v.isEmpty ? 'Select asset type' : null,
              ),
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(labelText: 'Value'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Enter value' : null,
              ),
              TextFormField(
                controller: _purchaseYearController,
                decoration: const InputDecoration(labelText: 'Purchase Year'),
                keyboardType: TextInputType.number,
              ),
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
                child: Text(_editingId == null ? 'Add Asset' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
