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
import 'liability_form_screen.dart';

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
  final Map<String, bool> _expandedGroups = {};

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

  Widget _buildGroupedLiabilitiesList() {
    final Map<String, List<Liability>> grouped = {};
    for (final liability in _liabilities) {
      grouped.putIfAbsent(liability.type, () => []).add(liability);
    }
    final sortedKeys = grouped.keys.toList()..sort();
    if (_liabilities.isEmpty) {
      return const Center(
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
      );
    }

    // Initialize expansion state for new groups
    for (final key in sortedKeys) {
      _expandedGroups.putIfAbsent(key, () => false);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 100), // Added bottom padding to prevent FAB overlap and ensure last item is visible
      children: [
        ExpansionPanelList(
          expansionCallback: (panelIndex, isExpanded) {
            setState(() {
              final key = sortedKeys[panelIndex];
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
                    color: Colors.orange.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(_getLiabilityIcon(sortedKeys[i]), size: 18, color: AppTheme.warning),
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
                      Text('(${grouped[sortedKeys[i]]!.length})', style: const TextStyle(fontSize: 12, color: Colors.black45)),
                    ],
                  ),
                ),
                body: Column(
                  children: grouped[sortedKeys[i]]!.map(_buildLiabilityCard).toList(),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLiabilityCard(Liability liability) {
    final progress = 1 - (liability.remainingAmount / liability.originalAmount);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.warning.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.warning.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.warning.withValues(alpha: 0.15),
                        AppTheme.warning.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.warning.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _getLiabilityIcon(liability.type),
                    color: AppTheme.warning,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        liability.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppTheme.success.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${(progress * 100).toStringAsFixed(0)}% paid',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.warning.withValues(alpha: 0.15),
                        AppTheme.warning.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.warning.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatCurrency(liability.remainingAmount),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.success),
                minHeight: 8,
              ),
            ),
            if (liability.monthlyPayment != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Monthly: ${_formatCurrency(liability.monthlyPayment!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (widget.user.isAdmin) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LiabilityFormScreen(liability: liability),
                        ),
                      );
                      if (result == true) {
                        _loadLiabilities();
                      }
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.warning,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Liability'),
                          content: const Text('Are you sure you want to delete this liability?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        try {
                          await ApiService.deleteLiability(liability.id!);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Liability deleted successfully')),
                            );
                          }
                          _loadLiabilities();
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to delete liability: $e')),
                            );
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Liabilities',
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
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LiabilityFormScreen(),
                    ),
                  );
                  if (result != null) _loadLiabilities();
                },
                tooltip: 'Add New Liability',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLiabilities,
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
                      // Header with reassurance (compact)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFEF6C00), // Deep orange
                              const Color(0xFFF57C00), // Lighter orange
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
                                  'Total Remaining',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatCurrency(_totalRemaining),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Monthly',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatCurrency(_totalMonthly),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
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
                          ],
                        ),
                      ),

                      // Liabilities List
                      Expanded(child: _buildGroupedLiabilitiesList()),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LiabilityFormScreen(),
            ),
          );
          if (result == true) {
            _loadLiabilities();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Liability',
      ),
    );
  }
}
