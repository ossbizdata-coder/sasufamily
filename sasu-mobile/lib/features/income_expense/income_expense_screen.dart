import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/income.dart';
import '../../data/models/expense.dart';
import '../../data/models/user.dart';
import '../../data/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import 'income_form_screen.dart';
import 'expense_form_screen.dart';

class IncomeExpenseScreen extends StatefulWidget {
  final User user;

  const IncomeExpenseScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<IncomeExpenseScreen> createState() => _IncomeExpenseScreenState();
}

class _IncomeExpenseScreenState extends State<IncomeExpenseScreen>
    with SingleTickerProviderStateMixin {
  List<Income> _incomes = [];
  List<Expense> _expenses = [];
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  // Track expanded state for expense categories
  final Map<String, bool> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final incomes = await ApiService.getIncomes();
      final expenses = await ApiService.getExpenses();
      setState(() {
        _incomes = incomes;
        _expenses = expenses;
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
    return NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0).format(amount);
  }

  double get _totalMonthlyIncome =>
      _incomes.where((i) => i.active).fold(0, (s, i) => s + i.getMonthlyAmount());

  double get _totalMonthlyExpenses => _expenses
      .where((e) => e.active)
      .fold(0, (s, e) => s + e.getMonthlyAmount());

  double get _totalMonthlyNeeds => _expenses
      .where((e) => e.active && e.isNeed)
      .fold(0, (s, e) => s + e.getMonthlyAmount());

  double get _totalMonthlyWants => _expenses
      .where((e) => e.active && !e.isNeed)
      .fold(0, (s, e) => s + e.getMonthlyAmount());

  double get _netSavings => _totalMonthlyIncome - _totalMonthlyExpenses;

  double get _savingsRate =>
      _totalMonthlyIncome == 0 ? 0 : (_netSavings / _totalMonthlyIncome) * 100;

  // ---------------- SUMMARY CARD ----------------

  Widget _buildSummaryCard() {
    final positive = _netSavings >= 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D47A1), // deep blue
            Color(0xFF1976D2), // strong royal blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _summaryRow(
            'Monthly Income',
            _formatCurrency(_totalMonthlyIncome),
            Icons.trending_up,
          ),
          const SizedBox(height: 14),
          _summaryRow(
            'Monthly Expenses',
            _formatCurrency(_totalMonthlyExpenses),
            Icons.trending_down,
          ),
          const Divider(color: Colors.white38, height: 28, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryText(
                'Net Savings',
                _formatCurrency(_netSavings),
                positive ? Colors.greenAccent : Colors.redAccent,
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withAlpha(40),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      positive
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: positive
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_savingsRate.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black38,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }


  Widget _summaryRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: Colors.black38,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _summaryText(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Net Savings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: const [
              Shadow(
                blurRadius: 6,
                color: Colors.black38,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
      ],
    );
  }


  // ---------------- INCOME ----------------

  Widget _buildIncomeList() {
    if (_incomes.isEmpty) return _emptyState(Icons.attach_money, 'No income added', _addIncome);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: _incomes.length,
      itemBuilder: (_, i) => _buildIncomeCard(_incomes[i]),
    );
  }

  Widget _buildIncomeCard(Income income) {
    return _financialCard(
      icon: Icons.attach_money,
      iconColor: Colors.green,
      title: income.source,
      subtitle: '${income.type} • ${income.frequency}',
      amount: income.getMonthlyAmount(),
      rawAmount: income.amount,
      actions: widget.user.isAdmin
          ? [
        _action('Edit', Icons.edit, Colors.green, () => _editIncome(income)),
        _action('Delete', Icons.delete, Colors.red, () => _deleteIncome(income)),
      ]
          : null,
    );
  }

  // ---------------- EXPENSE ----------------

  Widget _buildExpenseList() {
    if (_expenses.isEmpty) return _emptyState(Icons.receipt_long, 'No expenses added', _addExpense);

    // Group expenses by category
    final Map<String, List<Expense>> grouped = {};
    for (final expense in _expenses) {
      grouped.putIfAbsent(expense.category, () => []).add(expense);
    }

    // Sort categories alphabetically
    final sortedCategories = grouped.keys.toList()..sort();

    // Initialize expansion state
    for (final category in sortedCategories) {
      _expandedCategories.putIfAbsent(category, () => false);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
      child: Column(
        children: sortedCategories.map((category) {
          final expenses = grouped[category]!;
          final categoryTotal = expenses.fold(0.0, (sum, e) => sum + e.getMonthlyAmount());
          final needsCount = expenses.where((e) => e.isNeed).length;
          final wantsCount = expenses.length - needsCount;
          final isExpanded = _expandedCategories[category] ?? false;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Category Header (tappable)
                InkWell(
                  onTap: () {
                    setState(() {
                      _expandedCategories[category] = !isExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(category).withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getCategoryIcon(category),
                            color: _getCategoryColor(category),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatCategoryName(category),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    '${expenses.length} items',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  if (needsCount > 0) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '$needsCount need${needsCount > 1 ? 's' : ''}',
                                        style: TextStyle(fontSize: 9, color: Colors.blue.shade700),
                                      ),
                                    ),
                                  ],
                                  if (wantsCount > 0) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '$wantsCount want${wantsCount > 1 ? 's' : ''}',
                                        style: TextStyle(fontSize: 9, color: Colors.purple.shade700),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatCurrency(categoryTotal),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.grey.shade500,
                        ),
                      ],
                    ),
                  ),
                ),
                // Expanded expense items
                if (isExpanded)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      children: expenses.map((expense) => _buildCompactExpenseItem(expense)).toList(),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCompactExpenseItem(Expense expense) {
    return InkWell(
      onTap: widget.user.isAdmin ? () => _editExpense(expense) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Need/Want indicator
            Container(
              width: 4,
              height: 28,
              decoration: BoxDecoration(
                color: expense.isNeed ? Colors.blue : Colors.purple,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    expense.frequency,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCurrency(expense.getMonthlyAmount()),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade700,
                  ),
                ),
                Text(
                  '/month',
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                ),
              ],
            ),
            if (widget.user.isAdmin) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _deleteExpense(expense),
                child: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade300),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatCategoryName(String category) {
    return category.replaceAll('_', ' ').split(' ').map((word) =>
      word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : ''
    ).join(' ');
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'FOOD': return Icons.restaurant;
      case 'UTILITIES': return Icons.power;
      case 'TRANSPORTATION': return Icons.directions_car;
      case 'EDUCATION': return Icons.school;
      case 'HEALTHCARE': return Icons.local_hospital;
      case 'ENTERTAINMENT': return Icons.movie;
      case 'SHOPPING': return Icons.shopping_bag;
      case 'HOUSING': return Icons.home;
      case 'INSURANCE': return Icons.health_and_safety;
      case 'LOAN_EMI': return Icons.account_balance;
      case 'SAVINGS': return Icons.savings;
      default: return Icons.receipt;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'FOOD': return Colors.orange;
      case 'UTILITIES': return Colors.blue;
      case 'TRANSPORTATION': return Colors.green;
      case 'EDUCATION': return Colors.purple;
      case 'HEALTHCARE': return Colors.red;
      case 'ENTERTAINMENT': return Colors.pink;
      case 'SHOPPING': return Colors.teal;
      case 'HOUSING': return Colors.brown;
      case 'INSURANCE': return Colors.indigo;
      case 'LOAN_EMI': return Colors.deepOrange;
      case 'SAVINGS': return Colors.green.shade700;
      default: return Colors.grey;
    }
  }

  Widget _buildExpenseCard(Expense expense) {
    return _financialCard(
      icon: Icons.receipt_long,
      iconColor: Colors.orange,
      title: expense.name,
      subtitle: '${expense.category} • ${expense.frequency}',
      amount: expense.getMonthlyAmount(),
      rawAmount: expense.amount,
      badge: expense.isNeed
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.priority_high, size: 14, color: Colors.blue.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Need',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_outline, size: 14, color: Colors.purple.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Want',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                ],
              ),
            ),
      actions: widget.user.isAdmin
          ? [
        _action('Edit', Icons.edit, Colors.orange, () => _editExpense(expense)),
        _action('Delete', Icons.delete, Colors.red, () => _deleteExpense(expense)),
      ]
          : null,
    );
  }

  // ---------------- COMMON CARD ----------------

  Widget _financialCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required double amount,
    required double rawAmount,
    Widget? badge,
    List<Widget>? actions,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: iconColor.withAlpha(20),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(subtitle, style: TextStyle(color: AppTheme.textMedium, fontSize: 12)),
                    if (badge != null) ...[
                      const SizedBox(height: 6),
                      badge,
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_formatCurrency(rawAmount),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${_formatCurrency(amount)}/mo',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMedium)),
                ],
              ),
            ],
          ),
          if (actions != null) ...[
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: actions),
          ]
        ],
      ),
    );
  }

  Widget _action(String label, IconData icon, Color color, VoidCallback onTap) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(foregroundColor: color),
    );
  }

  Widget _emptyState(IconData icon, String text, VoidCallback action) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(text),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: action,
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // ---------------- ACTIONS ----------------

  void _addIncome() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const IncomeFormScreen()),
    );
    if (result == true) _loadData();
  }

  void _editIncome(Income income) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => IncomeFormScreen(income: income)),
    );
    if (result == true) _loadData();
  }

  void _deleteIncome(Income income) async {
    await ApiService.deleteIncome(income.id!);
    _loadData();
  }

  void _addExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExpenseFormScreen()),
    );
    if (result == true) _loadData();
  }

  void _editExpense(Expense expense) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ExpenseFormScreen(expense: expense)),
    );
    if (result == true) _loadData();
  }

  void _deleteExpense(Expense expense) async {
    await ApiService.deleteExpense(expense.id!);
    _loadData();
  }

  // ---------------- BUILD ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Flow'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Income'), Tab(text: 'Expenses')],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : Column(
        children: [
          _buildSummaryCard(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildIncomeList(), _buildExpenseList()],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
        _tabController.index == 0 ? _addIncome() : _addExpense(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
