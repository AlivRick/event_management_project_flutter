// import 'package:flutter/material.dart';
// import '../../services/wallet_service.dart';
//
// class WalletScreen extends StatelessWidget {
//   final WalletService _walletService = WalletService();
//   final String userId; // ID người dùng cần truyền vào
//
//   WalletScreen({required this.userId}); // Constructor nhận userId
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Wallet")),
//       body: FutureBuilder<double>(
//         future: _walletService.getWalletBalance(userId), // Lấy số dư ví từ WalletService
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           } else {
//             final balance = snapshot.data ?? 0.0;
//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Current Balance: \$${balance.toStringAsFixed(2)}",
//                       style: TextStyle(fontSize: 18)),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.pushNamed(context, '/wallet_topup');
//                     },
//                     child: Text("Top Up Wallet"),
//                   ),
//                 ],
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
//
import 'package:flutter/material.dart';
import '../../services/wallet_service.dart';
import '../../services/stripe_service.dart';

class WalletScreen extends StatelessWidget {
  final WalletService _walletService = WalletService();
  final String userId; // ID người dùng cần truyền vào

  WalletScreen({required this.userId}); // Constructor nhận userId

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Wallet")),
      body: FutureBuilder<double>(
        future: _walletService.getWalletBalance(userId), // Lấy số dư ví từ WalletService
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            final balance = snapshot.data ?? 0.0;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Current Balance: \$${balance.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showTopUpDialog(context);
                    },
                    child: Text("Top Up Wallet"),
                  ),
                ],
              ),
            );
          }
        },
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
          title: Text('Enter Amount to Top Up'),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng popup
              },
              child: Text('Cancel'),
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
              child: Text('Proceed to Payment'),
            ),
          ],
        );
      },
    );
  }

  // Tiến hành thanh toán qua Stripe
  void _processPayment(BuildContext context, double amount) async {
    try {
      // Gọi StripeService để tạo PaymentIntent và xử lý thanh toán
      bool paymentSuccess = await StripeService.instance.makePayment(amount.toInt());

      if (paymentSuccess) {
        // Thanh toán thành công, cập nhật ví người dùng
        await _walletService.updateWallet(userId, amount);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Top-up successful!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment failed")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}
