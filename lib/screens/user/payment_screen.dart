import 'package:flutter/material.dart';
import '../../models/ticket_type_model.dart';

class PaymentScreen extends StatelessWidget {
  final List<TicketType> tickets;

  PaymentScreen({required this.tickets});

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
            Text('Tổng tiền: \$${totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 20)),
            ElevatedButton(
              onPressed: () {
                // Xử lý thanh toán
              },
              child: Text('Thanh toán'),
            ),
          ],
        ),
      ),
    );
  }
}
