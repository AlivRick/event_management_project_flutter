import 'package:cloud_firestore/cloud_firestore.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<double> getWalletBalance(String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    final docSnapshot = await userRef.get();
    if (docSnapshot.exists) {
      final walletBalance = docSnapshot['wallet_balance'] as double?;
      return walletBalance ?? 0.0;
    } else {
      throw Exception("User not found");
    }
  }

  Future<void> updateWallet(String userId, double amount) async {
    final userRef = _firestore.collection('users').doc(userId);
    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final currentBalance = userSnapshot['wallet_balance'] as double?;

      if (currentBalance != null) {
        transaction.update(userRef, {'wallet_balance': currentBalance + amount});
      } else {
        throw Exception("User wallet balance not found");
      }
    });
  }
}
