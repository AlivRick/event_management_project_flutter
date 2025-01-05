import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket_type_model.dart';

class TicketService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<TicketType> createTicketTypeFromMap(Map<String, dynamic> ticketTypeMap) async {
    final docRef = await _firestore.collection('ticket_types').add(ticketTypeMap);
    final docSnapshot = await docRef.get();  // Lấy dữ liệu vừa được tạo
    final createdTicketMap = docSnapshot.data()!;

    // Trả về đối tượng TicketType đã được tạo đầy đủ
    return TicketType.fromMap(createdTicketMap);
  }

// Sửa lại phương thức tạo TicketType
  Future<TicketType> createTicketType(TicketType ticketType) async {
    // Tạo tài liệu trong Firestore với ID tự động
    final docRef = await _firestore.collection('ticket_types').add(ticketType.toMap());

    // Lấy Document ID và cập nhật trường 'id'
    final docId = docRef.id;
    await docRef.update({'id': docId});

    // Lấy snapshot của document vừa tạo
    final docSnapshot = await docRef.get();

    // Trả về đối tượng TicketType đã được tạo và cập nhật
    final createdTicketMap = docSnapshot.data()!;
    return TicketType.fromMap(createdTicketMap);
  }


  // Get a list of ticket types for an event
  Stream<List<TicketType>> getTicketTypes(String eventId) {
    return _firestore
        .collection('ticket_types')
        .where('event_id', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => TicketType.fromMap(doc.data())).toList());
  }

  // Update ticket type information
  Future<void> updateTicketType(String ticketTypeId, Map<String, dynamic> updates) async {
    await _firestore.collection('ticket_types').doc(ticketTypeId).update(updates);
  }
}
