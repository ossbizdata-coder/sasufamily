/// Liability Model
///
/// Represents financial obligations
/// Used for net worth calculation and monthly burden analysis
/// UI should never feel scary - supports calm presentation

class Liability {
  final int? id;
  final String name;
  final String type;
  final double originalAmount;
  final double remainingAmount;
  final double? monthlyPayment;
  final double? interestRate;
  final String? startDate;
  final String? endDate;
  final String? description;
  final bool active;

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
  });

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
    };
  }
}

