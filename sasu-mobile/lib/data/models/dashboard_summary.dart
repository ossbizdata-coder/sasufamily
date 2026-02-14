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
  final double monthlyIncome;
  final double monthlyExpenses;
  final int wealthHealthScore;
  final String wealthHealthLabel;
  final String futureReadinessStatus;
  final ScoreBreakdown? scoreBreakdown;
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
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.wealthHealthScore,
    required this.wealthHealthLabel,
    required this.futureReadinessStatus,
    this.scoreBreakdown,
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
      monthlyIncome: (json['monthlyIncome'] ?? 0).toDouble(),
      monthlyExpenses: (json['monthlyExpenses'] ?? 0).toDouble(),
      wealthHealthScore: json['wealthHealthScore'] ?? 0,
      wealthHealthLabel: json['wealthHealthLabel'] ?? '',
      futureReadinessStatus: json['futureReadinessStatus'] ?? '',
      scoreBreakdown: json['scoreBreakdown'] != null
          ? ScoreBreakdown.fromJson(json['scoreBreakdown'])
          : null,
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

class ScoreBreakdown {
  // 1. Net Worth Growth (25 points max)
  final int netWorthScore;
  final String netWorthStatus;
  final double netWorthValue;

  // 2. Cash Flow Health (20 points max)
  final int cashFlowScore;
  final String cashFlowStatus;
  final double savingsRate;
  final double monthlySurplus;

  // 3. Debt Health (15 points max)
  final int debtScore;
  final String debtStatus;
  final double debtToIncomeRatio;
  final double debtRatio;

  // 4. Liquidity (15 points max)
  final int liquidityScore;
  final String liquidityStatus;
  final double emergencyFundMonths;
  final double liquidAssets;

  // 5. Investment Efficiency (15 points max)
  final int investmentScore;
  final String investmentStatus;
  final double investmentRatio;
  final double totalInvestments;

  // 6. Protection (10 points max)
  final int protectionScore;
  final String protectionStatus;
  final double coverageRatio;
  final bool hasHealthInsurance;
  final bool hasLifeInsurance;

  ScoreBreakdown({
    required this.netWorthScore,
    required this.netWorthStatus,
    required this.netWorthValue,
    required this.cashFlowScore,
    required this.cashFlowStatus,
    required this.savingsRate,
    required this.monthlySurplus,
    required this.debtScore,
    required this.debtStatus,
    required this.debtToIncomeRatio,
    required this.debtRatio,
    required this.liquidityScore,
    required this.liquidityStatus,
    required this.emergencyFundMonths,
    required this.liquidAssets,
    required this.investmentScore,
    required this.investmentStatus,
    required this.investmentRatio,
    required this.totalInvestments,
    required this.protectionScore,
    required this.protectionStatus,
    required this.coverageRatio,
    required this.hasHealthInsurance,
    required this.hasLifeInsurance,
  });

  factory ScoreBreakdown.fromJson(Map<String, dynamic> json) {
    return ScoreBreakdown(
      netWorthScore: json['netWorthScore'] ?? 0,
      netWorthStatus: json['netWorthStatus'] ?? '',
      netWorthValue: (json['netWorthValue'] ?? 0).toDouble(),
      cashFlowScore: json['cashFlowScore'] ?? 0,
      cashFlowStatus: json['cashFlowStatus'] ?? '',
      savingsRate: (json['savingsRate'] ?? 0).toDouble(),
      monthlySurplus: (json['monthlySurplus'] ?? 0).toDouble(),
      debtScore: json['debtScore'] ?? 0,
      debtStatus: json['debtStatus'] ?? '',
      debtToIncomeRatio: (json['debtToIncomeRatio'] ?? 0).toDouble(),
      debtRatio: (json['debtRatio'] ?? 0).toDouble(),
      liquidityScore: json['liquidityScore'] ?? 0,
      liquidityStatus: json['liquidityStatus'] ?? '',
      emergencyFundMonths: (json['emergencyFundMonths'] ?? 0).toDouble(),
      liquidAssets: (json['liquidAssets'] ?? 0).toDouble(),
      investmentScore: json['investmentScore'] ?? 0,
      investmentStatus: json['investmentStatus'] ?? '',
      investmentRatio: (json['investmentRatio'] ?? 0).toDouble(),
      totalInvestments: (json['totalInvestments'] ?? 0).toDouble(),
      protectionScore: json['protectionScore'] ?? 0,
      protectionStatus: json['protectionStatus'] ?? '',
      coverageRatio: (json['coverageRatio'] ?? 0).toDouble(),
      hasHealthInsurance: json['hasHealthInsurance'] ?? false,
      hasLifeInsurance: json['hasLifeInsurance'] ?? false,
    );
  }
}

