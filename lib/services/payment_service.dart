import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket_type_model.dart';
import '../models/user_model.dart';
import '../models/invoice_model.dart';
import '../models/ticket_detail_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cart_service.dart';

class PaymentService {
  static double _convertToDouble(dynamic value) {
    if (value == null) return 0.0; // Nếu giá trị null, trả về 0.0
    if (value is double) return value; // Nếu đã là double, trả về luôn
    return value is int
        ? value.toDouble()
        : 0.0; // Chuyển từ int hoặc giá trị khác sang double
  }

  static Future<bool> handlePayment({
    required String userId,
    required List<TicketType> tickets,
  }) async {
    try {
      // Lấy thông tin người dùng từ Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        print("Người dùng không tồn tại");
        return false; // Người dùng không tồn tại
      }

      // Kiểm tra dữ liệu Firestore và in ra dữ liệu
      print("Dữ liệu người dùng từ Firestore: ${userDoc.data()}");

      // Ánh xạ dữ liệu từ Firestore thành đối tượng User
      User user = User.fromMap({
        'id': userDoc.id,
        'name': userDoc['name'] ?? '',
        'email': userDoc['email'] ?? '',
        'role': userDoc['role'] ?? 'USER',
        'wallet_balance': _convertToDouble(userDoc['walletBalance']),
      });

      // Kiểm tra nếu walletBalance là null hoặc không có giá trị
      double walletBalance = user.walletBalance ?? 0.0;
      print("Số dư ví của người dùng: \$${walletBalance}");

      // Tính tổng tiền từ danh sách vé
      double totalAmount = tickets.fold(
          0.0, (sum, ticket) => sum + ticket.price);
      print("Tổng số tiền phải thanh toán: \$${totalAmount}");

      // Kiểm tra số dư ví của người dùng
      if (walletBalance < totalAmount) {
        print("Không đủ số dư trong ví");
        return false; // Không đủ số dư
      }

      // Cập nhật số lượng vé đã bán
      List<TicketDetail> ticketDetails = [];

      for (TicketType ticket in tickets) {
        DocumentSnapshot ticketDoc = await FirebaseFirestore.instance
            .collection('ticket_types')
            .doc(ticket.id)
            .get();

        if (!ticketDoc.exists) {
          print("Loại vé không tồn tại");
          return false; // Loại vé không tồn tại
        }

        TicketType currentTicket = TicketType.fromMap(
            ticketDoc.data() as Map<String, dynamic>);

        // Kiểm tra nếu số vé bán vượt quá số vé có sẵn
        if (currentTicket.soldTickets + 1 > currentTicket.maxTickets) {
          print("Số vé bán vượt quá số vé có sẵn");
          return false; // Số vé bán vượt quá số vé có sẵn
        }

        // Cập nhật số vé đã bán
        await FirebaseFirestore.instance
            .collection('ticket_types')
            .doc(ticket.id)
            .update({
          'sold_tickets': FieldValue.increment(1),
        });

        // Tạo một mã ID duy nhất cho vé từ Document ID của Firestore
        String ticketId = FirebaseFirestore.instance
            .collection('ticket_details')
            .doc()
            .id;

        // Thêm vé vào danh sách ticketDetails
        ticketDetails.add(TicketDetail(
          ticketTypeId: ticket.id,
          id: ticketId, // Sử dụng Document ID của Firestore
          price: ticket.price,
            isUsed : false
        ));
      }

      // Cập nhật lại số dư ví người dùng
      double updatedWalletBalance = walletBalance - totalAmount;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'walletBalance': updatedWalletBalance});

      // Tạo một Invoice ID (có thể sử dụng UUID hoặc tự động tạo)
      String invoiceId = FirebaseFirestore.instance
          .collection('invoices')
          .doc()
          .id;

      // Lưu hóa đơn vào Firestore
      Invoice invoice = Invoice(
        id: invoiceId,
        userId: userId,
        date: DateTime.now(),
        type: 'TICKET_PURCHASE',
        totalAmount: totalAmount,
        ticketDetails: ticketDetails,
      );

      await FirebaseFirestore.instance.collection('invoices')
          .doc(invoiceId)
          .set(invoice.toMap());

      // Xóa giỏ hàng sau khi thanh toán thành công
      await CartService
          .clearCart(); // Gọi phương thức clearCart để xóa giỏ hàng

      print("Hóa đơn đã được lưu thành công.");
      return true; // Thanh toán thành công
    } catch (e) {
      print('Lỗi khi xử lý thanh toán: $e');
      return false; // Lỗi trong quá trình thanh toán
    }
  }
}
