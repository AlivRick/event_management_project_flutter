import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/ticket_type_model.dart';
import '../../services/cart_service.dart';
import 'payment_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<TicketType> cartItems = [];
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadCart();
    _fetchCurrentUser();
  }

  void _loadCart() async {
    cartItems = await CartService.getCart();
    setState(() {});
  }

  void _fetchCurrentUser() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        userId = currentUser.uid; // Lưu userId từ FirebaseAuth
      });
    }
  }

  void _removeFromCart(TicketType ticket) async {
    cartItems.remove(ticket);
    await CartService.saveCart2(cartItems);
    _loadCart();
  }

  void _clearAllCart() async {
    cartItems.clear();
    await CartService.saveCart2(cartItems);
    _loadCart();
  }

  Future<bool> _isTicketSoldOut(TicketType ticket) async {
    final ticketSnapshot = await FirebaseFirestore.instance
        .collection('ticket_types')
        .doc(ticket.id)
        .get();

    if (ticketSnapshot.exists) {
      final ticketData = ticketSnapshot.data()!;
      int soldTickets = ticketData['sold_tickets'] ?? 0;
      int maxTickets = ticketData['max_tickets'] ?? 0;
      return soldTickets >= maxTickets;
    } else {
      return false;
    }
  }

  void _navigateToPaymentScreen() async {
    // Kiểm tra xem có vé nào hết hạn hoặc hết vé không
    bool hasInvalidTickets = false;
    for (var ticket in cartItems) {
      bool isSoldOut = await _isTicketSoldOut(ticket);
      if (isSoldOut) {
        hasInvalidTickets = true;
        break; // Nếu có vé hết, không cho phép thanh toán
      }
    }

    if (hasInvalidTickets) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Có vé hết hạn hoặc hết vé. Vui lòng xóa chúng khỏi giỏ hàng.")),
      );
      return; // Dừng thanh toán nếu có vé hết hạn hoặc hết vé
    }

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng đăng nhập trước khi thanh toán.")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          tickets: cartItems,   // Truyền danh sách vé
          userId: userId!,      // Truyền userId (đảm bảo không null)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giỏ hàng'),
        backgroundColor: Color(0xFF2ECC71), // Màu nền đồng bộ với các màn hình khác
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_forever),
              onPressed: _clearAllCart,
              tooltip: 'Xóa tất cả vé',
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
        child: Text(
          'Giỏ hàng của bạn trống!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
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
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(ticket.name, style: TextStyle(fontWeight: FontWeight.bold)),
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
          onPressed: _navigateToPaymentScreen, // Navigate to PaymentScreen
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2ECC71), // Màu nền đồng bộ
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            'Thanh toán (${cartItems.length} vé)',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
