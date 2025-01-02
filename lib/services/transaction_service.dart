import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Giả lập quá trình mua vé và giảm số lượng vé đã bán
  Future<bool> purchaseTicket(String eventId) async {
    try {
      final eventRef = _firestore.collection('events').doc(eventId);
      final eventDoc = await eventRef.get();

      if (eventDoc.exists) {
        final data = eventDoc.data();
        final soldTickets = data?['soldTickets'] ?? 0;
        final maxTickets = data?['maxTickets'] ?? 0;

        if (soldTickets < maxTickets) {
          // Cập nhật số vé đã bán
          await eventRef.update({'soldTickets': soldTickets + 1});
          return true;
        }
      }
    } catch (e) {
      print("Error purchasing ticket: $e");
    }
    return false;
  }
}
