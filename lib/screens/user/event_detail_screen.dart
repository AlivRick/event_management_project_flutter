import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../services/transaction_service.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  EventDetailScreen({required this.event});

  final TransactionService _transactionService = TransactionService();
  final EventService _eventService = EventService(); // Sử dụng EventService nếu cần

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.description, style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Tickets Available: ${event.soldTickets}/${event.maxTickets}"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: event.soldTickets < event.maxTickets
                  ? () async {
                      final success = await _transactionService.purchaseTicket(event.id);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Ticket purchased successfully!")),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Purchase failed!")),
                        );
                      }
                    }
                  : null,
              child: Text("Buy Ticket"),
            ),
          ],
        ),
      ),
    );
  }
}
