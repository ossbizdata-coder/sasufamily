/// Asset Model
///
/// Represents a family-owned asset like land, investment, or savings
/// Used for calculating net worth
///
/// Supports automatic value calculation based on:
/// - Purchase value and date
/// - Yearly growth rate (compound interest)
/// - Currency conversion (USD to LKR)

import '../../core/utils/value_calculator.dart';
import '../services/exchange_rate_service.dart';

class Asset {
  final int? id;
  final String name;
  final String type;
  final double currentValue; // Base/purchase value for auto-growth assets
  final double? purchaseValue;
  final int? purchaseYear;
  final String? purchaseDate; // Full date for precise calculations (ISO 8601)
  final String? description;
  final double? yearlyGrowthRate; // Annual growth rate as percentage (e.g., 11 for 11%)
  final String? lastUpdated;
  final bool active;
  final bool isLiquid; // Can be converted to cash quickly (3-6 months)
  final bool isInvestment; // Generates returns or appreciates (used for Investment Efficiency)
  final bool autoGrowth; // If true, value is calculated automatically based on growth rate
  final String currency; // 'LKR' or 'USD'

  Asset({
    this.id,
    required this.name,
    required this.type,
    required this.currentValue,
    this.purchaseValue,
    this.purchaseYear,
    this.purchaseDate,
    this.description,
    this.yearlyGrowthRate,
    this.lastUpdated,
    this.active = true,
    this.isLiquid = false,
    this.isInvestment = false,
    this.autoGrowth = false,
    this.currency = 'LKR',
  });

  /// Check if this asset is in USD
  bool get isUSD => currency == 'USD';

  /// Get the value in LKR (converts if USD using current exchange rate)
  double get valueInLKR {
    final value = calculatedCurrentValue;
    return isUSD ? ExchangeRateService.convertUsdToLkr(value) : value;
  }

  /// Get the effective growth rate (uses default if not specified)
  double get effectiveGrowthRate {
    return yearlyGrowthRate ?? ValueCalculator.getDefaultGrowthRate(type);
  }

  /// Get the purchase date as DateTime
  DateTime? get purchaseDateAsDateTime {
    if (purchaseDate != null) {
      try {
        return DateTime.parse(purchaseDate!);
      } catch (_) {}
    }
    // Fallback to purchaseYear if available
    if (purchaseYear != null) {
      return DateTime(purchaseYear!, 1, 1);
    }
    return null;
  }

  /// Calculate the current value based on compound growth
  /// This is the KEY method that auto-adjusts values based on time
  double get calculatedCurrentValue {
    // If auto-growth is disabled or no start date, return stored value
    if (!autoGrowth) {
      return currentValue;
    }

    final startDate = purchaseDateAsDateTime;
    if (startDate == null) {
      return currentValue;
    }

    final baseValue = purchaseValue ?? currentValue;
    final growthRate = effectiveGrowthRate;

    // If no growth rate or zero, return base value
    if (growthRate == 0) {
      return baseValue;
    }

    final result = ValueCalculator.calculateCompoundGrowth(
      principalValue: baseValue,
      yearlyGrowthRate: growthRate,
      startDate: startDate,
    );

    return result;
  }

  /// Get the total gain/loss since purchase
  double get totalGain {
    final baseValue = purchaseValue ?? currentValue;
    return calculatedCurrentValue - baseValue;
  }

  /// Get the gain/loss as a percentage
  double get gainPercentage {
    final baseValue = purchaseValue ?? currentValue;
    if (baseValue <= 0) return 0;
    return (totalGain / baseValue) * 100;
  }

  /// Project value for a future number of years
  double projectValue(int yearsAhead) {
    return ValueCalculator.projectFutureValue(
      currentValue: calculatedCurrentValue,
      yearlyGrowthRate: effectiveGrowthRate,
      yearsAhead: yearsAhead,
    );
  }

  factory Asset.fromJson(Map<String, dynamic> json) {
    // Debug: print received JSON to see what backend is sending
    final currency = json['currency'] ?? 'LKR';
    print('Asset.fromJson [${json['name']}]: currency=$currency, isUSD=${currency == 'USD'}');

    return Asset(
      id: json['id'],
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      currentValue: (json['currentValue'] ?? 0).toDouble(),
      purchaseValue: json['purchaseValue']?.toDouble(),
      purchaseYear: json['purchaseYear'],
      purchaseDate: json['purchaseDate'],
      description: json['description'],
      yearlyGrowthRate: json['yearlyGrowthRate']?.toDouble(),
      lastUpdated: json['lastUpdated'],
      active: json['active'] ?? true,
      isLiquid: json['isLiquid'] ?? false,
      isInvestment: json['isInvestment'] ?? false,
      autoGrowth: json['autoGrowth'] ?? false,
      currency: currency,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'name': name,
      'type': type,
      'currentValue': currentValue,
      'purchaseValue': purchaseValue,
      'purchaseYear': purchaseYear,
      'purchaseDate': purchaseDate,
      'description': description,
      'yearlyGrowthRate': yearlyGrowthRate,
      'lastUpdated': lastUpdated,
      'active': active,
      'isLiquid': isLiquid,
      'isInvestment': isInvestment,
      'autoGrowth': autoGrowth,
      'currency': currency,
    };
    // Debug: print what we're sending
    print('Asset.toJson: autoGrowth=$autoGrowth, currency=$currency');
    return json;
  }

  /// Create a copy with updated fields
  Asset copyWith({
    int? id,
    String? name,
    String? type,
    double? currentValue,
    double? purchaseValue,
    int? purchaseYear,
    String? purchaseDate,
    String? description,
    double? yearlyGrowthRate,
    String? lastUpdated,
    bool? active,
    bool? isLiquid,
    bool? isInvestment,
    bool? autoGrowth,
    String? currency,
  }) {
    return Asset(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currentValue: currentValue ?? this.currentValue,
      purchaseValue: purchaseValue ?? this.purchaseValue,
      purchaseYear: purchaseYear ?? this.purchaseYear,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      description: description ?? this.description,
      yearlyGrowthRate: yearlyGrowthRate ?? this.yearlyGrowthRate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      active: active ?? this.active,
      isLiquid: isLiquid ?? this.isLiquid,
      isInvestment: isInvestment ?? this.isInvestment,
      autoGrowth: autoGrowth ?? this.autoGrowth,
      currency: currency ?? this.currency,
    );
  }
}
