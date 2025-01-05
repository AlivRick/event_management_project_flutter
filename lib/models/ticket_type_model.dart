class TicketType {
  final String id;
  final String eventId; // Liên kết với sự kiện
  final String name; // Loại vé (VIP1, VIP2, Thường, ...)
  final double price; // Giá vé
  final int maxTickets; // Tổng số lượng vé
  final int soldTickets; // Số vé đã bán

  TicketType({
    required this.id,
    required this.eventId,
    required this.name,
    required this.price,
    required this.maxTickets,
    required this.soldTickets,
  });

  factory TicketType.fromMap(Map<String, dynamic> map) {
    return TicketType(
      id: map['id'] ?? '',
      eventId: map['event_id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] as num).toDouble(),
      maxTickets: map['max_tickets'] ?? 0,
      soldTickets: map['sold_tickets'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'name': name,
      'price': price,
      'max_tickets': maxTickets,
      'sold_tickets': soldTickets,
    };
  }
}
