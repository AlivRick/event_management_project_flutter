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
  // Danh sách vé người dùng đã chọn
  List<TicketType> selectedTickets = [];

  // Hàm thêm loại vé vào danh sách đã chọn
  void _toggleTicketSelection(TicketType ticketType) {
    setState(() {
      selectedTickets.add(ticketType); // Thêm một bản sao của vé vào danh sách
    });
  }

  // Giảm số lượng vé, xóa vé nếu số lượng = 1
  void _decreaseTicketQuantity(TicketType ticketType) {
    setState(() {
      // Tìm và xóa 1 vé cụ thể nếu tồn tại trong danh sách
      int index = selectedTickets.indexWhere((ticket) => ticket.id == ticketType.id);
      if (index != -1) {
        selectedTickets.removeAt(index); // Loại bỏ vé khỏi danh sách
      }
    });
  }

  // Lấy loại vé từ Firestore
  Future<List<TicketType>> _fetchTicketTypes() async {
    // Lấy dữ liệu từ Firestore về các loại vé cho sự kiện này
    final ticketTypesSnapshot = await FirebaseFirestore.instance
        .collection('ticket_types')
        .where('event_id', isEqualTo: widget.event.id)
        .get();

    return ticketTypesSnapshot.docs.map((doc) {
      return TicketType.fromMap(doc.data());
    }).toList();
  }

  // Lưu vé đã chọn vào giỏ hàng (tạo giỏ hàng mới)
  void _addToCart() async {
    // Lưu giỏ hàng vào SharedPreferences
    await CartService.saveCart(selectedTickets);

    // Thông báo thêm thành công
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thêm vé vào giỏ hàng')),
    );

    // Quay lại màn hình trước (giỏ hàng)
    Navigator.pop(context);
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
            Text(widget.event.description),
            SizedBox(height: 10),
            Text("Địa điểm: ${widget.event.location}"),
            SizedBox(height: 10),
            Text("Thời gian: $formattedDate"),
            SizedBox(height: 10),
            Text("Trạng thái: ${widget.event.status}"),
            SizedBox(height: 20),

            // Hiển thị loại vé
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
                        // Kiểm tra xem số vé đã bán có bằng số vé tối đa chưa
                        bool isSoldOut = ticketType.soldTickets >= ticketType.maxTickets;

                        // Đếm số lần vé xuất hiện trong selectedTickets
                        int ticketCount = selectedTickets.where((ticket) => ticket.id == ticketType.id).length;

                        return Card(
                          color: isSoldOut ? Colors.grey[300] : Colors.white, // Mờ đi nếu hết vé
                          child: ListTile(
                            title: Text(ticketType.name),
                            subtitle: Text(
                                "Giá: \$${ticketType.price.toStringAsFixed(2)}\n${isSoldOut ? "Hết vé" : "Còn vé"}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: isSoldOut || ticketCount == 0
                                      ? null // Không cho giảm nếu hết vé hoặc không còn vé trong giỏ
                                      : () => _decreaseTicketQuantity(ticketType),
                                ),
                                Text(ticketCount.toString()), // Hiển thị số lần vé xuất hiện trong giỏ
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: isSoldOut
                                      ? null // Không cho thêm nếu hết vé
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

            // Nút thêm vào giỏ hàng
            if (selectedTickets.isNotEmpty) ...[
              ElevatedButton(
                onPressed: _addToCart,
                child: Text("Thêm vào giỏ hàng"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
