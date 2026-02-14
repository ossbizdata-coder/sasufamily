/// Income Model
///
/// Represents a family income source

class Income {
  final int? id;
  final String source;
  final double amount;
  final String type;
  final String frequency;
  final String? startDate;
  final String? description;
  final bool active;

  Income({
    this.id,
    required this.source,
    required this.amount,
    required this.type,
    required this.frequency,
    this.startDate,
    this.description,
    this.active = true,
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'],
      source: json['source'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      frequency: json['frequency'] ?? '',
      startDate: json['startDate'],
      description: json['description'],
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'amount': amount,
      'type': type,
      'frequency': frequency,
      'startDate': startDate,
      'description': description,
      'active': active,
    };
  }

  double getMonthlyAmount() {
    if (frequency == 'MONTHLY') {
      return amount;
    } else if (frequency == 'QUARTERLY') {
      return amount / 3;
    } else if (frequency == 'YEARLY') {
      return amount / 12;
    }
    return 0;
  }
}

