import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../models/ticket_type_model.dart';
import '../../services/cart_service.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  EventDetailScreen({required this.event});

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  List<TicketType> selectedTickets = [];

  void _toggleTicketSelection(TicketType ticketType) {
    setState(() {
      selectedTickets.add(ticketType);
    });
  }

  void _decreaseTicketQuantity(TicketType ticketType) {
    setState(() {
      int index = selectedTickets.indexWhere((ticket) => ticket.id == ticketType.id);
      if (index != -1) {
        selectedTickets.removeAt(index);
      }
    });
  }

  Future<List<TicketType>> _fetchTicketTypes() async {
    final ticketTypesSnapshot = await FirebaseFirestore.instance
        .collection('ticket_types')
        .where('event_id', isEqualTo: widget.event.id)
        .get();

    return ticketTypesSnapshot.docs.map((doc) {
      return TicketType.fromMap(doc.data());
    }).toList();
  }

  void _addToCart() async {
    await CartService.saveCart(selectedTickets);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thêm vé vào giỏ hàng')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(widget.event.date);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3498DB), // Consistent color with UserInfoScreen
        title: Text(widget.event.name),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.event.description, style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Địa điểm: ${widget.event.location}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Thời gian: $formattedDate", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Trạng thái: ${widget.event.status}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),

            // Ticket Types section
            FutureBuilder<List<TicketType>>(
              future: _fetchTicketTypes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Lỗi: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Không có loại vé nào khả dụng.');
                } else {
                  final ticketTypes = snapshot.data!;

                  return Expanded(
                    child: ListView.builder(
                      itemCount: ticketTypes.length,
                      itemBuilder: (context, index) {
                        final ticketType = ticketTypes[index];
                        bool isSoldOut = ticketType.soldTickets >= ticketType.maxTickets;
                        int ticketCount = selectedTickets.where((ticket) => ticket.id == ticketType.id).length;

                        return Card(
                          color: isSoldOut ? Colors.grey[300] : Colors.white,
                          elevation: 5, // Add shadow to create a card-like effect
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              ticketType.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Giá: \$${ticketType.price.toStringAsFixed(2)}\n${isSoldOut ? "Hết vé" : "Còn vé"}",
                              style: TextStyle(color: Colors.black54),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: isSoldOut || ticketCount == 0
                                      ? null
                                      : () => _decreaseTicketQuantity(ticketType),
                                ),
                                Text(ticketCount.toString(), style: TextStyle(fontSize: 18)),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: isSoldOut
                                      ? null
                                      : () => _toggleTicketSelection(ticketType),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),

            // Add to cart button
            if (selectedTickets.isNotEmpty) ...[
              ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3498DB), // Consistent button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Thêm vào giỏ hàng", style: TextStyle(fontSize: 18)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
