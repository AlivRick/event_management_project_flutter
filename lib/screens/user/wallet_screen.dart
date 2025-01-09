import 'package:flutter/material.dart';
import '../../services/wallet_service.dart';
import '../../services/stripe_service.dart';
import 'user_info_screen.dart';

class WalletScreen extends StatelessWidget {
  final WalletService _walletService = WalletService();
  final String userId; // ID người dùng cần truyền vào

  WalletScreen({required this.userId}); // Constructor nhận userId

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Wallet",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Colors.white, // Chữ màu trắng cho AppBar
          ),
        ),
        backgroundColor: Color(0xFF2ECC71), // Màu xanh lá cho AppBar
      ),
      body: Container(
        color: Colors.white, // Màu nền trắng cho body
        child: FutureBuilder<double>(
          future: _walletService.getWalletBalance(userId), // Lấy số dư ví từ WalletService
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Color(0xFF2ECC71))); // Xanh lá cho loading spinner
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: TextStyle(color: Colors.black), // Chữ màu đen cho lỗi
                ),
              );
            } else {
              final balance = snapshot.data ?? 0.0;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Current Balance: ${balance.toStringAsFixed(0)}₫", // Hiển thị số dư dưới dạng VND, làm tròn về số nguyên
                      style: TextStyle(fontSize: 18, color: Colors.black), // Chữ màu đen
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _showTopUpDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2ECC71), // Màu xanh lá cho button
                      ),
                      child: Text(
                        "Top Up Wallet",
                        style: TextStyle(fontFamily: 'Roboto', color: Colors.white), // Chữ màu trắng trên button
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // Mở dialog cho người dùng nhập số tiền cần nạp
  void _showTopUpDialog(BuildContext context) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Nền trắng cho dialog
          title: Text(
            'Enter Amount to Top Up',
            style: TextStyle(fontFamily: 'Roboto', color: Colors.black), // Chữ màu đen
          ),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount',
              labelStyle: TextStyle(color: Colors.black), // Chữ màu đen
              border: OutlineInputBorder(),
            ),
            style: TextStyle(color: Colors.black), // Chữ màu đen trong TextField
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng popup
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF2ECC71)), // Màu xanh lá cho nút Cancel
              ),
            ),
            ElevatedButton(
              onPressed: () {
                double amount = double.tryParse(amountController.text) ?? 0.0;
                if (amount > 0) {
                  Navigator.pop(context); // Đóng popup
                  _processPayment(context, amount); // Tiến hành thanh toán
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter a valid amount")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2ECC71), // Màu xanh lá cho button
              ),
              child: Text('Proceed to Payment'),
            ),
          ],
        );
      },
    );
  }

  // Hiển thị dialog thành công
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // Nền trắng cho dialog
        contentPadding: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Icon(
          Icons.check_circle,
          color: Color(0xFF2ECC71), // Màu xanh lá cho icon
          size: 80,
        ),
        titlePadding: EdgeInsets.only(bottom: 10),
        content: Text(
          'Nạp tiền thành công!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Chữ màu đen
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => UserInfoScreen()), // Chuyển tới màn hình UserInfoScreen
              );
            },
            child: Text(
              'Đóng',
              style: TextStyle(color: Color(0xFF2ECC71)), // Màu xanh lá cho nút Đóng
            ),
          ),
        ],
      ),
    );
  }

  // Tiến hành thanh toán qua Stripe
  void _processPayment(BuildContext context, double amount) async {
    try {
      bool paymentSuccess = await StripeService.instance.makePayment(amount.toInt(), userId);

      if (paymentSuccess) {
        // Hiển thị dialog thành công
        _showSuccessDialog(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Thanh toán thất bại")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã xảy ra lỗi: $e")),
      );
    }
  }
}
