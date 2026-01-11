/// User Model
///
/// Represents family member with authentication details

class User {
  final int? id;
  final String username;
  final String fullName;
  final String role;
  final String? token;

  User({
    this.id,
    required this.username,
    required this.fullName,
    required this.role,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? '',
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'role': role,
      'token': token,
    };
  }

  bool get isAdmin => role == 'ADMIN';
  bool get isFamily => role == 'FAMILY';
}

