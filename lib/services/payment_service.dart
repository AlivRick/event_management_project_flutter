import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ticket_detail_model.dart';
import '../models/ticket_type_model.dart';
import '../models/user_model.dart';

class PaymentService {
  static Future<bool> handlePayment({
    required String userId,
    required List<TicketDetail> ticketDetails, // Nhận danh sách vé mua
  }) async {
    try {
      // Lấy thông tin người dùng
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return false; // Người dùng không tồn tại
      }

      User user = User.fromMap(userDoc.data() as Map<String, dynamic>);

      // Tính tổng số tiền cho tất cả các vé
      double totalAmount = ticketDetails.fold(0, (sum, ticket) => sum + (ticket.price * ticket.quantity));

      // Kiểm tra số dư ví của người dùng
      if (user.walletBalance < totalAmount) {
        return false; // Không đủ số dư
      }

      // Kiểm tra số lượng vé có sẵn và cập nhật vé đã bán
      for (TicketDetail ticketDetail in ticketDetails) {
        DocumentSnapshot ticketDoc = await FirebaseFirestore.instance
            .collection('ticket_types')
            .doc(ticketDetail.ticketTypeId)
            .get();

        if (!ticketDoc.exists) {
          return false; // Loại vé không tồn tại
        }

        TicketType ticketType = TicketType.fromMap(ticketDoc.data() as Map<String, dynamic>);

        if (ticketType.soldTickets + ticketDetail.quantity > ticketType.maxTickets) {
          return false; // Số vé bán vượt quá số vé có sẵn
        }

        // Cập nhật số vé bán
        await FirebaseFirestore.instance
            .collection('ticket_types')
            .doc(ticketDetail.ticketTypeId)
            .update({
          'sold_tickets': FieldValue.increment(ticketDetail.quantity),
        });
      }

      // Cập nhật lại số dư ví của người dùng
      double updatedWalletBalance = user.walletBalance - totalAmount;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'wallet_balance': updatedWalletBalance});

      return true; // Thanh toán thành công
    } catch (e) {
      print('Lỗi khi xử lý thanh toán: $e');
      return false;
    }
  }
}
