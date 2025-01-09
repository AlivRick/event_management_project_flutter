class TicketDetail {
  final String ticketTypeId;
  final String id;
  final double price;
  final bool isUsed; // Thêm trường này

  TicketDetail({
    required this.ticketTypeId,
    required this.id,
    required this.price,
    required this.isUsed, // Thêm vào constructor
  });

  factory TicketDetail.fromMap(Map<String, dynamic> map) {
    return TicketDetail(
      ticketTypeId: map['ticket_type_id'] ?? '',
      id: map['id'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      isUsed: map['is_used'] ?? false, // Mặc định là false nếu không có giá trị
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ticket_type_id': ticketTypeId,
      'id': id,
      'price': price,
      'is_used': isUsed, // Thêm trường này
    };
  }
}
