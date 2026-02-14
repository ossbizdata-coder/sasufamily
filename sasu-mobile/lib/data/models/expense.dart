/// Expense Model
///
/// Represents a family expense

class Expense {
  final int? id;
  final String name;
  final double amount;
  final String category;
  final String frequency;
  final String? startDate;
  final String? description;
  final bool active;
  final bool isNeed; // true for Needs, false for Wants

  Expense({
    this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.frequency,
    this.startDate,
    this.description,
    this.active = true,
    this.isNeed = true,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      name: json['name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      frequency: json['frequency'] ?? '',
      startDate: json['startDate'],
      description: json['description'],
      active: json['active'] ?? true,
      isNeed: json['isNeed'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'frequency': frequency,
      'startDate': startDate,
      'description': description,
      'active': active,
      'isNeed': isNeed,
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

