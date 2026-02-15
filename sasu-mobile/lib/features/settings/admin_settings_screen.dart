import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/services/exchange_rate_service.dart';
import '../../data/services/pin_service.dart';
import '../../data/models/user.dart';
import '../auth/pin_screen.dart';

/// Admin Settings Screen
///
/// Configuration page for admin users to manage app settings

class AdminSettingsScreen extends StatefulWidget {
  final User user;

  const AdminSettingsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _rateController = TextEditingController();
  double _currentRate = ExchangeRateService.defaultUsdToLkr;
  DateTime? _lastUpdated;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isPinEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final rate = await ExchangeRateService.getUsdToLkrRate();
    final lastUpdated = await ExchangeRateService.getLastUpdated();
    final isPinEnabled = await PinService.isPinSetUp();
    setState(() {
      _currentRate = rate;
      _lastUpdated = lastUpdated;
      _rateController.text = rate.toStringAsFixed(2);
      _isPinEnabled = isPinEnabled;
      _isLoading = false;
    });
  }

  Future<void> _saveExchangeRate() async {
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

    setState(() => _isSaving = true);

    final success = await ExchangeRateService.setUsdToLkrRate(newRate);

    setState(() => _isSaving = false);

    if (success) {
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update exchange rate. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        title: const Text('Admin Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Admin Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.indigo.shade600,
                        Colors.indigo.shade800,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withAlpha(40),
                        child: const Icon(Icons.admin_panel_settings, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Administrator',
                            style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section: Currency Settings
                _buildSectionHeader('Currency Settings', Icons.currency_exchange),
                const SizedBox(height: 12),

                // Exchange Rate Card
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'USD to LKR Rate',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              if (_lastUpdated != null)
                                Text(
                                  'Updated: ${DateFormat('MMM d, h:mm a').format(_lastUpdated!)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Text(
                              '\$1 = Rs. ${_currentRate.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                            ),
                            child: const Text('\$1 =', style: TextStyle(fontWeight: FontWeight.w600)),
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
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _isSaving ? null : _saveExchangeRate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            child: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Save'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'USD assets will be converted using this rate',
                                style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section: Security
                _buildSectionHeader('Security', Icons.security),
                const SizedBox(height: 12),

                _buildPinSettingsTile(),

                const SizedBox(height: 24),

                // Section: App Info
                _buildSectionHeader('App Information', Icons.info_outline),
                const SizedBox(height: 12),

                _buildInfoTile('App Version', '1.0.0'),
                _buildInfoTile('Data Storage', 'Local + Cloud Sync'),
                _buildInfoTile('Last Sync', DateFormat('MMM d, yyyy h:mm a').format(DateTime.now())),

                const SizedBox(height: 24),

                // Future Settings Placeholder
                _buildSectionHeader('More Settings', Icons.settings),
                const SizedBox(height: 12),

                _buildComingSoonTile('Notification Preferences'),
                _buildComingSoonTile('Data Export'),
                _buildComingSoonTile('Family Member Management'),
                _buildComingSoonTile('Backup & Restore'),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildComingSoonTile(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade500)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Coming Soon',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinSettingsTile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // PIN Lock Toggle
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isPinEnabled ? Colors.green.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _isPinEnabled ? Icons.lock : Icons.lock_open,
                  color: _isPinEnabled ? Colors.green.shade700 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'App Lock',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      _isPinEnabled ? 'PIN protection enabled' : 'No PIN set',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isPinEnabled,
                onChanged: (value) async {
                  if (value) {
                    // Enable PIN - navigate to setup
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PinScreen(
                          mode: PinMode.setup,
                          onSuccess: () => Navigator.pop(context, true),
                        ),
                      ),
                    );
                    if (result == true) {
                      setState(() => _isPinEnabled = true);
                    }
                  } else {
                    // Disable PIN
                    await PinService.disablePin();
                    setState(() => _isPinEnabled = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PIN lock disabled')),
                    );
                  }
                },
                activeColor: Colors.green,
              ),
            ],
          ),

          // Change PIN button (only show if PIN is enabled)
          if (_isPinEnabled) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PinScreen(
                      mode: PinMode.change,
                      onSuccess: () => Navigator.pop(context, true),
                    ),
                  ),
                );
                if (result == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PIN changed successfully')),
                  );
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Text(
                      'Change PIN',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

