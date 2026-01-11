/// Dashboard Screen
///
/// This is the HOME screen of the app.
///
/// Goals:
/// - Give instant confidence
/// - Show family financial health at a glance
///
/// Sections (top to bottom):
/// 1. Welcome message (soft, emotional)
/// 2. Total Net Worth
/// 3. Asset vs Liability summary
/// 4. Family Wealth Health Score (0–100)
/// 5. Future Readiness Indicator
///
/// UI rules:
/// - Scrollable layout
/// - Use InfoCard widgets
/// - Use calm charts (no aggressive colors)
/// - Plenty of spacing
///
/// Emotion:
/// User should feel:
/// "We are safe. Our future is planned."

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/dashboard_summary.dart';
import '../../data/models/user.dart';
import '../../data/services/api_service.dart';
import '../../core/widgets/info_card.dart';
import '../../core/theme/app_theme.dart';
import '../assets/assets_screen.dart';
import '../insurance/insurance_screen.dart';
import '../liabilities/liabilities_screen.dart';

class DashboardScreen extends StatefulWidget {
  final User user;

  const DashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardSummary? _summary;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final summary = await ApiService.getDashboardSummary();
      setState(() {
        _summary = summary;
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

  String _formatCompact(double amount) {
    if (amount >= 10000000) {
      return 'Rs. ${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return 'Rs. ${(amount / 100000).toStringAsFixed(1)}L';
    } else {
      return 'Rs. ${(amount / 1000).toStringAsFixed(0)}K';
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppTheme.success;
    if (score >= 60) return AppTheme.primaryBlue;
    if (score >= 40) return AppTheme.gold;
    return AppTheme.warning;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SaSu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ApiService.clearToken();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
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
                        onPressed: _loadDashboard,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDashboard,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome message
                        _buildWelcomeSection(),
                        const SizedBox(height: 24),

                        // Net Worth Card
                        _buildNetWorthCard(),
                        const SizedBox(height: 16),

                        // Wealth Health Score
                        _buildWealthScoreCard(),
                        const SizedBox(height: 24),

                        // Quick Stats Row
                        _buildQuickStatsRow(),
                        const SizedBox(height: 24),

                        // Motivational Message
                        _buildMotivationalCard(),
                        const SizedBox(height: 24),

                        // Navigate to Details
                        _buildNavigationSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, ${widget.user.fullName}',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Your Family Financial Health',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textMedium,
              ),
        ),
      ],
    );
  }

  Widget _buildNetWorthCard() {
    return InfoCard(
      title: 'Total Net Worth',
      value: _formatCompact(_summary!.netWorth),
      subtitle: 'Assets: ${_formatCompact(_summary!.totalAssets)} | '
          'Liabilities: ${_formatCompact(_summary!.totalLiabilities)}',
      icon: Icons.account_balance_wallet,
      gradient: AppTheme.greenGradient,
    );
  }

  Widget _buildWealthScoreCard() {
    final score = _summary!.wealthHealthScore;
    final color = _getScoreColor(score);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wealth Health Score',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _summary!.wealthHealthLabel,
                      style: TextStyle(
                        fontSize: 16,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                // Circular progress indicator
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                      Center(
                        child: Text(
                          '$score',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: color, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Future Readiness: ${_summary!.futureReadinessStatus}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsRow() {
    return Row(
      children: [
        Expanded(
          child: InfoCard(
            title: 'Insurance Coverage',
            value: _formatCompact(_summary!.totalInsuranceCoverage),
            subtitle: '${_summary!.totalInsurancePolicies} policies',
            icon: Icons.security,
            iconColor: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InfoCard(
            title: 'Monthly Burden',
            value: _formatCompact(_summary!.totalMonthlyBurden),
            subtitle: 'All loans',
            icon: Icons.payments_outlined,
            iconColor: AppTheme.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.blueGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _summary!.motivationalMessage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'View Details',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        _buildNavigationCard(
          'Assets',
          'View all family assets',
          Icons.home_work,
          AppTheme.primaryGreen,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AssetsScreen(user: widget.user)),
          ),
        ),
        const SizedBox(height: 12),
        _buildNavigationCard(
          'Insurance',
          'Protection & future benefits',
          Icons.security,
          AppTheme.primaryBlue,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InsuranceScreen(user: widget.user)),
          ),
        ),
        const SizedBox(height: 12),
        _buildNavigationCard(
          'Liabilities',
          'Loans and credits',
          Icons.credit_card,
          AppTheme.warning,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LiabilitiesScreen(user: widget.user)),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

