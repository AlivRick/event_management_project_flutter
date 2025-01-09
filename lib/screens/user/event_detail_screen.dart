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
  final Color primaryColor = Color(0xFF27AE60); // Màu xanh lá cho các phần bổ trợ
  final Color soldOutColor = Colors.grey[800]!; // Màu nền của vé đã bán hết (xám tối)
  final Color availableColor = Colors.black; // Màu nền của vé có sẵn (đen)
  final Color textColor = Colors.white; // Màu chữ chính
  final Color subtitleTextColor = Colors.grey[500]!; // Màu chữ phụ cho các mô tả vé (xám sáng)

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
      backgroundColor: Colors.black, // Nền đen cho toàn bộ màn hình
      appBar: AppBar(
        backgroundColor: primaryColor, // Màu xanh lá cho AppBar
        title: Text(widget.event.name, style: TextStyle(color: textColor)),
        centerTitle: true,
      ),
      body: SingleChildScrollView( // Wrap the body in SingleChildScrollView to enable scrolling
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hiển thị ảnh sự kiện, đảm bảo không bị cắt và không bị lỗi pixel
              // Hiển thị ảnh sự kiện, đảm bảo không bị cắt và không bị lỗi pixel
              if (widget.event.imageUrl != null && widget.event.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.event.imageUrl!,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.contain, // Thay BoxFit.cover thành BoxFit.contain để đảm bảo ảnh không bị cắt
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 250,
                        child: Center(child: Icon(Icons.broken_image, size: 50)),
                      );
                    },
                  ),
                ),


              // Nội dung mô tả sự kiện với nền xám
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[800], // Màu xám nền cho chữ
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.event.description,
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ),
              SizedBox(height: 10),

              // Địa điểm với nền xám
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[800], // Màu xám nền cho chữ
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Địa điểm: ${widget.event.location}",
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ),
              SizedBox(height: 10),

              // Thời gian với nền xám
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[800], // Màu xám nền cho chữ
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Thời gian: $formattedDate",
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ),
              SizedBox(height: 10),

              // Trạng thái với nền xám
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[800], // Màu xám nền cho chữ
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Trạng thái: ${widget.event.status}",
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ),
              SizedBox(height: 20),

              // Ticket Types section
              FutureBuilder<List<TicketType>>(
                future: _fetchTicketTypes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Lỗi: ${snapshot.error}', style: TextStyle(color: textColor));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('Không có loại vé nào khả dụng.', style: TextStyle(color: textColor));
                  } else {
                    final ticketTypes = snapshot.data!;

                    return ListView.builder(
                      shrinkWrap: true, // Ensures the ListView does not take up excess space
                      itemCount: ticketTypes.length,
                      itemBuilder: (context, index) {
                        final ticketType = ticketTypes[index];
                        bool isSoldOut = ticketType.soldTickets >= ticketType.maxTickets;
                        int ticketCount = selectedTickets.where((ticket) => ticket.id == ticketType.id).length;

                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[700], // Ô màu xám bao quanh
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tên vé
                              Text(
                                ticketType.name,
                                style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 18),
                              ),
                              SizedBox(height: 8),
                              // Mô tả vé
                              Text(
                                "Giá: \$${ticketType.price.toStringAsFixed(2)}\n${isSoldOut ? "Hết vé" : "Còn vé"}",
                                style: TextStyle(color: subtitleTextColor),
                              ),
                              SizedBox(height: 8),
                              // Các nút cộng và trừ
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: isSoldOut || ticketCount == 0
                                        ? null
                                        : () => _decreaseTicketQuantity(ticketType),
                                    color: isSoldOut || ticketCount == 0 ? Colors.grey : primaryColor,
                                  ),
                                  Text(ticketCount.toString(), style: TextStyle(fontSize: 18, color: textColor)),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: isSoldOut
                                        ? null
                                        : () => _toggleTicketSelection(ticketType),
                                    color: isSoldOut ? Colors.grey : primaryColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),


              // Add to cart button
              if (selectedTickets.isNotEmpty) ...[
                ElevatedButton(
                  onPressed: _addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, // Sử dụng màu chính cho nút
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Thêm vào giỏ hàng", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
