import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new event
  Future<String> createEvent(Event event) async {
    final docRef = await FirebaseFirestore.instance.collection('events').add(event.toMap());
    final eventId = docRef.id;

    // Cập nhật thêm trường 'id' bên trong document
    await docRef.update({'id': eventId});

    return eventId;
  }


  // Get a list of all events
  Stream<List<Event>> getEvents() {
    return _firestore.collection('events').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Event.fromMap(doc.data())).toList());
  }

  // Update event status (OPEN/CLOSED)
  Future<void> updateEventStatus(String eventId, String status) async {
    await _firestore.collection('events').doc(eventId).update({'status': status});
  }
}
