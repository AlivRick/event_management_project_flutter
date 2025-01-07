import 'package:flutter/material.dart';
import 'package:flutter_braintree/flutter_braintree.dart';
import '../../services/wallet_service.dart';

class WalletTopUpScreen extends StatefulWidget {
  final String userId; // ID người dùng

  WalletTopUpScreen({required this.userId});

  @override
  _WalletTopUpScreenState createState() => _WalletTopUpScreenState();
}

class _WalletTopUpScreenState extends State<WalletTopUpScreen> {
  final TextEditingController _amountController = TextEditingController();
  final WalletService _walletService = WalletService();
  bool _isLoading = false; // Biến để hiển thị trạng thái chờ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Top Up Wallet")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter amount to top up",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator()) // Hiển thị khi đang xử lý
                : ElevatedButton(
              onPressed: _topUpWallet,
              child: Text("Proceed to Payment"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _topUpWallet() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    if (amount < 1.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Minimum top-up amount is \$1")),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Bật trạng thái chờ
    });

    try {
      // Thanh toán qua Braintree
      final result = await Braintree.requestPaypalNonce(
        "sandbox_tv5cd5vq_873h2snfhn5hkbdt", // Tokenization Key
        BraintreePayPalRequest(
          amount: amount.toStringAsFixed(2),
          currencyCode: "USD",
        ),
      );


      if (result != null) {
        // Nếu thanh toán thành công, cập nhật ví
        await _walletService.updateWallet(widget.userId, amount);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Top up successful!")),
        );
        Navigator.pop(context); // Quay lại màn hình trước
      } else {
        // Nếu người dùng hủy thanh toán
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment cancelled")),
        );
      }
    } catch (e) {
      // Xử lý lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Tắt trạng thái chờ
      });
    }
  }
}
