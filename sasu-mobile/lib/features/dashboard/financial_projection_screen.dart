/// Financial Projection Screen
///
/// Shows projected values for all 6 pillars over future years
/// - Net Worth projection
/// - Cash Flow projection
/// - Debt reduction projection
/// - Liquidity growth projection
/// - Investment growth projection
/// - Protection coverage projection

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/user.dart';
import '../../data/services/api_service.dart';
import '../../core/theme/app_theme.dart';

class FinancialProjectionScreen extends StatefulWidget {
  final User user;

  const FinancialProjectionScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<FinancialProjectionScreen> createState() => _FinancialProjectionScreenState();
}

class _FinancialProjectionScreenState extends State<FinancialProjectionScreen> {
  int _selectedYear = DateTime.now().year + 1;
  bool _isLoading = true;
  String? _error;

  // Current values
  double _currentAssets = 0;
  double _currentLiabilities = 0;
  double _currentIncome = 0;
  double _currentExpenses = 0;
  double _currentLiquidAssets = 0;
  double _currentInvestments = 0;
  double _currentInsuranceCoverage = 0;

  // Projected values
  Map<String, double> _projectedValues = {};

  // Growth assumptions (annual %)
  final double _assetGrowthRate = 8.0; // 8% annual growth
  final double _investmentGrowthRate = 12.0; // 12% for investments
  final double _incomeGrowthRate = 5.0; // 5% salary increment
  final double _expenseGrowthRate = 4.0; // 4% inflation
  final double _debtReductionRate = 15.0; // 15% annual debt reduction
  final double _liquidityGrowthRate = 10.0; // 10% savings growth

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  Future<void> _loadCurrentData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load all current data
      final assets = await ApiService.getAssets();
      final liabilities = await ApiService.getLiabilities();
      final incomes = await ApiService.getIncomes();
      final expenses = await ApiService.getExpenses();
      final insurances = await ApiService.getInsurance();

      _currentAssets = assets.fold(0.0, (sum, a) => sum + a.currentValue);
      _currentLiabilities = liabilities.fold(0.0, (sum, l) => sum + l.remainingAmount);

      // Calculate monthly income and expenses
      _currentIncome = incomes.fold(0.0, (sum, income) => sum + income.getMonthlyAmount());
      _currentExpenses = expenses.fold(0.0, (sum, expense) => sum + expense.getMonthlyAmount());

      // Liquid assets (cash, bank accounts, FD)
      _currentLiquidAssets = assets
          .where((a) => ['SAVINGS', 'FIXED_DEPOSIT'].contains(a.type))
          .fold(0.0, (sum, a) => sum + a.currentValue);

      // Investments (shares, mutual funds, retirement)
      _currentInvestments = assets
          .where((a) => ['SHARES', 'EPF', 'RETIREMENT_FUND'].contains(a.type))
          .fold(0.0, (sum, a) => sum + a.currentValue);

      _currentInsuranceCoverage = insurances.fold(0.0, (sum, i) => sum + i.coverageAmount);

      _calculateProjections();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _calculateProjections() {
    final currentYear = DateTime.now().year;
    final yearsAhead = _selectedYear - currentYear;

    if (yearsAhead <= 0) {
      _projectedValues = {
        'assets': _currentAssets,
        'liabilities': _currentLiabilities,
        'netWorth': _currentAssets - _currentLiabilities,
        'income': _currentIncome,
        'expenses': _currentExpenses,
        'cashFlow': _currentIncome - _currentExpenses,
        'liquidAssets': _currentLiquidAssets,
        'investments': _currentInvestments,
        'insurance': _currentInsuranceCoverage,
      };
      return;
    }

    // Project asset growth (compound)
    final projectedAssets = _currentAssets * _compound(_assetGrowthRate, yearsAhead);

    // Project debt reduction (decreasing)
    final projectedLiabilities = _currentLiabilities * _compound(-_debtReductionRate, yearsAhead);

    // Project income growth
    final projectedIncome = _currentIncome * _compound(_incomeGrowthRate, yearsAhead);

    // Project expense growth
    final projectedExpenses = _currentExpenses * _compound(_expenseGrowthRate, yearsAhead);

    // Project liquidity growth
    final projectedLiquidity = _currentLiquidAssets * _compound(_liquidityGrowthRate, yearsAhead);

    // Project investment growth
    final projectedInvestments = _currentInvestments * _compound(_investmentGrowthRate, yearsAhead);

    _projectedValues = {
      'assets': projectedAssets,
      'liabilities': projectedLiabilities.clamp(0, double.infinity), // Can't go negative
      'netWorth': projectedAssets - projectedLiabilities.clamp(0, double.infinity),
      'income': projectedIncome,
      'expenses': projectedExpenses,
      'cashFlow': projectedIncome - projectedExpenses,
      'liquidAssets': projectedLiquidity,
      'investments': projectedInvestments,
      'insurance': _currentInsuranceCoverage, // Assume constant unless updated
    };
  }

  double _compound(double rate, int years) {
    return math.pow(1 + rate / 100, years).toDouble();
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);
    return formatter.format(amount);
  }

  String _formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Projections'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : Column(
                  children: [
                    _buildYearSelector(),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadCurrentData,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _buildProjectionCard(
                              'Net Worth',
                              Icons.account_balance,
                              _currentAssets - _currentLiabilities,
                              _projectedValues['netWorth'] ?? 0,
                              Colors.green,
                            ),
                            const SizedBox(height: 12),
                            _buildProjectionCard(
                              'Total Assets',
                              Icons.trending_up,
                              _currentAssets,
                              _projectedValues['assets'] ?? 0,
                              Colors.blue,
                            ),
                            const SizedBox(height: 12),
                            _buildProjectionCard(
                              'Total Liabilities',
                              Icons.trending_down,
                              _currentLiabilities,
                              _projectedValues['liabilities'] ?? 0,
                              Colors.red,
                              isDecrease: true,
                            ),
                            const SizedBox(height: 12),
                            _buildProjectionCard(
                              'Monthly Cash Flow',
                              Icons.attach_money,
                              _currentIncome - _currentExpenses,
                              _projectedValues['cashFlow'] ?? 0,
                              Colors.purple,
                            ),
                            const SizedBox(height: 12),
                            _buildProjectionCard(
                              'Liquid Assets',
                              Icons.water_drop,
                              _currentLiquidAssets,
                              _projectedValues['liquidAssets'] ?? 0,
                              Colors.cyan,
                            ),
                            const SizedBox(height: 12),
                            _buildProjectionCard(
                              'Investments',
                              Icons.show_chart,
                              _currentInvestments,
                              _projectedValues['investments'] ?? 0,
                              Colors.orange,
                            ),
                            const SizedBox(height: 12),
                            _buildProjectionCard(
                              'Insurance Coverage',
                              Icons.security,
                              _currentInsuranceCoverage,
                              _projectedValues['insurance'] ?? 0,
                              Colors.indigo,
                            ),
                            const SizedBox(height: 24),
                            _buildAssumptionsCard(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildYearSelector() {
    final currentYear = DateTime.now().year;
    final years = List.generate(10, (i) => currentYear + i);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.greenGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Target Year',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<int>(
              value: _selectedYear,
              isExpanded: true,
              underline: const SizedBox(),
              items: years.map((year) {
                final yearsAhead = year - currentYear;
                return DropdownMenuItem(
                  value: year,
                  child: Text(
                    yearsAhead == 0
                        ? '$year (Current)'
                        : '$year (+$yearsAhead years)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedYear = value;
                    _calculateProjections();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionCard(
    String title,
    IconData icon,
    double currentValue,
    double projectedValue,
    Color color, {
    bool isDecrease = false,
  }) {
    final difference = projectedValue - currentValue;
    final percentageChange = currentValue != 0
        ? (difference / currentValue * 100)
        : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(currentValue),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.grey[400],
                  size: 24,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Projected $_selectedYear',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(projectedValue),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: (isDecrease ? difference < 0 : difference > 0)
                    ? Colors.green.withAlpha(20)
                    : Colors.red.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    (isDecrease ? difference < 0 : difference > 0)
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: (isDecrease ? difference < 0 : difference > 0)
                        ? Colors.green
                        : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatCurrency(difference.abs())} (${_formatPercentage(percentageChange.abs())})',
                    style: TextStyle(
                      color: (isDecrease ? difference < 0 : difference > 0)
                          ? Colors.green[700]
                          : Colors.red[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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

  Widget _buildAssumptionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Growth Assumptions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildAssumptionRow('Asset Growth', _assetGrowthRate),
            _buildAssumptionRow('Investment Returns', _investmentGrowthRate),
            _buildAssumptionRow('Income Growth', _incomeGrowthRate),
            _buildAssumptionRow('Expense Inflation', _expenseGrowthRate),
            _buildAssumptionRow('Debt Reduction', _debtReductionRate),
            _buildAssumptionRow('Savings Growth', _liquidityGrowthRate),
            const SizedBox(height: 12),
            Text(
              'Note: These are estimated projections based on historical averages and may not reflect actual future performance.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssumptionRow(String label, double rate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
          Text(
            '${rate.toStringAsFixed(1)}% p.a.',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

