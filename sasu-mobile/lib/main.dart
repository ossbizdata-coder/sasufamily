/// SaSu Family Wealth Dashboard
///
/// Main application entry point
///
/// A calm, motivating family financial planning app

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'data/services/api_service.dart';

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
    );
  }
}

