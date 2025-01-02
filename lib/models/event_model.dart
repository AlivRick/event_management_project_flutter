import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String name;
  final String description;
  final String location;
  final DateTime date;
  final double ticketPrice;
  final int maxTickets;
  final int soldTickets;
  final String status;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.date,
    required this.ticketPrice,
    required this.maxTickets,
    required this.soldTickets,
    required this.status,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      ticketPrice: map['ticket_price'].toDouble(),
      maxTickets: map['max_tickets'],
      soldTickets: map['sold_tickets'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'date': date,
      'ticket_price': ticketPrice,
      'max_tickets': maxTickets,
      'sold_tickets': soldTickets,
      'status': status,
    };
  }
}
