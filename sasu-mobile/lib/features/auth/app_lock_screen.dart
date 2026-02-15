import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';
import '../../data/services/pin_service.dart';
import '../../core/theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';
import 'login_screen.dart';
import 'pin_screen.dart';

/// App Lock Screen
///
/// Entry point that checks:
/// 1. If user is logged in (has valid JWT)
/// 2. If PIN lock is enabled
///
/// Routing:
/// - Not logged in → Login Screen
/// - Logged in + PIN enabled → PIN Screen → Dashboard
/// - Logged in + No PIN → Dashboard (with option to set up PIN)
class AppLockScreen extends StatefulWidget {
  const AppLockScreen({Key? key}) : super(key: key);

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> with WidgetsBindingObserver {
  bool _isLoading = true;
  bool _showPinSetup = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuthState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app comes back to foreground, check if PIN is required
    if (state == AppLifecycleState.resumed) {
      _checkAuthState();
    }
  }

  Future<void> _checkAuthState() async {
    setState(() => _isLoading = true);

    try {
      // Check if user is logged in
      final isLoggedIn = await ApiService.isLoggedIn();

      if (!isLoggedIn) {
        // Not logged in, go to login screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
        return;
      }

      // User is logged in, check PIN status
      final isPinSetUp = await PinService.isPinSetUp();

      if (isPinSetUp) {
        // PIN is set up, show PIN screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PinScreen(
                mode: PinMode.unlock,
                onSuccess: () => _navigateToDashboard(),
              ),
            ),
          );
        }
      } else {
        // No PIN, offer to set up
        setState(() {
          _isLoading = false;
          _showPinSetup = true;
        });
      }
    } catch (e) {
      // Error, go to login
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  Future<void> _navigateToDashboard() async {
    try {
      final user = await ApiService.getCurrentUser();
      if (mounted && user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => DashboardScreen(user: user)),
        );
      } else {
        // No user, go to login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _setupPin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PinScreen(
          mode: PinMode.setup,
          onSuccess: () {
            Navigator.of(context).pop();
            _navigateToDashboard();
          },
        ),
      ),
    );
  }

  void _skipPinSetup() {
    _navigateToDashboard();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.primaryBlue,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'SaSu Family',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Wealth Dashboard',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withAlpha(180),
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    // PIN setup prompt
    if (_showPinSetup) {
      return Scaffold(
        backgroundColor: AppTheme.primaryBlue,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Secure Your App',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Set up a PIN to protect your financial data',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withAlpha(180),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _setupPin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Set Up PIN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'PIN is required to protect your financial data',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withAlpha(150),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

