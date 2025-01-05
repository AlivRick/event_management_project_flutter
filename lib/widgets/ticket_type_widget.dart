import 'package:flutter/material.dart';

class TicketTypeWidget extends StatefulWidget {
  final String title;
  final String price;
  final String maxTickets;
  final VoidCallback onDelete; // Function to delete ticket type
  final Function(String title, String price, String maxTickets) onUpdate;
  final String? ticketId; // ID của ticket nếu đã lưu vào DB

  TicketTypeWidget({
    required this.title,
    required this.price,
    required this.maxTickets,
    required this.onDelete,
    required this.onUpdate,
    this.ticketId, // Nếu ticket đã lưu, nó có ID
  });

  @override
  _TicketTypeWidgetState createState() => _TicketTypeWidgetState();
}

class _TicketTypeWidgetState extends State<TicketTypeWidget> {
  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _maxTicketsController;

  bool _isEditing = false; // Để xác định khi nào đang chỉnh sửa

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _priceController = TextEditingController(text: widget.price);
    _maxTicketsController = TextEditingController(text: widget.maxTickets);

    // Nếu ticket đã có id (đã lưu vào DB), không cần popup mà chỉ cho phép chỉnh sửa
    _isEditing = widget.ticketId == null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _maxTicketsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Ticket Type Name',
                    ),
                    enabled: _isEditing,
                    onChanged: (value) {
                      // Gọi onUpdate mỗi khi thay đổi
                      widget.onUpdate(
                        _titleController.text,
                        _priceController.text,
                        _maxTicketsController.text,
                      );
                    },
                  ),
                ),
                if (_isEditing)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: widget.onDelete,
                  ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                    ),
                    keyboardType: TextInputType.number,
                    enabled: _isEditing,
                    onChanged: (value) {
                      // Gọi onUpdate mỗi khi thay đổi
                      widget.onUpdate(
                        _titleController.text,
                        _priceController.text,
                        _maxTicketsController.text,
                      );
                    },
                  ),
                ),
                if (_isEditing)
                  ElevatedButton(
                    onPressed: () {
                      final price =
                          double.tryParse(_priceController.text) ?? -1.0;
                      if (price < 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid price')),
                        );
                        return;
                      }
                      // Gọi onUpdate khi nhấn nút Update
                      widget.onUpdate(
                        _titleController.text,
                        _priceController.text,
                        _maxTicketsController.text,
                      );
                    },
                    child: const Text('Update'),
                  ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _maxTicketsController,
                    decoration: const InputDecoration(
                      labelText: 'Max Tickets',
                    ),
                    keyboardType: TextInputType.number,
                    enabled: _isEditing,
                    onChanged: (value) {
                      // Gọi onUpdate mỗi khi thay đổi
                      widget.onUpdate(
                        _titleController.text,
                        _priceController.text,
                        _maxTicketsController.text,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
