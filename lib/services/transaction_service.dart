import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new transaction
  Future<String> createTransaction(UserTransaction transaction) async {
    final docRef = await _firestore.collection('transactions').add(transaction.toMap());
    final transactionId = docRef.id;

    // Update the document with its ID
    await docRef.update({'id': transactionId});

    return transactionId;
  }

  // Get all transactions for a specific user
  Stream<List<UserTransaction>> getTransactionsByUserId(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UserTransaction.fromMap(doc.data()))
        .toList());
  }

  // Get all transactions
  Stream<List<UserTransaction>> getAllTransactions() {
    return _firestore
        .collection('transactions')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UserTransaction.fromMap(doc.data()))
        .toList());
  }

  // Update transaction type (e.g., DEPOSIT or WITHDRAW)
  Future<void> updateTransactionType(String transactionId, String type) async {
    await _firestore.collection('transactions').doc(transactionId).update({'type': type});
  }

  // Delete a transaction
  Future<void> deleteTransaction(String transactionId) async {
    await _firestore.collection('transactions').doc(transactionId).delete();
  }
}
