import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/asset.dart';
import '../../data/models/expense.dart';
import '../../data/models/user.dart';
import '../../data/services/api_service.dart';

class LiquidityEmergencyScreen extends StatefulWidget {
  final User user;

  const LiquidityEmergencyScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<LiquidityEmergencyScreen> createState() =>
      _LiquidityEmergencyScreenState();
}

class _LiquidityEmergencyScreenState extends State<LiquidityEmergencyScreen> {
  List<Asset> _assets = [];
  List<Expense> _expenses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final assets = await ApiService.getAssets();
      final expenses = await ApiService.getExpenses();
      setState(() {
        _assets = assets;
        _expenses = expenses;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  String _fmt(double v) =>
      NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0).format(v);

  /// Liquid assets only
  List<Asset> get _liquidAssets => _assets
      .where((a) => a.isLiquid)
      .toList();

  double get _totalLiquidAssets =>
      _liquidAssets.fold(0, (s, a) => s + a.currentValue);

  double get _monthlyExpenses => _expenses
      .where((e) => e.active)
      .fold(0, (s, e) => s + e.getMonthlyAmount());

  double get _monthsCovered =>
      _monthlyExpenses == 0 ? 0 : _totalLiquidAssets / _monthlyExpenses;


  String get _statusText {
    if (_monthsCovered >= 6) return 'Excellent';
    if (_monthsCovered >= 3) return 'Fair';
    return 'Critical';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Liquidity & Emergency Fund',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddEditDialog(),
            tooltip: 'Add Liquid Asset',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 24),
                  _buildMetricsSection(),
                  const SizedBox(height: 24),
                  _buildLiquidAssetsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF00838F), const Color(0xFF00ACC1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00838F).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                'Emergency Coverage',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${_monthsCovered.toStringAsFixed(1)} months',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              _statusText,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Metrics',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          'Total Liquid Assets',
          _fmt(_totalLiquidAssets),
          Icons.account_balance_wallet,
          Colors.blue.shade700,
        ),
        const SizedBox(height: 10),
        _buildMetricCard(
          'Monthly Expenses',
          _fmt(_monthlyExpenses),
          Icons.trending_down,
          Colors.orange.shade700,
        ),
        const SizedBox(height: 10),
        _buildMetricCard(
          'Recommended Minimum (6 months)',
          _fmt(_monthlyExpenses * 6),
          Icons.security,
          Colors.green.shade700,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidAssetsList() {
    if (_liquidAssets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.water_drop_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No liquid assets yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add cash, bank savings, or fixed deposits',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddEditDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Liquid Asset'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00838F),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Liquid Assets (${_liquidAssets.length})',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        ..._liquidAssets.map((asset) => _buildAssetCard(asset)).toList(),
      ],
    );
  }

  Widget _buildAssetCard(Asset asset) {
    IconData icon;
    Color color;
    String typeLabel;

    switch (asset.type) {
      case 'CASH':
        icon = Icons.money;
        color = Colors.green.shade700;
        typeLabel = 'Cash';
        break;
      case 'SAVINGS':
        icon = Icons.savings;
        color = Colors.blue.shade700;
        typeLabel = 'Savings Account';
        break;
      case 'FIXED_DEPOSIT':
        icon = Icons.account_balance;
        color = Colors.purple.shade700;
        typeLabel = 'Fixed Deposit';
        break;
      case 'BANK_DEPOSIT':
        icon = Icons.account_balance;
        color = Colors.indigo.shade700;
        typeLabel = 'Bank Deposit';
        break;
      case 'GOLD':
        icon = Icons.emoji_events;
        color = Colors.amber.shade700;
        typeLabel = 'Gold';
        break;
      default:
        icon = Icons.account_balance_wallet;
        color = Colors.grey.shade700;
        typeLabel = asset.type.replaceAll('_', ' ');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    typeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _fmt(asset.currentValue),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  _showAddEditDialog(asset: asset);
                } else if (value == 'delete') {
                  _confirmDelete(asset);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditDialog({Asset? asset}) {
    final isEdit = asset != null;
    final nameController = TextEditingController(text: asset?.name ?? '');
    final valueController = TextEditingController(
        text: asset?.currentValue.toString() ?? '');
    String selectedType = asset?.type ?? 'CASH';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Liquid Asset' : 'Add Liquid Asset'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'CASH', child: Text('Cash')),
                    DropdownMenuItem(
                        value: 'SAVINGS', child: Text('Savings Account')),
                    DropdownMenuItem(
                        value: 'BANK_DEPOSIT', child: Text('Bank Deposit')),
                    DropdownMenuItem(
                        value: 'FIXED_DEPOSIT', child: Text('Fixed Deposit')),
                    DropdownMenuItem(value: 'GOLD', child: Text('Gold')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: valueController,
                  decoration: const InputDecoration(
                    labelText: 'Current Value (Rs.)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
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
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                final value = double.tryParse(valueText);
                if (value == null || value <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid value')),
                  );
                  return;
                }

                Navigator.pop(context);

                try {
                  if (isEdit) {
                    if (asset.id == null) {
                      throw Exception('Asset ID is null');
                    }
                    final updatedAsset = Asset(
                      id: asset.id,
                      name: name,
                      type: selectedType,
                      currentValue: value,
                      purchaseValue: asset.purchaseValue,
                      purchaseYear: asset.purchaseYear,
                      description: asset.description,
                      yearlyGrowthRate: asset.yearlyGrowthRate,
                      lastUpdated: asset.lastUpdated,
                      active: asset.active,
                      isLiquid: true,
                    );
                    await ApiService.updateAsset(asset.id!, updatedAsset);
                  } else {
                    final newAsset = Asset(
                      name: name,
                      type: selectedType,
                      currentValue: value,
                      purchaseValue: value,
                      active: true,
                      isLiquid: true,
                    );
                    await ApiService.createAsset(newAsset);
                  }
                  await _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(isEdit
                              ? 'Asset updated successfully'
                              : 'Asset added successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Asset asset) {
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                if (asset.id == null) {
                  throw Exception('Asset ID is null');
                }
                await ApiService.deleteAsset(asset.id!);
                await _loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Asset deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}


