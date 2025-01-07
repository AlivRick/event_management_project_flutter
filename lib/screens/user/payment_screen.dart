import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/ticket_type_model.dart';
import '../../services/payment_service.dart';
import 'event_list_screen.dart';

class PaymentScreen extends StatelessWidget {
  final List<TicketType> tickets;
  final String userId; // ID của người dùng được truyền từ màn hình trước

  PaymentScreen({required this.tickets, required this.userId});

  @override
  Widget build(BuildContext context) {
    double totalPrice = tickets.fold(0.0, (sum, ticket) => sum + ticket.price);

    return Scaffold(
      appBar: AppBar(title: Text('Thanh toán')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ...tickets.map((ticket) {
              return ListTile(
                title: Text(ticket.name),
                subtitle: Text("Giá: \$${ticket.price.toStringAsFixed(2)}"),
              );
            }).toList(),
            Divider(),
            Text(
              'Tổng tiền: \$${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Hiển thị trạng thái "Đang xử lý..."
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return Center(child: CircularProgressIndicator());
                  },
                );
                // Gọi PaymentService để xử lý thanh toán
                bool paymentSuccess = await PaymentService.handlePayment(
                  userId: userId,
                  tickets: tickets,
                );

                // Đóng dialog trạng thái
                Navigator.pop(context);

                if (paymentSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Thanh toán thành công!')),
                  );

                  // Hiển thị dialog với dấu tích xanh sau khi thanh toán thành công
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      contentPadding: EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      title: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 80,
                      ),
                      titlePadding: EdgeInsets.only(bottom: 10),
                      content: Text(
                        'Thanh toán thành công!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Đóng dialog
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => EventListScreen()), // Chuyển tới màn hình EventListScreen
                            );
                          },
                          child: Text('Đóng', style: TextStyle(color: Colors.blue)),
                        ),
                      ],
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Thanh toán thất bại! Vui lòng kiểm tra số dư.')),
                  );
                }
              },
              child: Text('Thanh toán'),
            ),
          ],
        ),
      ),
    );
  }
}
