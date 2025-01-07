class TicketDetail {
  final String ticketTypeId;
  final String id;
  final double price;

  TicketDetail({
    required this.ticketTypeId,
    required this.id,
    required this.price,
  });

  factory TicketDetail.fromMap(Map<String, dynamic> map) {
    return TicketDetail(
      ticketTypeId: map['ticket_type_id'] ?? '',
      id: map['id'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ticket_type_id': ticketTypeId,
      'id': id,
      'price': price,
    };
  }
}
