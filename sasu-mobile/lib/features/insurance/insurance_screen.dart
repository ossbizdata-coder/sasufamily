/// Insurance Screen
///
/// Displays all insurance policies.
///
/// Focus:
/// - Protection
/// - Security
/// - Future benefits
///
/// Show:
/// - Policy name
/// - Coverage amount
/// - Maturity year
/// - Beneficiaries
///
/// Emotion:
/// "My family is protected."

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/insurance.dart';
import '../../data/models/user.dart';
import '../../data/services/api_service.dart';
import '../../core/theme/app_theme.dart';

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
        title: const Text('Insurance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInsurance,
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
                      // Total Coverage Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppTheme.blueGradient,
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.shield, color: Colors.white, size: 48),
                            const SizedBox(height: 16),
                            const Text(
                              'Total Protection',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatCurrency(_totalCoverage),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_policies.length} active policies',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Policies List
                      Expanded(
                        child: _policies.isEmpty
                            ? const Center(
                                child: Text('No insurance policies found'),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _policies.length,
                                itemBuilder: (context, index) {
                                  final policy = _policies[index];
                                  return _buildInsuranceCard(policy);
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
                  const SnackBar(content: Text('Add insurance feature coming soon')),
                );
              },
              backgroundColor: AppTheme.primaryBlue,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildInsuranceCard(Insurance policy) {
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
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getInsuranceIcon(policy.type),
                    color: AppTheme.primaryBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        policy.policyName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        policy.type.replaceAll('_', ' '),
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
                        // TODO: Edit policy
                      } else if (value == 'delete') {
                        // TODO: Delete policy
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
            _buildInfoRow('Provider', policy.provider),
            _buildInfoRow('Coverage', _formatCurrency(policy.coverageAmount)),
            _buildInfoRow('Beneficiary', policy.beneficiary),
            if (policy.maturityYear != null)
              _buildInfoRow('Maturity', policy.maturityYear.toString()),
            if (policy.maturityBenefit != null)
              _buildInfoRow(
                'Maturity Benefit',
                _formatCurrency(policy.maturityBenefit!),
                highlight: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool highlight = false}) {
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
            style: TextStyle(
              fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
              color: highlight ? AppTheme.primaryBlue : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

