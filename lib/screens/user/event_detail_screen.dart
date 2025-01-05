import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Để định dạng ngày
import '../../models/event_model.dart';
import '../../models/ticket_type_model.dart';
import '../../services/payment_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_screen.dart'; // Đảm bảo bạn đã tạo màn hình thanh toán

class EventDetailScreen extends StatefulWidget {
  final Event event;

  EventDetailScreen({required this.event});

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final PaymentService _transactionService = PaymentService();

  // Danh sách lưu các loại vé người dùng đã chọn
  List<TicketType> selectedTickets = [];

  // Fetch the ticket types for the event from Firestore
  Future<List<TicketType>> _fetchTicketTypes() async {
    try {
      final ticketTypesSnapshot = await FirebaseFirestore.instance
          .collection('ticket_types')
          .where('event_id', isEqualTo: widget.event.id)
          .get();

      return ticketTypesSnapshot.docs.map((doc) {
        return TicketType.fromMap(doc.data());
      }).toList();
    } catch (e) {
      debugPrint('Error fetching ticket types: $e');
      throw Exception('Không thể tải danh sách loại vé.');
    }
  }

  // Hàm thêm loại vé vào danh sách đã chọn
  void _toggleTicketSelection(TicketType ticketType) {
    setState(() {
      if (selectedTickets.contains(ticketType)) {
        selectedTickets.remove(ticketType);
      } else {
        selectedTickets.add(ticketType);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(widget.event.date);

    return Scaffold(
      appBar: AppBar(title: Text(widget.event.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.event.description, style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Địa điểm: ${widget.event.location}"),
            SizedBox(height: 10),
            Text("Thời gian: $formattedDate"),
            SizedBox(height: 10),
            Text("Trạng thái: ${widget.event.status}"),
            SizedBox(height: 20),

            // Ticket Types Section
            FutureBuilder<List<TicketType>>(
              future: _fetchTicketTypes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text(
                    'Lỗi: ${snapshot.error}',
                    style: TextStyle(color: Colors.red),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text(
                    "Không có loại vé nào khả dụng.",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  );
                } else {
                  final ticketTypes = snapshot.data!;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: ticketTypes.length,
                      itemBuilder: (context, index) {
                        final ticketType = ticketTypes[index];
                        final ticketsAvailable =
                            ticketType.maxTickets - ticketType.soldTickets;

                        return Card(
                          child: ListTile(
                            title: Text(ticketType.name),
                            subtitle: Text("Giá: \$${ticketType.price.toStringAsFixed(2)}"),
                            trailing: Text(
                              "Đã bán: ${ticketType.soldTickets}/${ticketType.maxTickets}",
                              style: ticketsAvailable > 0
                                  ? TextStyle(color: Colors.green)
                                  : TextStyle(color: Colors.red),
                            ),
                            onTap: ticketsAvailable > 0
                                ? () {
                              _toggleTicketSelection(ticketType);
                            }
                                : null, // Disable tap if no tickets available
                            tileColor: selectedTickets.contains(ticketType)
                                ? Colors.blue.withOpacity(0.2)
                                : null, // Highlight selected tickets
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),

            // Hiển thị vé đã chọn
            if (selectedTickets.isNotEmpty) ...[
              SizedBox(height: 20),
              Text("Vé đã chọn:", style: TextStyle(fontWeight: FontWeight.bold)),
              ...selectedTickets.map((ticket) {
                return ListTile(
                  title: Text(ticket.name),
                  subtitle: Text("Giá: \$${ticket.price.toStringAsFixed(2)}"),
                );
              }).toList(),

              // Nút thanh toán
              ElevatedButton(
                onPressed: () {
                  // Chuyển sang màn hình thanh toán, truyền danh sách vé đã chọn
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        tickets: selectedTickets,
                      ),
                    ),
                  );
                },
                child: Text("Đi đến thanh toán"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
