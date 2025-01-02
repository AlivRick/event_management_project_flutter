import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createEvent(Event event) async {
    await _firestore.collection('events').add(event.toMap());
  }

  Stream<List<Event>> getEvents() {
    return _firestore.collection('events').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Event.fromMap(doc.data())).toList());
  }

  Future<void> updateEventStatus(String eventId, String status) async {
    await _firestore.collection('events').doc(eventId).update({'status': status});
  }
}
