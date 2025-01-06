import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/ticket_type_model.dart';

class CartService {
  static const String _cartKey = 'cart_key';

  // Lấy giỏ hàng từ SharedPreferences
  static Future<List<TicketType>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString(_cartKey);

    if (cartData == null) {
      return []; // Nếu không có dữ liệu giỏ hàng, trả về danh sách trống
    } else {
      List<dynamic> decodedList = jsonDecode(cartData);
      return decodedList.map((item) => TicketType.fromMap(item)).toList();
    }
  }

  // Lưu giỏ hàng vào SharedPreferences (kết hợp giỏ hàng cũ với vé mới)
  static Future<void> saveCart(List<TicketType> newTickets) async {
    final prefs = await SharedPreferences.getInstance();

    // Lấy giỏ hàng cũ từ SharedPreferences
    List<TicketType> currentCart = await getCart();

    // Kết hợp giỏ hàng cũ và vé mới
    currentCart.addAll(newTickets);

    // Lưu giỏ hàng kết hợp vào SharedPreferences
    List<Map<String, dynamic>> cartMap = currentCart.map((ticket) => ticket.toMap()).toList();
    String encodedCart = jsonEncode(cartMap); // Mã hóa dữ liệu giỏ hàng thành chuỗi JSON
    await prefs.setString(_cartKey, encodedCart);
  }

  // Xóa giỏ hàng
  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_cartKey);
  }

  // Lưu giỏ hàng vào SharedPreferences (kết hợp giỏ hàng cũ với vé mới)
  static Future<void> saveCart2(List<TicketType> updatedCart) async {
    final prefs = await SharedPreferences.getInstance();

    // Lưu giỏ hàng đã cập nhật vào SharedPreferences
    List<Map<String, dynamic>> cartMap = updatedCart.map((ticket) => ticket.toMap()).toList();
    String encodedCart = jsonEncode(cartMap); // Mã hóa dữ liệu giỏ hàng thành chuỗi JSON
    await prefs.setString(_cartKey, encodedCart);
  }
}
