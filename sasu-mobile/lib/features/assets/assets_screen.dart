/// Assets Screen
///
/// Displays all family assets.
///
/// Layout:
/// - Total asset value at top
/// - Assets grouped by type
/// - Each asset in an InfoCard
///
/// Show:
/// - Asset name
/// - Current value
/// - Purchase year
///
/// This screen must feel:
/// - Strong
/// - Reassuring
/// - Organized

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
        title: const Text('Assets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAssets,
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
                      // Total Assets Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppTheme.greenGradient,
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Total Assets',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatCurrency(_totalAssets),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_assets.length} assets',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Assets List
                      Expanded(
                        child: _assets.isEmpty
                            ? const Center(
                                child: Text('No assets found'),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _assets.length,
                                itemBuilder: (context, index) {
                                  final asset = _assets[index];
                                  return _buildAssetCard(asset);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: widget.user.isAdmin
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Add asset screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add asset feature coming soon')),
                );
              },
              backgroundColor: AppTheme.primaryGreen,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildAssetCard(Asset asset) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getAssetIcon(asset.type),
            color: AppTheme.primaryGreen,
            size: 28,
          ),
        ),
        title: Text(
          asset.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              asset.type.replaceAll('_', ' '),
              style: TextStyle(
                color: AppTheme.textLight,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatCurrency(asset.currentValue),
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (asset.purchaseYear != null) ...[
              const SizedBox(height: 4),
              Text(
                'Since ${asset.purchaseYear}',
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        trailing: widget.user.isAdmin
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    // TODO: Edit asset
                  } else if (value == 'delete') {
                    // TODO: Delete asset
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}

