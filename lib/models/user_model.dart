class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final double walletBalance;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.walletBalance,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'USER',
      walletBalance: map['wallet_balance'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'wallet_balance': walletBalance,
    };
  }
}
