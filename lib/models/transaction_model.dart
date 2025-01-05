import 'package:cloud_firestore/cloud_firestore.dart';

import 'ticket_detail_model.dart';

class Transaction {
  final String id;
  final String userId;
  final DateTime date;
  final String type; // "TICKET_PURCHASE" or "WALLET_TOPUP"
  final List<TicketDetail> ticketDetails; // Danh sách các vé mua trong giao dịch

  Transaction({
    required this.id,
    required this.userId,
    required this.date,
    required this.type,
    required this.ticketDetails, // Thêm danh sách vé vào constructor
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    var ticketDetailsFromMap = (map['ticket_details'] as List)
        .map((ticketDetail) => TicketDetail.fromMap(ticketDetail))
        .toList();

    return Transaction(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      type: map['type'] ?? '',
      ticketDetails: ticketDetailsFromMap, // Đọc ticketDetails từ Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date,
      'type': type,
      'ticket_details': ticketDetails.map((e) => e.toMap()).toList(), // Lưu ticketDetails vào Firestore
    };
  }
}
