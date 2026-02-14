import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/insurance.dart';
import '../../data/models/user.dart';
import '../../data/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import 'insurance_form_screen.dart';

class InsuranceScreen extends StatefulWidget {
  final User user;

  const InsuranceScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen> {
  List<Insurance> _policies = [];
  bool _isLoading = true;
  String? _error;

  final Map<String, bool> _expandedGroups = {};

  @override
  void initState() {
    super.initState();
    _loadInsurance();
  }

  Future<void> _loadInsurance() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final policies = await ApiService.getInsurance();
      setState(() {
        _policies = policies;
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

  double get _totalCoverage {
    return _policies.fold(0, (sum, policy) => sum + policy.coverageAmount);
  }

  IconData _getInsuranceIcon(String type) {
    switch (type) {
      case 'LIFE':
        return Icons.favorite;
      case 'MEDICAL':
        return Icons.health_and_safety;
      case 'EDUCATION':
        return Icons.school;
      case 'VEHICLE':
        return Icons.directions_car;
      case 'HOME':
        return Icons.home;
      default:
        return Icons.security;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Insurance'),
            if (widget.user.isAdmin) ...[
              const SizedBox(width: 12),
              Container(
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
                        builder: (context) => const InsuranceFormScreen(),
                      ),
                    );
                    if (result != null) _loadInsurance();
                  },
                  tooltip: 'Add New Insurance',
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInsurance,
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
            const Icon(Icons.error_outline,
                size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInsurance,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadInsurance,
        child: Column(
          children: [
            // ===== STRONG INSURANCE HEADER =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0D47A1),
                    Color(0xFF1976D2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                crossAxisAlignment:
                CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                          Colors.white.withAlpha(20),
                          borderRadius:
                          BorderRadius.circular(12),
                          border: Border.all(
                            color:
                            Colors.white.withAlpha(30),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.shield,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Protection',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatCurrency(
                                _totalCoverage),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight:
                              FontWeight.bold,
                              letterSpacing: 0.4,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black26,
                                  offset:
                                  Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6),
                    decoration: BoxDecoration(
                      color:
                      Colors.black.withAlpha(20),
                      borderRadius:
                      BorderRadius.circular(10),
                      border: Border.all(
                        color:
                        Colors.white.withAlpha(
                            30),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${_policies.length} policies',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(child: _buildGroupedInsuranceList()),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedInsuranceList() {
    final Map<String, List<Insurance>> grouped = {};
    for (final policy in _policies) {
      grouped.putIfAbsent(policy.type, () => []).add(policy);
    }

    final sortedKeys = grouped.keys.toList()..sort();

    if (_policies.isEmpty) {
      return const Center(child: Text('No insurance policies found'));
    }

    for (final key in sortedKeys) {
      _expandedGroups.putIfAbsent(key, () => false);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 100),
      children: [
        ExpansionPanelList(
          expansionCallback: (index, isExpanded) {
            setState(() {
              final key = sortedKeys[index];
              _expandedGroups[key] =
              !(_expandedGroups[key] ?? false);
            });
          },
          expandedHeaderPadding: EdgeInsets.zero,
          elevation: 1,
          children: [
            for (int i = 0; i < sortedKeys.length; i++)
              ExpansionPanel(
                canTapOnHeader: true,
                isExpanded:
                _expandedGroups[sortedKeys[i]] ?? false,
                headerBuilder: (context, isOpen) =>
                    Container(
                      margin:
                      const EdgeInsets.only(top: 8, bottom: 2),
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(20),
                        borderRadius:
                        BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getInsuranceIcon(
                                sortedKeys[i]),
                            size: 18,
                            color:
                            AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            sortedKeys[i]
                                .replaceAll('_', ' ')
                                .toUpperCase(),
                            style: const TextStyle(
                              fontWeight:
                              FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${grouped[sortedKeys[i]]!.length})',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black45),
                          ),
                        ],
                      ),
                    ),
                body: Column(
                  children: grouped[
                  sortedKeys[i]]!
                      .map(_buildInsuranceCard)
                      .toList(),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsuranceCard(Insurance policy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
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
                        AppTheme.primaryBlue.withValues(alpha: 0.15),
                        AppTheme.primaryBlue.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getInsuranceIcon(policy.type),
                    color: AppTheme.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        policy.policyName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Provider: ${policy.provider}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      if (policy.beneficiary.isNotEmpty)
                        Text(
                          'Beneficiary: ${policy.beneficiary}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black45,
                          ),
                        ),
                    ],
                  ),
                ),
                if (widget.user.isAdmin)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InsuranceFormScreen(
                              insurance: policy,
                            ),
                          ),
                        );
                        if (result == true) {
                          _loadInsurance();
                        }
                      } else if (value == 'delete') {
                        _confirmDelete(policy);
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
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Coverage',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      _formatCurrency(policy.coverageAmount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (policy.premiumAmount != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Premium',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        '${_formatCurrency(policy.premiumAmount!)}${policy.premiumFrequency != null ? ' / ${policy.premiumFrequency!.toLowerCase()}' : ''}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (policy.startDate != null || policy.maturityYear != null) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (policy.startDate != null)
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 12, color: Colors.black45),
                        const SizedBox(width: 4),
                        Text(
                          'Start: ${policy.startDate}',
                          style: const TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      ],
                    ),
                  if (policy.maturityYear != null)
                    Row(
                      children: [
                        const Icon(Icons.event, size: 12, color: Colors.black45),
                        const SizedBox(width: 4),
                        Text(
                          'Maturity: ${policy.maturityYear}',
                          style: const TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      ],
                    ),
                ],
              ),
            ],
            if (policy.maturityBenefit != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Maturity Benefit:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      _formatCurrency(policy.maturityBenefit!),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (policy.description != null && policy.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                policy.description!,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Insurance policy) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Insurance Policy'),
        content: Text('Are you sure you want to delete "${policy.policyName}"?'),
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
        await ApiService.deleteInsurance(policy.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Insurance policy deleted successfully')),
          );
          _loadInsurance();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting insurance: $e')),
          );
        }
      }
    }
  }
}
