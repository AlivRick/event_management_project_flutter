import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String userId;
  final String eventId;
  final double amount;
  final DateTime date;
  final String type; // "TICKET_PURCHASE" or "WALLET_TOPUP"

  Transaction({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.amount,
    required this.date,
    required this.type,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      eventId: map['event_id'] ?? '',
      amount: map['amount'].toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      type: map['type'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
      'amount': amount,
      'date': date,
      'type': type,
    };
  }
}
