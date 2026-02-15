/// Liability Model
///
/// Represents financial obligations
/// Used for net worth calculation and monthly burden analysis
/// UI should never feel scary - supports calm presentation
///
/// Supports automatic remaining balance calculation based on:
/// - Monthly payments and start date
/// - Interest rate

import '../../core/utils/value_calculator.dart';

class Liability {
  final int? id;
  final String name;
  final String type;
  final double originalAmount;
  final double remainingAmount; // Base remaining amount (may be auto-calculated)
  final double? monthlyPayment;
  final double? interestRate;
  final String? startDate;
  final String? endDate;
  final String? description;
  final bool active;
  final bool autoCalculate; // If true, remaining amount is calculated automatically

  Liability({
    this.id,
    required this.name,
    required this.type,
    required this.originalAmount,
    required this.remainingAmount,
    this.monthlyPayment,
    this.interestRate,
    this.startDate,
    this.endDate,
    this.description,
    this.active = true,
    this.autoCalculate = false,
  });

  /// Get the start date as DateTime
  DateTime? get startDateAsDateTime {
    if (startDate != null) {
      try {
        // Try ISO format first (YYYY-MM-DD)
        return DateTime.parse(startDate!);
      } catch (_) {
        // Try DD/MM/YYYY format
        try {
          final parts = startDate!.split('/');
          if (parts.length == 3) {
            return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          }
        } catch (_) {}
        // Try DD-MM-YYYY format
        try {
          final parts = startDate!.split('-');
          if (parts.length == 3 && parts[0].length == 2) {
            return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          }
        } catch (_) {}
      }
    }
    return null;
  }

  /// Get the current liability status with auto-calculation
  LiabilityStatus? get calculatedStatus {
    if (!autoCalculate) return null;

    final start = startDateAsDateTime;
    if (start == null || monthlyPayment == null || monthlyPayment! <= 0) {
      return null;
    }

    return ValueCalculator.calculateLiabilityStatus(
      originalAmount: originalAmount,
      interestRate: interestRate ?? 0,
      monthlyPayment: monthlyPayment!,
      startDate: start,
    );
  }

  /// Get the calculated remaining amount
  double get calculatedRemainingAmount {
    if (!autoCalculate) {
      return remainingAmount;
    }

    final status = calculatedStatus;
    if (status == null) {
      return remainingAmount;
    }

    return status.remainingAmount;
  }

  /// Get total amount paid so far
  double get totalPaid {
    final status = calculatedStatus;
    if (status == null) {
      return originalAmount - remainingAmount;
    }
    return status.totalPaid;
  }

  /// Get total interest paid so far
  double get totalInterestPaid {
    final status = calculatedStatus;
    return status?.totalInterestPaid ?? 0;
  }

  /// Get months remaining
  int get monthsRemaining {
    final status = calculatedStatus;
    return status?.monthsRemaining ?? _estimateMonthsRemaining();
  }

  /// Estimate months remaining based on simple calculation
  int _estimateMonthsRemaining() {
    if (monthlyPayment == null || monthlyPayment! <= 0) return -1;
    return (remainingAmount / monthlyPayment!).ceil();
  }

  /// Get formatted time remaining
  String get remainingTimeFormatted {
    final status = calculatedStatus;
    if (status != null) {
      return status.remainingTimeFormatted;
    }

    final months = _estimateMonthsRemaining();
    if (months < 0) return 'Unknown';

    final years = months ~/ 12;
    final remainingMonths = months % 12;

    if (years > 0 && remainingMonths > 0) {
      return '$years yr $remainingMonths mo';
    } else if (years > 0) {
      return '$years years';
    } else {
      return '$remainingMonths months';
    }
  }

  /// Get progress percentage (0.0 to 1.0)
  double get progressPercent {
    if (originalAmount <= 0) return 1.0;
    final remaining = calculatedRemainingAmount;
    return ((originalAmount - remaining) / originalAmount).clamp(0.0, 1.0);
  }

  /// Check if liability is fully paid
  bool get isFullyPaid {
    final status = calculatedStatus;
    if (status != null) {
      return status.isFullyPaid;
    }
    return calculatedRemainingAmount <= 0;
  }

  factory Liability.fromJson(Map<String, dynamic> json) {
    return Liability(
      id: json['id'],
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      originalAmount: (json['originalAmount'] ?? 0).toDouble(),
      remainingAmount: (json['remainingAmount'] ?? 0).toDouble(),
      monthlyPayment: json['monthlyPayment']?.toDouble(),
      interestRate: json['interestRate']?.toDouble(),
      startDate: json['startDate'],
      endDate: json['endDate'],
      description: json['description'],
      active: json['active'] ?? true,
      autoCalculate: json['autoCalculate'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'originalAmount': originalAmount,
      'remainingAmount': remainingAmount,
      'monthlyPayment': monthlyPayment,
      'interestRate': interestRate,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
      'active': active,
      'autoCalculate': autoCalculate,
    };
  }

  /// Create a copy with updated fields
  Liability copyWith({
    int? id,
    String? name,
    String? type,
    double? originalAmount,
    double? remainingAmount,
    double? monthlyPayment,
    double? interestRate,
    String? startDate,
    String? endDate,
    String? description,
    bool? active,
    bool? autoCalculate,
  }) {
    return Liability(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      originalAmount: originalAmount ?? this.originalAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      interestRate: interestRate ?? this.interestRate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      active: active ?? this.active,
      autoCalculate: autoCalculate ?? this.autoCalculate,
    );
  }
}
