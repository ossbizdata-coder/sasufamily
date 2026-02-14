/// SaSu Family Wealth Dashboard
///
/// Main application entry point
///
/// A calm, motivating family financial planning app

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'data/services/api_service.dart';
import 'features/assets/asset_form_screen.dart';
import 'features/assets/assets_screen.dart';
import 'features/liabilities/liability_form_screen.dart';
import 'features/liabilities/liabilities_screen.dart';
import 'features/insurance/insurance_form_screen.dart';
import 'features/insurance/insurance_screen.dart';
import 'features/income_expense/income_expense_screen.dart';
import 'features/dashboard/financial_projection_screen.dart';
import 'features/liquidity/liquidity_screen.dart';
import 'features/investments/investment_efficiency_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API service
  await ApiService.init();

  runApp(const SaSuApp());
}

class SaSuApp extends StatelessWidget {
  const SaSuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaSu - Family Wealth Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
      routes: {
        '/assets': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map && args['user'] != null) {
            return AssetsScreen(user: args['user']);
          }
          return const LoginScreen();
        },
        '/liabilities': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map && args['user'] != null) {
            return LiabilitiesScreen(user: args['user']);
          }
          return const LoginScreen();
        },
        '/insurance': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map && args['user'] != null) {
            return InsuranceScreen(user: args['user']);
          }
          return const LoginScreen();
        },
        '/addAsset': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map && args['asset'] != null) {
            return AssetFormScreen(asset: args['asset']);
          }
          return const AssetFormScreen();
        },
        '/assetForm': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map<String, dynamic>) {
            return AssetFormScreen(asset: args);
          }
          return const AssetFormScreen();
        },
        '/addLiability': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map && args['liability'] != null) {
            return LiabilityFormScreen(liability: args['liability']);
          }
          return const LiabilityFormScreen();
        },
        '/addInsurance': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map && args['insurance'] != null) {
            return InsuranceFormScreen(insurance: args['insurance']);
          }
          return const InsuranceFormScreen();
        },
        '/incomeExpense': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map && args['user'] != null) {
            return IncomeExpenseScreen(user: args['user']);
          }
          // This shouldn't happen if properly called from dashboard
          return const LoginScreen();
        },
        '/liquidity': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map && args['user'] != null) {
            return LiquidityScreen(user: args['user']);
          }
          return const LoginScreen();
        },
        '/financialProjection': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map && args['user'] != null) {
            return FinancialProjectionScreen(user: args['user']);
          }
          return const LoginScreen();
        },
        '/investment-efficiency': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map && args['user'] != null) {
            return InvestmentEfficiencyScreen(user: args['user']);
          }
          return const LoginScreen();
        },
      },
    );
  }
}
