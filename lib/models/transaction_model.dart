import 'package:cloud_firestore/cloud_firestore.dart';

class UserTransaction  {
  final String id; // ID của giao dịch, sẽ được lấy từ documentId
  final String userId; // ID của người dùng
  final String type; // Loại giao dịch: 'DEPOSIT' hoặc 'WITHDRAW'
  final double amount; // Số tiền giao dịch
  final DateTime date; // Thời gian giao dịch

  UserTransaction ({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.date,
  });

  // Chuyển từ Map sang Transaction object
  factory UserTransaction.fromMap(Map<String, dynamic> map) {
    return UserTransaction (
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
    );
  }

  // Chuyển từ UserTransaction  object sang Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'amount': amount,
      'date': Timestamp.fromDate(date),
    };
  }
}
