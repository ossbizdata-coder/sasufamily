import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/services/exchange_rate_service.dart';

/// Exchange Rate Settings Screen
///
/// Allows users to update the USD to LKR exchange rate

class ExchangeRateScreen extends StatefulWidget {
  const ExchangeRateScreen({Key? key}) : super(key: key);

  @override
  State<ExchangeRateScreen> createState() => _ExchangeRateScreenState();
}

class _ExchangeRateScreenState extends State<ExchangeRateScreen> {
  final _rateController = TextEditingController();
  double _currentRate = ExchangeRateService.defaultUsdToLkr;
  DateTime? _lastUpdated;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentRate();
  }

  Future<void> _loadCurrentRate() async {
    final rate = await ExchangeRateService.getUsdToLkrRate();
    final lastUpdated = await ExchangeRateService.getLastUpdated();
    setState(() {
      _currentRate = rate;
      _lastUpdated = lastUpdated;
      _rateController.text = rate.toStringAsFixed(2);
      _isLoading = false;
    });
  }

  Future<void> _saveRate() async {
    final newRate = double.tryParse(_rateController.text);
    if (newRate == null || newRate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid exchange rate'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await ExchangeRateService.setUsdToLkrRate(newRate);
    setState(() {
      _currentRate = newRate;
      _lastUpdated = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exchange rate updated to Rs. ${newRate.toStringAsFixed(2)} per USD'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true); // Return true to indicate rate was updated
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchange Rate'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Current Rate Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.shade600,
                          Colors.amber.shade800,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withAlpha(50),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.currency_exchange, color: Colors.white, size: 28),
                            SizedBox(width: 8),
                            Text(
                              'Current Rate',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              '\$1 = ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Rs. ${_currentRate.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (_lastUpdated != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Last updated: ${DateFormat('MMM d, yyyy h:mm a').format(_lastUpdated!)}',
                            style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Update Rate Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(20),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.edit, color: Colors.grey.shade600, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Update Exchange Rate',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                                border: Border.all(color: Colors.amber.shade200),
                              ),
                              child: Text(
                                '\$1 =',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber.shade800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _rateController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  prefixText: 'Rs. ',
                                  border: OutlineInputBorder(
                                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                ),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _saveRate,
                            icon: const Icon(Icons.save),
                            label: const Text('Save Rate'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.amber.shade700,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'How to get the latest rate',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Check the current USD/LKR rate from:\n'
                                '• Google: Search "USD to LKR"\n'
                                '• Central Bank of Sri Lanka\n'
                                '• Your bank\'s exchange rates',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue.shade700,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Example Conversion
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Example Conversions',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildConversionExample(100),
                        const SizedBox(height: 8),
                        _buildConversionExample(500),
                        const SizedBox(height: 8),
                        _buildConversionExample(1000),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildConversionExample(double usdAmount) {
    final rate = double.tryParse(_rateController.text) ?? _currentRate;
    final lkrAmount = usdAmount * rate;
    final formatter = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'USD ${usdAmount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Icon(Icons.arrow_forward, size: 16, color: Colors.grey.shade400),
        Text(
          formatter.format(lkrAmount),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}

