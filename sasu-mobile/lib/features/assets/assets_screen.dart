import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/asset.dart';
import '../../data/models/user.dart';
import '../../data/services/api_service.dart';
import '../../core/theme/app_theme.dart';

class AssetsScreen extends StatefulWidget {
  final User user;

  const AssetsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  List<Asset> _assets = [];
  bool _isLoading = true;
  String? _error;
  final Map<String, bool> _expandedGroups = {};

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final assets = await ApiService.getAssets();
      setState(() {
        _assets = assets;
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

  double get _totalAssets {
    return _assets.fold(0, (sum, asset) => sum + asset.currentValue);
  }

  IconData _getAssetIcon(String type) {
    switch (type) {
      case 'LAND':
        return Icons.landscape;
      case 'HOUSE':
        return Icons.home;
      case 'VEHICLE':
        return Icons.directions_car;
      case 'FIXED_DEPOSIT':
      case 'SAVINGS':
        return Icons.savings;
      case 'SHARES':
        return Icons.show_chart;
      case 'EPF':
      case 'RETIREMENT_FUND':
        return Icons.account_balance;
      case 'GOLD':
        return Icons.diamond;
      default:
        return Icons.account_balance_wallet;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assets',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          if (widget.user.isAdmin)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, '/addAsset');
                  if (result != null) _loadAssets();
                },
                tooltip: 'Add New Asset',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAssets,
            tooltip: 'Refresh',
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
              onPressed: _loadAssets,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadAssets,
        child: Column(
          children: [
            // ===== STRONG ASSETS HEADER (MATCHES LIABILITIES QUALITY) =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1B5E20), // deep green
                    Color(0xFF2E7D32), // strong green
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Assets',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatCurrency(_totalAssets),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black26,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withAlpha(30),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${_assets.length} items',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ===== GROUPED ASSETS LIST =====
            Expanded(child: _buildGroupedAssetsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetCard(Asset asset) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryGreen.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryGreen.withValues(alpha: 0.15),
                    AppTheme.primaryGreen.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                _getAssetIcon(asset.type),
                color: AppTheme.primaryGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          asset.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      if (asset.isLiquid) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.blue.shade300,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.water_drop,
                                size: 10,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Liquid',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (asset.isInvestment) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.purple.shade300,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.trending_up,
                                size: 10,
                                color: Colors.purple.shade700,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Investment',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (asset.purchaseYear != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Since ${asset.purchaseYear}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryGreen.withValues(alpha: 0.15),
                    AppTheme.primaryGreen.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _formatCurrency(asset.currentValue),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
            if (widget.user.isAdmin) ...[
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                onSelected: (value) async {
                  if (value == 'edit') {
                    final result = await Navigator.pushNamed(
                      context,
                      '/addAsset',
                      arguments: {
                        'asset': {
                          'id': asset.id,
                          'name': asset.name,
                          'type': asset.type,
                          'currentValue': asset.currentValue,
                          'purchaseYear': asset.purchaseYear,
                          'isLiquid': asset.isLiquid,
                          'isInvestment': asset.isInvestment,
                        }
                      },
                    );
                    if (result != null) _loadAssets();
                  } else if (value == 'delete') {
                    _confirmDelete(asset);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Asset asset) async {
    if (asset.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete asset: Invalid asset ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Asset'),
        content: Text('Are you sure you want to delete "${asset.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.deleteAsset(asset.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${asset.name} deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadAssets();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting asset: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildGroupedAssetsList() {
    final Map<String, List<Asset>> grouped = {};
    for (final asset in _assets) {
      grouped.putIfAbsent(asset.type, () => []).add(asset);
    }

    final sortedKeys = grouped.keys.toList()..sort();

    if (_assets.isEmpty) {
      return const Center(child: Text('No assets found'));
    }

    for (final key in sortedKeys) {
      _expandedGroups.putIfAbsent(key, () => false);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 80),
      children: [
        ExpansionPanelList(
          expansionCallback: (index, isExpanded) {
            setState(() {
              final key = sortedKeys[index];
              _expandedGroups[key] = !(_expandedGroups[key] ?? false);
            });
          },
          expandedHeaderPadding: EdgeInsets.zero,
          elevation: 1,
          children: [
            for (int i = 0; i < sortedKeys.length; i++)
              ExpansionPanel(
                canTapOnHeader: true,
                isExpanded: _expandedGroups[sortedKeys[i]] ?? false,
                headerBuilder: (context, isOpen) => Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 2),
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getAssetIcon(sortedKeys[i]),
                        size: 18,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        sortedKeys[i].replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${grouped[sortedKeys[i]]!.length})',
                        style: const TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
                body: Column(
                  children: grouped[sortedKeys[i]]!.map(_buildAssetCard).toList(),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
