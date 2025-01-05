
class TicketDetail {
  final String ticketTypeId; // Liên kết với loại vé
  final int quantity; // Số lượng vé đã mua
  final double price; // Giá vé

  TicketDetail({
    required this.ticketTypeId,
    required this.quantity,
    required this.price,
  });

  factory TicketDetail.fromMap(Map<String, dynamic> map) {
    return TicketDetail(
      ticketTypeId: map['ticket_type_id'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ticket_type_id': ticketTypeId,
      'quantity': quantity,
      'price': price,
    };
  }
}
