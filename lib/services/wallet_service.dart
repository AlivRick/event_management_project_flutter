import 'package:cloud_firestore/cloud_firestore.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy số dư ví của người dùng
  Future<double> getWalletBalance(String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    final docSnapshot = await userRef.get();
    if (docSnapshot.exists) {
      final walletBalance = docSnapshot['walletBalance'] as double?;
      return walletBalance ?? 0.0;
    } else {
      throw Exception("User not found");
    }
  }

  // Cập nhật số dư ví của người dùng sau khi thanh toán
  Future<void> updateWallet(String userId, double amount) async {
    final userRef = _firestore.collection('users').doc(userId);
    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final currentBalance = userSnapshot['walletBalance'] as double?;

      if (currentBalance != null) {
        transaction.update(userRef, {'walletBalance': currentBalance + amount});
      } else {
        throw Exception("User wallet balance not found");
      }
    });
  }
}
