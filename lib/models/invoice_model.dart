import 'package:cloud_firestore/cloud_firestore.dart';
import 'ticket_detail_model.dart';

class Invoice {
  final String id; // ID hóa đơn
  final String userId; // ID người dùng
  final DateTime date; // Ngày tháng
  final String type; // "TICKET_PURCHASE" hoặc "WALLET_TOPUP"
  final double totalAmount; // Tổng số tiền thanh toán
  final List<TicketDetail> ticketDetails; // Danh sách các vé mua trong hóa đơn

  Invoice({
    required this.id,
    required this.userId,
    required this.date,
    required this.type,
    required this.totalAmount,
    required this.ticketDetails, // Danh sách vé
  });

  factory Invoice.fromMap(Map<String, dynamic> map) {
    // Kiểm tra xem 'ticket_details' có phải là một danh sách không và nếu có thì chuyển thành List<TicketDetail>
    var ticketDetailsFromMap = <TicketDetail>[];

    if (map['ticket_details'] is List) {
      // Nếu ticket_details là một List, thì tiến hành ánh xạ vào danh sách TicketDetail
      ticketDetailsFromMap = (map['ticket_details'] as List)
          .map((ticketDetail) => TicketDetail.fromMap(ticketDetail))
          .toList();
    }

    return Invoice(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      date: (map['date'] as Timestamp).toDate(), // Convert Timestamp to DateTime
      type: map['type'] ?? '',
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0, // Nếu không có total_amount, gán mặc định là 0.0
      ticketDetails: ticketDetailsFromMap, // Đọc ticketDetails từ Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date,
      'type': type,
      'total_amount': totalAmount,
      'ticket_details': ticketDetails.map((e) => e.toMap()).toList(), // Lưu ticketDetails vào Firestore
    };
  }
}
