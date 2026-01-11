/// Insurance Model
///
/// Represents an insurance policy and its future benefit
/// Used to calculate family protection and future maturity values

class Insurance {
  final int? id;
  final String policyName;
  final String type;
  final String provider;
  final double coverageAmount;
  final double? premiumAmount;
  final String? premiumFrequency;
  final String? startDate;
  final int? maturityYear;
  final double? maturityBenefit;
  final String beneficiary;
  final String? description;
  final bool active;

  Insurance({
    this.id,
    required this.policyName,
    required this.type,
    required this.provider,
    required this.coverageAmount,
    this.premiumAmount,
    this.premiumFrequency,
    this.startDate,
    this.maturityYear,
    this.maturityBenefit,
    required this.beneficiary,
    this.description,
    this.active = true,
  });

  factory Insurance.fromJson(Map<String, dynamic> json) {
    return Insurance(
      id: json['id'],
      policyName: json['policyName'] ?? '',
      type: json['type'] ?? '',
      provider: json['provider'] ?? '',
      coverageAmount: (json['coverageAmount'] ?? 0).toDouble(),
      premiumAmount: json['premiumAmount']?.toDouble(),
      premiumFrequency: json['premiumFrequency'],
      startDate: json['startDate'],
      maturityYear: json['maturityYear'],
      maturityBenefit: json['maturityBenefit']?.toDouble(),
      beneficiary: json['beneficiary'] ?? '',
      description: json['description'],
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'policyName': policyName,
      'type': type,
      'provider': provider,
      'coverageAmount': coverageAmount,
      'premiumAmount': premiumAmount,
      'premiumFrequency': premiumFrequency,
      'startDate': startDate,
      'maturityYear': maturityYear,
      'maturityBenefit': maturityBenefit,
      'beneficiary': beneficiary,
      'description': description,
      'active': active,
    };
  }
}

