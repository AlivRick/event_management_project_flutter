import 'package:flutter/material.dart';
import '../../models/ticket_type_model.dart';

class PaymentScreen extends StatelessWidget {
  final List<TicketType> tickets;

  PaymentScreen({required this.tickets});

  @override
  Widget build(BuildContext context) {
    double totalAmount = tickets.fold(0, (sum, ticket) => sum + ticket.price);

    return Scaffold(
      appBar: AppBar(title: Text("Thanh toán")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tổng số vé: ${tickets.length}"),
            SizedBox(height: 10),
            Column(
              children: tickets.map((ticket) {
                return ListTile(
                  title: Text(ticket.name),
                  subtitle: Text("Giá: \$${ticket.price.toStringAsFixed(2)}"),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text("Tổng cộng: \$${totalAmount.toStringAsFixed(2)}",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Xử lý thanh toán tại đây
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Thanh toán thành công!")),
                );
                Navigator.pop(context);
              },
              child: Text("Thanh toán"),
            ),
          ],
        ),
      ),
    );
  }
}
