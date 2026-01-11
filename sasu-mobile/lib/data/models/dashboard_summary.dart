/// Dashboard Summary Model
///
/// Complete family financial health overview
/// Used by main dashboard screen

class DashboardSummary {
  final double totalAssets;
  final double totalLiabilities;
  final double netWorth;
  final double totalInsuranceCoverage;
  final double totalMonthlyBurden;
  final int wealthHealthScore;
  final String wealthHealthLabel;
  final String futureReadinessStatus;
  final List<AssetSummary> assetsByType;
  final List<LiabilitySummary> liabilitiesByType;
  final int totalInsurancePolicies;
  final String motivationalMessage;

  DashboardSummary({
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
    required this.totalInsuranceCoverage,
    required this.totalMonthlyBurden,
    required this.wealthHealthScore,
    required this.wealthHealthLabel,
    required this.futureReadinessStatus,
    required this.assetsByType,
    required this.liabilitiesByType,
    required this.totalInsurancePolicies,
    required this.motivationalMessage,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalAssets: (json['totalAssets'] ?? 0).toDouble(),
      totalLiabilities: (json['totalLiabilities'] ?? 0).toDouble(),
      netWorth: (json['netWorth'] ?? 0).toDouble(),
      totalInsuranceCoverage: (json['totalInsuranceCoverage'] ?? 0).toDouble(),
      totalMonthlyBurden: (json['totalMonthlyBurden'] ?? 0).toDouble(),
      wealthHealthScore: json['wealthHealthScore'] ?? 0,
      wealthHealthLabel: json['wealthHealthLabel'] ?? '',
      futureReadinessStatus: json['futureReadinessStatus'] ?? '',
      assetsByType: (json['assetsByType'] as List?)
              ?.map((e) => AssetSummary.fromJson(e))
              .toList() ??
          [],
      liabilitiesByType: (json['liabilitiesByType'] as List?)
              ?.map((e) => LiabilitySummary.fromJson(e))
              .toList() ??
          [],
      totalInsurancePolicies: json['totalInsurancePolicies'] ?? 0,
      motivationalMessage: json['motivationalMessage'] ?? '',
    );
  }
}

class AssetSummary {
  final String type;
  final int count;
  final double totalValue;

  AssetSummary({
    required this.type,
    required this.count,
    required this.totalValue,
  });

  factory AssetSummary.fromJson(Map<String, dynamic> json) {
    return AssetSummary(
      type: json['type'] ?? '',
      count: json['count'] ?? 0,
      totalValue: (json['totalValue'] ?? 0).toDouble(),
    );
  }
}

class LiabilitySummary {
  final String type;
  final int count;
  final double totalRemaining;
  final double monthlyBurden;

  LiabilitySummary({
    required this.type,
    required this.count,
    required this.totalRemaining,
    required this.monthlyBurden,
  });

  factory LiabilitySummary.fromJson(Map<String, dynamic> json) {
    return LiabilitySummary(
      type: json['type'] ?? '',
      count: json['count'] ?? 0,
      totalRemaining: (json['totalRemaining'] ?? 0).toDouble(),
      monthlyBurden: (json['monthlyBurden'] ?? 0).toDouble(),
    );
  }
}

