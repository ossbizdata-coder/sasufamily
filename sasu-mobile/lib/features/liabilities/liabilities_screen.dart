/// Liabilities Screen
///
/// Displays loans and credits.
///
/// UI rules:
/// - No red alerts
/// - Calm neutral colors
///
/// Show:
/// - Remaining amount
/// - Monthly payment
/// - Years left
///
/// Include reassuring text:
/// "All liabilities are manageable."

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/liability.dart';
import '../../data/models/user.dart';
import '../../data/services/api_service.dart';
import '../../core/theme/app_theme.dart';

class LiabilitiesScreen extends StatefulWidget {
  final User user;

  const LiabilitiesScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<LiabilitiesScreen> createState() => _LiabilitiesScreenState();
}

class _LiabilitiesScreenState extends State<LiabilitiesScreen> {
  List<Liability> _liabilities = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLiabilities();
  }

  Future<void> _loadLiabilities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final liabilities = await ApiService.getLiabilities();
      setState(() {
        _liabilities = liabilities;
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

  double get _totalRemaining {
    return _liabilities.fold(0, (sum, liability) => sum + liability.remainingAmount);
  }

  double get _totalMonthly {
    return _liabilities.fold(
      0,
      (sum, liability) => sum + (liability.monthlyPayment ?? 0),
    );
  }

  IconData _getLiabilityIcon(String type) {
    switch (type) {
      case 'HOME_LOAN':
        return Icons.home;
      case 'VEHICLE_LOAN':
        return Icons.directions_car;
      case 'PERSONAL_LOAN':
        return Icons.person;
      case 'EDUCATION_LOAN':
        return Icons.school;
      case 'CREDIT_CARD':
        return Icons.credit_card;
      default:
        return Icons.payments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liabilities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLiabilities,
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
                        onPressed: _loadLiabilities,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLiabilities,
                  child: Column(
                    children: [
                      // Header with reassurance
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        color: AppTheme.lightBlue,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildHeaderStat(
                                  'Total Remaining',
                                  _formatCurrency(_totalRemaining),
                                ),
                                _buildHeaderStat(
                                  'Monthly Burden',
                                  _formatCurrency(_totalMonthly),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'All liabilities are under control',
                                    style: TextStyle(
                                      color: AppTheme.success,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Liabilities List
                      Expanded(
                        child: _liabilities.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.celebration, size: 64, color: AppTheme.success),
                                    SizedBox(height: 16),
                                    Text(
                                      'No liabilities!',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.success,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text('Your family is debt-free! 🎉'),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _liabilities.length,
                                itemBuilder: (context, index) {
                                  final liability = _liabilities[index];
                                  return _buildLiabilityCard(liability);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: widget.user.isAdmin
          ? FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add liability feature coming soon')),
                );
              },
              backgroundColor: AppTheme.warning,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textMedium,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildLiabilityCard(Liability liability) {
    final progress = 1 - (liability.remainingAmount / liability.originalAmount);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getLiabilityIcon(liability.type),
                    color: AppTheme.warning,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        liability.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        liability.type.replaceAll('_', ' '),
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.user.isAdmin)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        // TODO: Edit liability
                      } else if (value == 'delete') {
                        // TODO: Delete liability
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
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Remaining: ${_formatCurrency(liability.remainingAmount)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}% paid',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.success),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),

            const SizedBox(height: 16),
            if (liability.monthlyPayment != null)
              _buildInfoRow(
                'Monthly Payment',
                _formatCurrency(liability.monthlyPayment!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textMedium,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

