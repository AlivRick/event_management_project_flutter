// Event Model
import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String name;
  final String description;
  final String location;
  final DateTime date;
  final String status;
  final String? imageUrl; // URL ảnh (có thể null)

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.date,
    required this.status,
    this.imageUrl, // Thêm trường imageUrl
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      status: map['status'],
      imageUrl: map['imageUrl'], // Đọc imageUrl từ Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'date': Timestamp.fromDate(date), // Chuyển đổi DateTime thành Timestamp
      'status': status,
      'imageUrl': imageUrl, // Ghi imageUrl vào Firestore
    };
  }
}