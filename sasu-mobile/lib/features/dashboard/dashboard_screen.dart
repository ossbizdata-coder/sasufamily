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
import '../../data/models/asset.dart';
import '../../data/models/liability.dart';
import '../../data/models/user.dart';
import '../../data/services/api_service.dart';
import '../../core/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  final User user;

  const DashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardSummary? _summary;
  List<Asset> _assets = [];
  List<Liability> _liabilities = [];
  bool _isLoading = true;
  String? _error;

  // Calculated totals (with auto-growth and currency conversion)
  double get _calculatedTotalAssets {
    return _assets.fold(0, (sum, asset) => sum + asset.valueInLKR);
  }

  double get _calculatedTotalLiabilities {
    return _liabilities.fold(0, (sum, liability) => sum + liability.calculatedRemainingAmount);
  }

  double get _calculatedNetWorth {
    return _calculatedTotalAssets - _calculatedTotalLiabilities;
  }

  double get _calculatedLiquidAssets {
    return _assets
        .where((a) => a.isLiquid)
        .fold(0, (sum, asset) => sum + asset.valueInLKR);
  }

  double get _calculatedInvestments {
    return _assets
        .where((a) => a.isInvestment)
        .fold(0, (sum, asset) => sum + asset.valueInLKR);
  }

  // Investment ratio = investments / total assets * 100
  double get _calculatedInvestmentRatio {
    if (_calculatedTotalAssets == 0) return 0;
    return (_calculatedInvestments / _calculatedTotalAssets) * 100;
  }

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
      // Load dashboard summary, assets, and liabilities in parallel
      final results = await Future.wait([
        ApiService.getDashboardSummary(),
        ApiService.getAssets(),
        ApiService.getLiabilities(),
      ]);

      setState(() {
        _summary = results[0] as DashboardSummary;
        _assets = results[1] as List<Asset>;
        _liabilities = results[2] as List<Liability>;
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


  Color _getScoreColor(int score) {
    if (score >= 80) return AppTheme.success;
    if (score >= 60) return AppTheme.primaryBlue;
    if (score >= 40) return AppTheme.gold;
    return AppTheme.warning;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove AppBar, start directly with body
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
              : SafeArea(
                  bottom: true,
                  child: RefreshIndicator(
                    onRefresh: _loadDashboard,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100), // Bottom padding for navbar
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome message (without button)
                          _buildWelcomeSection(),
                          const SizedBox(height: 12),
                          // Wealth Health Score
                          _buildWealthScoreCard(),
                          const SizedBox(height: 12),
                          // Financial Summary (Assets, Debts, Net Worth)
                          _buildFinancialSummaryCard(),
                          const SizedBox(height: 16),
                          // Detailed Score Breakdown (always visible)
                          if (_summary!.scoreBreakdown != null)
                            _buildScoreBreakdown(),
                          const SizedBox(height: 16),
                          // Financial Projection Button at bottom
                          _buildFinancialProjectionButton(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildWelcomeSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Welcome, ${widget.user.fullName}',
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),
        // Refresh button
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.grey.shade600),
          onPressed: _loadDashboard,
          tooltip: 'Refresh',
        ),
        if (widget.user.isAdmin)
          IconButton(
            icon: Icon(Icons.settings, color: Colors.grey.shade600),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/admin-settings',
                arguments: {'user': widget.user},
              );
            },
            tooltip: 'Admin Settings',
          ),
      ],
    );
  }

  Widget _buildFinancialSummaryCard() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Net Worth (centered with icon)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: _calculatedNetWorth >= 0 ? AppTheme.primaryGreen : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  _formatCurrency(_calculatedNetWorth),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _calculatedNetWorth >= 0 ? AppTheme.primaryGreen : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Assets and Liabilities row - centered alignment
            Row(
              children: [
                // Assets
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_upward, color: AppTheme.primaryGreen, size: 14),
                          const SizedBox(width: 4),
                          Text('Assets', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(_calculatedTotalAssets),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                // Divider
                Container(
                  width: 1,
                  height: 36,
                  color: Colors.grey.shade300,
                ),
                // Liabilities
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_downward, color: Colors.orange.shade700, size: 14),
                          const SizedBox(width: 4),
                          Text('Liabilities', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(_calculatedTotalLiabilities),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _calculatedTotalLiabilities > 0 ? Colors.orange.shade700 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFinancialProjectionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/financialProjection',
            arguments: {'user': widget.user},
          );
        },
        icon: const Icon(Icons.insights, size: 20),
        label: const Text('View Financial Projections'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
      ),
    );
  }


  Widget _buildWealthScoreCard() {
    final score = _summary!.wealthHealthScore;
    final color = _getScoreColor(score);

    return Card(
      margin: EdgeInsets.zero, // remove default margin
      child: Padding(
        padding: const EdgeInsets.all(12), // reduced padding
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
                    const SizedBox(height: 4), // reduced spacing
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _summary!.wealthHealthLabel,
                          style: TextStyle(
                            fontSize: 15,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_summary!.wealthHealthLabel == 'Excellent')
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Icon(
                              Icons.emoji_events,
                              color: Colors.amber.shade700,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                // Show animated speedometer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withAlpha((0.08 * 255).toInt()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$score%',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: color.withAlpha((0.25 * 255).toInt()),
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8), // reduced spacing
            Container(
              padding: const EdgeInsets.all(8), // reduced padding
              decoration: BoxDecoration(
                color: color.withAlpha((0.1 * 255).toInt()),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: color, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Future Readiness: ${_summary!.futureReadinessStatus}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  _buildStars(score),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStars(int score) {
    int stars = (score / 20).ceil().clamp(1, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) => Icon(
        i < stars ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 18,
      )),
    );
  }

  Widget _buildScoreBreakdown() {
    final breakdown = _summary!.scoreBreakdown!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _buildPillarCard(
          'Net Worth',
          breakdown.netWorthScore,
          25,
          breakdown.netWorthStatus,
          Icons.trending_up,
          const Color(0xFF2E7D32), // Natural green
          'Net Worth: ${_formatCurrency(_calculatedNetWorth)}',
          '/assets',
        ),
        const SizedBox(height: 8),
        _buildPillarCard(
          'Cash Flow Health',
          breakdown.cashFlowScore,
          20,
          breakdown.cashFlowStatus,
          Icons.payments,
          const Color(0xFF1565C0), // Deep blue
          'Savings Rate: ${breakdown.savingsRate.toStringAsFixed(1)}% | '
              'Surplus: ${_formatCurrency(breakdown.monthlySurplus)}',
          '/incomeExpense',
        ),
        const SizedBox(height: 8),
        _buildPillarCard(
          'Liquidity & Emergency Fund',
          breakdown.liquidityScore,
          15,
          breakdown.liquidityStatus,
          Icons.water_drop,
          const Color(0xFF00838F), // Teal/Cyan
          'Emergency Fund: ${breakdown.emergencyFundMonths.toStringAsFixed(1)} months | '
              'Liquid: ${_formatCurrency(_calculatedLiquidAssets)}',
          '/liquidity',
        ),
        const SizedBox(height: 8),
        _buildPillarCard(
          'Protection & Insurance',
          breakdown.protectionScore,
          10,
          breakdown.protectionStatus,
          Icons.health_and_safety,
          const Color(0xFF283593), // Indigo
          'Coverage: ${breakdown.coverageRatio.toStringAsFixed(1)}x | '
              'Health: ${breakdown.hasHealthInsurance ? "✓" : "✗"} | '
              'Life: ${breakdown.hasLifeInsurance ? "✓" : "✗"}',
          '/insurance',
          hasHealthInsurance: breakdown.hasHealthInsurance,
          hasLifeInsurance: breakdown.hasLifeInsurance,
        ),
        const SizedBox(height: 8),
        _buildPillarCard(
          'Investment Efficiency',
          breakdown.investmentScore,
          15,
          breakdown.investmentStatus,
          Icons.show_chart,
          const Color(0xFF6A1B9A), // Purple
          'Investment Ratio: ${_calculatedInvestmentRatio.toStringAsFixed(1)}% | '
              'Total: ${_formatCurrency(_calculatedInvestments)}',
          '/investment-efficiency',
        ),
        const SizedBox(height: 8),
        _buildPillarCard(
          'Debts',
          breakdown.debtScore,
          15,
          breakdown.debtStatus,
          Icons.account_balance,
          breakdown.debtStatus == 'Critical' ? const Color(0xFFC62828) : const Color(0xFFEF6C00), // Red or orange
          'Total: ${_formatCurrency(_calculatedTotalLiabilities)} | '
              'DTI: ${breakdown.debtToIncomeRatio.toStringAsFixed(1)}%',
          '/liabilities',
        ),

      ],
    );
  }

  Widget _buildPillarCard(
    String title,
    int score,
    int maxScore,
    String status,
    IconData icon,
    Color color,
    String details,
    String? route, {
    bool? hasHealthInsurance,
    bool? hasLifeInsurance,
  }) {
    final percentage = (score / maxScore * 100).clamp(0.0, 100.0);
    final statusColor = _getStatusColor(status);

    // Check if this is the insurance card
    final isInsuranceCard = hasHealthInsurance != null || hasLifeInsurance != null;

    // Extract total amount from details string
    String totalAmount = '';
    if (details.contains('Net Worth:')) {
      totalAmount = details.split('Net Worth:')[1].trim();
    } else if (details.contains('Surplus:')) {
      totalAmount = details.split('Surplus:')[1].trim();
    } else if (details.contains('Debt Ratio:')) {
      // For debt, show DTI ratio
      totalAmount = details.split('DTI:')[1].split('|')[0].trim();
    } else if (details.contains('Liquid:')) {
      totalAmount = details.split('Liquid:')[1].trim();
    } else if (details.contains('Total:')) {
      totalAmount = details.split('Total:')[1].trim();
    } else if (details.contains('Coverage:')) {
      totalAmount = details.split('Coverage:')[1].split('|')[0].trim();
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: route != null
          ? () {
              Navigator.pushNamed(
                context,
                route,
                arguments: {'user': widget.user},
              );
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
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
                          color.withValues(alpha: 0.15),
                          color.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
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
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (totalAmount.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.15),
                            color.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: color.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        totalAmount,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: color.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$score / $maxScore',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
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
                      Icons.info_outline,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: isInsuranceCard
                          ? _buildInsuranceDetails(details, hasHealthInsurance!, hasLifeInsurance!)
                          : Text(
                              details,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                                height: 1.3,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Excellent':
        return Colors.green.shade700;
      case 'Good':
        return Colors.blue.shade700;
      case 'Fair':
        return Colors.orange.shade700;
      case 'Critical':
      case 'Poor':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Widget _buildInsuranceDetails(String details, bool hasHealth, bool hasLife) {
    // Extract coverage part
    final coveragePart = details.split('|')[0].trim();

    return Row(
      children: [
        Text(
          coveragePart,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Health: ',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
          ),
        ),
        Icon(
          hasHealth ? Icons.check_circle : Icons.cancel,
          size: 14,
          color: hasHealth ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          'Life: ',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
          ),
        ),
        Icon(
          hasLife ? Icons.check_circle : Icons.cancel,
          size: 14,
          color: hasLife ? Colors.green : Colors.red,
        ),
      ],
    );
  }
}
