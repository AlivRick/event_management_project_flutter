import 'package:flutter/material.dart';
import '../../models/ticket_type_model.dart';
import '../../services/cart_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<TicketType> cartItems = []; // Danh sách vé trong giỏ hàng

  @override
  void initState() {
    super.initState();
    _loadCart(); // Tải giỏ hàng khi màn hình được hiển thị
  }

  // Tải giỏ hàng từ SharedPreferences
  void _loadCart() async {
    cartItems = await CartService.getCart(); // Lấy giỏ hàng từ CartService
    setState(() {});
  }

  // Xóa vé khỏi giỏ hàng
  void _removeFromCart(TicketType ticket) async {
    // Xóa vé khỏi danh sách giỏ hàng trong bộ nhớ
    cartItems.remove(ticket);

    // Lưu lại giỏ hàng đã thay đổi vào SharedPreferences
    await CartService.saveCart2(cartItems);

    // Tải lại giỏ hàng từ SharedPreferences để cập nhật màn hình
    _loadCart();

    // Cập nhật lại trạng thái giao diện
    setState(() {});
  }

  // Xóa tất cả vé khỏi giỏ hàng
  void _clearAllCart() async {
    // Xóa tất cả vé khỏi danh sách
    cartItems.clear();

    // Cập nhật lại giỏ hàng trong SharedPreferences
    await CartService.saveCart2(cartItems);

    // Tải lại giỏ hàng từ SharedPreferences để cập nhật màn hình
    _loadCart();

    // Cập nhật lại trạng thái giao diện
    setState(() {});
  }

  // Kiểm tra vé đã hết hay chưa từ Firestore
  Future<bool> _isTicketSoldOut(TicketType ticket) async {
    final ticketSnapshot = await FirebaseFirestore.instance
        .collection('ticket_types')
        .doc(ticket.id)
        .get();

    if (ticketSnapshot.exists) {
      final ticketData = ticketSnapshot.data()!;
      int soldTickets = ticketData['sold_tickets'] ?? 0;
      int maxTickets = ticketData['max_tickets'] ?? 0;
      return soldTickets >= maxTickets; // Vé đã hết nếu số vé đã bán >= số vé tối đa
    } else {
      return false; // Trường hợp không tìm thấy vé, xem như vé còn
    }
  }

  // Hàm thanh toán giỏ hàng
  void _checkout() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Thanh toán thành công!')));
    CartService.clearCart(); // Xóa giỏ hàng sau khi thanh toán
    setState(() {
      cartItems = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giỏ hàng'),
        actions: [
          // Nút Xóa tất cả vé nằm bên phải trên cùng của màn hình
          if (cartItems.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_forever),
              onPressed: _clearAllCart, // Xóa tất cả vé trong giỏ hàng
              tooltip: 'Xóa tất cả vé',
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(child: Text('Giỏ hàng của bạn trống!'))
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final ticket = cartItems[index];
          return FutureBuilder<bool>(
            future: _isTicketSoldOut(ticket),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(ticket.name),
                    subtitle: Text('Đang kiểm tra trạng thái vé...'),
                  ),
                );
              }

              bool isSoldOut = snapshot.data ?? false;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: isSoldOut ? Colors.grey[300] : Colors.white,
                child: ListTile(
                  title: Text(ticket.name),
                  subtitle: Text(
                    'Giá: \$${ticket.price.toStringAsFixed(2)}\n${isSoldOut ? "Vé đã hết" : ""}',
                    style: TextStyle(
                      color: isSoldOut ? Colors.red : Colors.black,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle_outline),
                    onPressed: isSoldOut ? null : () => _removeFromCart(ticket),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _checkout, // Thanh toán giỏ hàng
          child: Text('Thanh toán (${cartItems.length} vé)'),
        ),
      ),
    );
  }
}
