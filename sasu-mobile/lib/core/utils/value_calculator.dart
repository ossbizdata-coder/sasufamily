/// Value Calculator Utility
///
/// Automatically calculates current values for assets and liabilities
/// based on time-based growth rates and payment schedules.
///
/// Features:
/// - Compound interest calculation for appreciating assets (EPF, Land, FD)
/// - Remaining balance calculation for liabilities
/// - Payment tracking and projection

import 'dart:math';

class ValueCalculator {
  /// Calculate the current value of an asset with compound growth
  ///
  /// [principalValue] - The initial/purchase value
  /// [yearlyGrowthRate] - Annual growth rate as percentage (e.g., 11 for 11%)
  /// [startDate] - When the asset was purchased/started
  /// [currentDate] - The date to calculate value for (defaults to now)
  ///
  /// Formula: A = P(1 + r)^t for annual compounding
  /// Where: P = principal, r = annual rate, t = time in years
  ///
  /// For partial years, we use proportional compounding:
  /// - Full years: compound interest
  /// - Partial year: proportional interest on the compounded amount
  static double calculateCompoundGrowth({
    required double principalValue,
    required double yearlyGrowthRate,
    required DateTime startDate,
    DateTime? currentDate,
    int compoundingFrequency = 1, // Annual compounding (like EPF)
  }) {
    currentDate ??= DateTime.now();

    if (startDate.isAfter(currentDate)) {
      return principalValue; // Future date, return principal
    }

    // Calculate full years and remaining months
    final daysDifference = currentDate.difference(startDate).inDays;
    final totalYears = daysDifference / 365.0;

    if (totalYears <= 0) {
      return principalValue;
    }

    // Convert percentage to decimal (11% -> 0.11)
    final rateDecimal = yearlyGrowthRate / 100;

    if (compoundingFrequency == 1) {
      // Annual compounding (EPF style)
      // Calculate full years compounded
      final fullYears = totalYears.floor();
      final partialYear = totalYears - fullYears;

      // Compound for full years: P * (1 + r)^n
      double amount = principalValue * pow(1 + rateDecimal, fullYears);

      // Add proportional interest for partial year
      // This simulates interest accruing but not yet credited
      if (partialYear > 0) {
        amount = amount * (1 + rateDecimal * partialYear);
      }

      return amount;
    } else {
      // Standard compound interest formula for other frequencies
      // A = P(1 + r/n)^(nt)
      final compoundFactor = pow(1 + (rateDecimal / compoundingFrequency),
                                  compoundingFrequency * totalYears);
      return principalValue * compoundFactor;
    }
  }

  /// Calculate remaining liability amount based on payments
  ///
  /// [originalAmount] - The original loan amount
  /// [interestRate] - Annual interest rate as percentage
  /// [monthlyPayment] - Fixed monthly payment amount
  /// [startDate] - Loan start date
  /// [currentDate] - Date to calculate remaining for
  static LiabilityStatus calculateLiabilityStatus({
    required double originalAmount,
    required double interestRate,
    required double monthlyPayment,
    required DateTime startDate,
    DateTime? currentDate,
  }) {
    currentDate ??= DateTime.now();

    if (startDate.isAfter(currentDate)) {
      return LiabilityStatus(
        remainingAmount: originalAmount,
        totalPaid: 0,
        totalInterestPaid: 0,
        monthsPaid: 0,
        monthsRemaining: _calculateTotalMonths(originalAmount, interestRate, monthlyPayment),
        isFullyPaid: false,
      );
    }

    // Calculate months elapsed
    final monthsElapsed = _monthsBetween(startDate, currentDate);

    // Monthly interest rate
    final monthlyRate = interestRate / 100 / 12;

    double balance = originalAmount;
    double totalInterestPaid = 0;
    double totalPrincipalPaid = 0;
    int monthsPaid = 0;

    // Simulate each month's payment
    for (int i = 0; i < monthsElapsed && balance > 0; i++) {
      final interestForMonth = balance * monthlyRate;
      final principalForMonth = monthlyPayment - interestForMonth;

      if (principalForMonth > 0) {
        balance -= principalForMonth;
        totalPrincipalPaid += principalForMonth;
      }
      totalInterestPaid += interestForMonth;
      monthsPaid++;

      if (balance <= 0) {
        balance = 0;
        break;
      }
    }

    // Calculate remaining months
    int monthsRemaining = 0;
    if (balance > 0 && monthlyPayment > 0) {
      double tempBalance = balance;
      while (tempBalance > 0 && monthsRemaining < 600) { // Max 50 years
        final interestForMonth = tempBalance * monthlyRate;
        final principalForMonth = monthlyPayment - interestForMonth;
        if (principalForMonth <= 0) {
          monthsRemaining = -1; // Payment too low to cover interest
          break;
        }
        tempBalance -= principalForMonth;
        monthsRemaining++;
      }
    }

    return LiabilityStatus(
      remainingAmount: balance.clamp(0, double.infinity),
      totalPaid: totalPrincipalPaid + totalInterestPaid,
      totalInterestPaid: totalInterestPaid,
      monthsPaid: monthsPaid,
      monthsRemaining: monthsRemaining,
      isFullyPaid: balance <= 0,
    );
  }

  /// Calculate months between two dates
  static int _monthsBetween(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + (end.month - start.month);
  }

  /// Calculate total months to pay off loan
  static int _calculateTotalMonths(double principal, double annualRate, double monthlyPayment) {
    if (monthlyPayment <= 0) return -1;

    final monthlyRate = annualRate / 100 / 12;
    if (monthlyRate == 0) {
      return (principal / monthlyPayment).ceil();
    }

    // Check if payment covers interest
    if (monthlyPayment <= principal * monthlyRate) {
      return -1; // Payment too low
    }

    // Formula: n = -log(1 - (P*r)/M) / log(1+r)
    final n = -log(1 - (principal * monthlyRate) / monthlyPayment) / log(1 + monthlyRate);
    return n.ceil();
  }

  /// Get default growth rate for asset type
  static double getDefaultGrowthRate(String assetType) {
    switch (assetType.toUpperCase()) {
      case 'EPF':
      case 'RETIREMENT_FUND':
        return 11.0; // 11% annual growth
      case 'LAND':
        return 8.0; // 8% annual appreciation
      case 'HOUSE':
        return 5.0; // 5% annual appreciation
      case 'FIXED_DEPOSIT':
        return 7.0; // 7% FD rate
      case 'SHARES':
        return 12.0; // 12% average stock market return
      case 'GOLD':
        return 6.0; // 6% gold appreciation
      case 'SAVINGS':
      case 'BANK_DEPOSIT':
        return 3.0; // 3% savings interest
      case 'VEHICLE':
        return -15.0; // Vehicles depreciate!
      default:
        return 0.0; // No growth for unknown types
    }
  }

  /// Format growth rate for display
  static String formatGrowthRate(double rate) {
    if (rate > 0) {
      return '+${rate.toStringAsFixed(1)}%/yr';
    } else if (rate < 0) {
      return '${rate.toStringAsFixed(1)}%/yr';
    }
    return 'Fixed';
  }

  /// Calculate projected value for a future date
  static double projectFutureValue({
    required double currentValue,
    required double yearlyGrowthRate,
    required int yearsAhead,
  }) {
    final rateDecimal = yearlyGrowthRate / 100;
    return currentValue * pow(1 + rateDecimal, yearsAhead);
  }
}

/// Status information for a liability
class LiabilityStatus {
  final double remainingAmount;
  final double totalPaid;
  final double totalInterestPaid;
  final int monthsPaid;
  final int monthsRemaining; // -1 if payment too low
  final bool isFullyPaid;

  LiabilityStatus({
    required this.remainingAmount,
    required this.totalPaid,
    required this.totalInterestPaid,
    required this.monthsPaid,
    required this.monthsRemaining,
    required this.isFullyPaid,
  });

  /// Get years and months remaining as formatted string
  String get remainingTimeFormatted {
    if (isFullyPaid) return 'Paid Off! 🎉';
    if (monthsRemaining < 0) return 'Payment too low';

    final years = monthsRemaining ~/ 12;
    final months = monthsRemaining % 12;

    if (years > 0 && months > 0) {
      return '$years yr $months mo';
    } else if (years > 0) {
      return '$years years';
    } else {
      return '$months months';
    }
  }

  /// Progress as percentage (0.0 to 1.0)
  double progressPercent(double originalAmount) {
    if (originalAmount <= 0) return 1.0;
    return ((originalAmount - remainingAmount) / originalAmount).clamp(0.0, 1.0);
  }
}

