import 'package:flutter/material.dart';
import '../../services/wallet_service.dart';

class WalletScreen extends StatelessWidget {
  final WalletService _walletService = WalletService();
  final String userId; // ID người dùng cần truyền vào

  WalletScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Wallet")),
      body: FutureBuilder<double>(
        future: _walletService.getWalletBalance(userId),
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
                      Navigator.pushNamed(context, '/wallet_topup');
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
}
