/// Liquidity & Emergency Fund Screen
///
/// Shows only LIQUID assets (cash, savings, short-term deposits)
/// These can be converted to cash within 3-6 months
///
/// Purpose:
/// - Monitor emergency fund readiness
/// - See accessible cash reserves
/// - Manage liquid assets separately from long-term investments

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/asset.dart';
import '../../data/models/user.dart';
import '../../data/services/api_service.dart';

class LiquidityScreen extends StatefulWidget {
  final User user;

  const LiquidityScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<LiquidityScreen> createState() => _LiquidityScreenState();
}

class _LiquidityScreenState extends State<LiquidityScreen> {
  List<Asset> _liquidAssets = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLiquidAssets();
  }

  Future<void> _loadLiquidAssets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final allAssets = await ApiService.getAssets();
      // Filter only liquid assets
      final liquidAssets = allAssets.where((a) => a.isLiquid).toList();

      setState(() {
        _liquidAssets = liquidAssets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);
    return formatter.format(amount);
  }

  double get _totalLiquidAssets {
    return _liquidAssets.fold(0.0, (sum, asset) => sum + asset.valueInLKR);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Liquidity & Emergency Fund',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF00838F), // Teal
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadLiquidAssets,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddLiquidAssetDialog(),
            tooltip: 'Add Liquid Asset',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadLiquidAssets,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLiquidAssets,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCard(),
                        const SizedBox(height: 16),
                        _buildInfoBanner(),
                        const SizedBox(height: 16),
                        _buildAssetsList(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00838F), Color(0xFF00ACC1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00838F).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.water_drop, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  'Total Liquid Assets',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _formatCurrency(_totalLiquidAssets),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_liquidAssets.length} liquid asset(s)',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Liquid assets can be converted to cash within 3-6 months. Includes: Cash, Savings, Short-term Deposits.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade900,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsList() {
    if (_liquidAssets.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(Icons.water_drop_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No liquid assets yet',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Add cash, savings, or short-term deposits',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Liquid Assets',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
        ),
        const SizedBox(height: 12),
        ..._liquidAssets.map((asset) => _buildAssetCard(asset)),
      ],
    );
  }

  Widget _buildAssetCard(Asset asset) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00838F).withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00838F).withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00838F).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getAssetIcon(asset.type),
                    color: const Color(0xFF00838F),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatAssetType(asset.type),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatCurrency(asset.valueInLKR),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00838F),
                  ),
                ),
                if (widget.user.role == 'ADMIN' || widget.user.role == 'SUPERADMIN')
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editAsset(asset);
                      } else if (value == 'delete') {
                        _deleteAsset(asset);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20, color: Colors.blue),
                            SizedBox(width: 12),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (asset.description != null && asset.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  asset.description!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getAssetIcon(String type) {
    switch (type) {
      case 'CASH':
        return Icons.payments;
      case 'BANK_DEPOSIT':
      case 'SAVINGS':
        return Icons.account_balance;
      case 'FIXED_DEPOSIT':
        return Icons.savings;
      default:
        return Icons.attach_money;
    }
  }

  String _formatAssetType(String type) {
    return type.replaceAll('_', ' ').toLowerCase().split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  void _showAddLiquidAssetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Liquid Asset'),
        content: const Text(
          'To add a liquid asset:\n\n'
          '1. Go to Assets screen\n'
          '2. Add a new asset (Cash, Bank Deposit, or Savings)\n'
          '3. Mark it as "Liquid" using the checkbox\n\n'
          'It will automatically appear here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _editAsset(Asset asset) {
    final nameController = TextEditingController(text: asset.name);
    final valueController = TextEditingController(text: asset.currentValue.toString());
    final descController = TextEditingController(text: asset.description ?? '');
    final purchaseValueController = TextEditingController(
      text: asset.purchaseValue?.toString() ?? '',
    );
    final purchaseYearController = TextEditingController(
      text: asset.purchaseYear?.toString() ?? '',
    );
    final growthRateController = TextEditingController(
      text: asset.yearlyGrowthRate?.toString() ?? '',
    );
    String selectedType = asset.type;
    bool isLiquid = asset.isLiquid;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Liquid Asset'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Asset Name'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Asset Type'),
                  items: const [
                    DropdownMenuItem(value: 'CASH', child: Text('Cash')),
                    DropdownMenuItem(value: 'BANK_DEPOSIT', child: Text('Bank Deposit')),
                    DropdownMenuItem(value: 'SAVINGS', child: Text('Savings Account')),
                    DropdownMenuItem(value: 'FIXED_DEPOSIT', child: Text('Fixed Deposit')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valueController,
                  decoration: const InputDecoration(labelText: 'Current Value'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: purchaseValueController,
                  decoration: const InputDecoration(labelText: 'Purchase Value (Optional)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: purchaseYearController,
                  decoration: const InputDecoration(labelText: 'Purchase Year (Optional)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: growthRateController,
                  decoration: const InputDecoration(labelText: 'Yearly Growth Rate % (Optional)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description (Optional)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Liquid Asset'),
                  subtitle: const Text('Can be converted to cash within 3-6 months'),
                  value: isLiquid,
                  onChanged: (value) {
                    setDialogState(() => isLiquid = value ?? false);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final valueText = valueController.text.trim();

                if (name.isEmpty || valueText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                final value = double.tryParse(valueText);
                if (value == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid value')),
                  );
                  return;
                }

                try {
                  final updatedAsset = Asset(
                    id: asset.id,
                    name: name,
                    type: selectedType,
                    currentValue: value,
                    purchaseValue: purchaseValueController.text.trim().isEmpty
                        ? null
                        : double.tryParse(purchaseValueController.text.trim()),
                    purchaseYear: purchaseYearController.text.trim().isEmpty
                        ? null
                        : int.tryParse(purchaseYearController.text.trim()),
                    yearlyGrowthRate: growthRateController.text.trim().isEmpty
                        ? null
                        : double.tryParse(growthRateController.text.trim()),
                    description: descController.text.trim().isEmpty
                        ? null
                        : descController.text.trim(),
                    isLiquid: isLiquid,
                    active: asset.active,
                    lastUpdated: asset.lastUpdated,
                  );

                  await ApiService.updateAsset(asset.id!, updatedAsset);
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Asset updated successfully')),
                  );
                  _loadLiquidAssets();
                } catch (e) {
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteAsset(Asset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Asset'),
        content: Text('Are you sure you want to delete "${asset.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await ApiService.deleteAsset(asset.id!);
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Asset deleted successfully')),
                );
                _loadLiquidAssets();
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

