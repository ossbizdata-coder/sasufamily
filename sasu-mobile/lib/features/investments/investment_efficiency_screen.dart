import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/asset.dart';
import '../../data/models/user.dart';
import '../../data/services/api_service.dart';
import '../../core/theme/app_theme.dart';

class InvestmentEfficiencyScreen extends StatefulWidget {
  final User user;

  const InvestmentEfficiencyScreen({Key? key, required this.user})
      : super(key: key);

  @override
  State<InvestmentEfficiencyScreen> createState() =>
      _InvestmentEfficiencyScreenState();
}

class _InvestmentEfficiencyScreenState
    extends State<InvestmentEfficiencyScreen> {
  List<Asset> _assets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    setState(() => _loading = true);
    final assets = await ApiService.getAssets();
    setState(() {
      _assets = assets;
      _loading = false;
    });
  }

  String _fmt(double v) =>
      NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0).format(v);

  // Use valueInLKR for consistent calculations (includes auto-growth and USD conversion)
  double get _totalAssets =>
      _assets.fold(0, (s, a) => s + a.valueInLKR);

  // Use isInvestment flag for investment assets
  double get _investedAssets => _assets
      .where((a) => a.isInvestment)
      .fold(0, (s, a) => s + a.valueInLKR);

  double get _efficiency =>
      _totalAssets == 0 ? 0 : (_investedAssets / _totalAssets) * 100;

  Color get _color {
    if (_efficiency >= 60) return Colors.green;
    if (_efficiency >= 40) return Colors.orange;
    return Colors.red;
  }

  String get _label {
    if (_efficiency >= 60) return 'Well Optimized';
    if (_efficiency >= 40) return 'Underutilized';
    return 'Inefficient';
  }

  @override
  Widget build(BuildContext context) {
    // Use isInvestment flag for filtering
    final investmentAssets = _assets
        .where((a) => a.isInvestment)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Investment Efficiency',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAssets),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  /// ===== HEADER =====
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Capital Efficiency',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_efficiency.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _label,
                            style: TextStyle(
                              color: _color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// ===== SUMMARY =====
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _metric('Total Assets', _fmt(_totalAssets),
                            Icons.account_balance, count: _assets.length),
                        _metric('Invested Capital', _fmt(_investedAssets),
                            Icons.trending_up, count: _assets.where((a) => a.isInvestment).length, highlight: true),
                        _metric(
                          'Idle Capital',
                          _fmt(_totalAssets - _investedAssets),
                          Icons.pause_circle,
                          count: _assets.where((a) => !a.isInvestment).length,
                        ),
                      ],
                    ),
                  ),

                  /// ===== INVESTMENT LIST =====
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Investment Assets',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${investmentAssets.length} items',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Investment assets list (no longer in Expanded)
                  if (investmentAssets.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.show_chart,
                              size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No investments yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _showAddDialog(),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Investment'),
                          ),
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      child: Column(
                        children: investmentAssets
                            .map((asset) => _buildInvestmentCard(asset))
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _metric(String title, String value, IconData icon, {int? count, bool highlight = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFF6A1B9A).withAlpha(10) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: highlight ? Border.all(color: const Color(0xFF6A1B9A).withAlpha(50), width: 2) : null,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: highlight ? const Color(0xFF6A1B9A) : AppTheme.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title,
                        style:
                            TextStyle(fontSize: 13, color: AppTheme.textMedium)),
                    if (count != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: highlight ? const Color(0xFF6A1B9A).withAlpha(30) : AppTheme.primaryBlue.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count items',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: highlight ? const Color(0xFF6A1B9A) : AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(value,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: highlight ? const Color(0xFF6A1B9A) : Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentCard(Asset asset) {
    final growthRate = asset.yearlyGrowthRate ?? 0;
    final purchaseValue = asset.purchaseValue ?? asset.currentValue;
    final currentVal = asset.calculatedCurrentValue;
    final gain = currentVal - purchaseValue;
    final gainPercent =
        purchaseValue > 0 ? (gain / purchaseValue * 100) : 0;

    return InkWell(
      onTap: () => _editAsset(asset),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF6A1B9A).withAlpha(76),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6A1B9A).withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 4),
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
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6A1B9A).withAlpha(38),
                          const Color(0xFF6A1B9A).withAlpha(13),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF6A1B9A).withAlpha(76),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _getAssetIcon(asset.type),
                      color: const Color(0xFF6A1B9A),
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getAssetTypeLabel(asset.type),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editAsset(asset);
                      } else if (value == 'delete') {
                        _confirmDelete(asset);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Value',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _fmt(currentVal),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6A1B9A),
                              ),
                            ),
                          ],
                        ),
                        if (gain != 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: gain > 0
                                  ? Colors.green.withAlpha(25)
                                  : Colors.red.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  gain > 0
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  size: 14,
                                  color: gain > 0 ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${gainPercent.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        gain > 0 ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    if (asset.purchaseYear != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            'Since ${asset.purchaseYear}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (growthRate > 0) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.show_chart,
                                size: 12, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              '${growthRate.toStringAsFixed(1)}% growth/yr',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getAssetIcon(String type) {
    switch (type) {
      case 'SHARES':
        return Icons.candlestick_chart;
      case 'RETIREMENT_FUND':
        return Icons.savings;
      case 'EPF':
        return Icons.account_balance_wallet;
      case 'GOLD':
        return Icons.diamond;
      default:
        return Icons.show_chart;
    }
  }

  String _getAssetTypeLabel(String type) {
    switch (type) {
      case 'SHARES':
        return 'Shares/Stocks';
      case 'RETIREMENT_FUND':
        return 'Retirement Fund';
      case 'EPF':
        return 'EPF';
      case 'GOLD':
        return 'Gold';
      default:
        return type;
    }
  }

  void _showAddDialog() {
    Navigator.pushNamed(
      context,
      '/assetForm',
      arguments: {
        'type': 'SHARES', // Default to shares for investments
      },
    ).then((_) => _loadAssets());
  }

  void _editAsset(Asset asset) {
    Navigator.pushNamed(
      context,
      '/assetForm',
      arguments: asset.toJson(),
    ).then((_) => _loadAssets());
  }

  void _confirmDelete(Asset asset) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Investment'),
        content: Text('Delete "${asset.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteAsset(asset.id!);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAsset(int id) async {
    try {
      await ApiService.deleteAsset(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Investment deleted')),
      );
      _loadAssets();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
