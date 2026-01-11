/// Asset Model
///
/// Represents a family-owned asset like land, investment, or savings
/// Used for calculating net worth

class Asset {
  final int? id;
  final String name;
  final String type;
  final double currentValue;
  final double? purchaseValue;
  final int? purchaseYear;
  final String? description;
  final double? yearlyGrowthRate;
  final String? lastUpdated;
  final bool active;

  Asset({
    this.id,
    required this.name,
    required this.type,
    required this.currentValue,
    this.purchaseValue,
    this.purchaseYear,
    this.description,
    this.yearlyGrowthRate,
    this.lastUpdated,
    this.active = true,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'],
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      currentValue: (json['currentValue'] ?? 0).toDouble(),
      purchaseValue: json['purchaseValue']?.toDouble(),
      purchaseYear: json['purchaseYear'],
      description: json['description'],
      yearlyGrowthRate: json['yearlyGrowthRate']?.toDouble(),
      lastUpdated: json['lastUpdated'],
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'currentValue': currentValue,
      'purchaseValue': purchaseValue,
      'purchaseYear': purchaseYear,
      'description': description,
      'yearlyGrowthRate': yearlyGrowthRate,
      'lastUpdated': lastUpdated,
      'active': active,
    };
  }
}

