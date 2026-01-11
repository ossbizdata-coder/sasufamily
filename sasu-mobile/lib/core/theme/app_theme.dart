/// AppTheme
///
/// Design goals:
/// - Calm, premium, reassuring look
/// - Soft greens and blues
/// - Light background
/// - Rounded cards (radius 20+)
/// - Subtle shadows
/// - Google Font: Poppins
///
/// Avoid:
/// - Harsh red colors
/// - Dense layouts
/// - Small fonts
///
/// Theme must support:
/// - Dashboard cards
/// - Charts
/// - Readable large numbers

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Calm, premium colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color creamBackground = Color(0xFFFAFAFA);
  static const Color cardWhite = Color(0xFFFFFFFF);

  // Text colors
  static const Color textDark = Color(0xFF212121);
  static const Color textMedium = Color(0xFF757575);
  static const Color textLight = Color(0xFF9E9E9E);

  // Accent colors
  static const Color gold = Color(0xFFFFC107);
  static const Color softOrange = Color(0xFFFF9800);

  // Status colors (calm versions)
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  static const Color neutral = Color(0xFF9E9E9E);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryGreen,
      secondary: primaryBlue,
      surface: cardWhite,
      background: creamBackground,
    ),
    scaffoldBackgroundColor: creamBackground,

    // Typography
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textDark,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textDark,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: textDark,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: textMedium,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        color: textLight,
      ),
    ),

    // Card theme
    cardTheme: CardTheme(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: cardWhite,
    ),

    // App bar theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: creamBackground,
      foregroundColor: textDark,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
    ),

    // Icon theme
    iconTheme: const IconThemeData(
      color: primaryGreen,
      size: 24,
    ),
  );

  // Gradient decorations
  static LinearGradient greenGradient = const LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient blueGradient = const LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient goldGradient = const LinearGradient(
    colors: [Color(0xFFFFC107), Color(0xFFFFD54F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

