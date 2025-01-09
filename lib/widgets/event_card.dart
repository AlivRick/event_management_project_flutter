import 'package:flutter/material.dart';
import '../screens/user/event_detail_screen.dart'; // Import màn hình EventDetailScreen
import '../models/event_model.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFF1B1B1B), // Nền màu xám đậm cho card
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // Bo góc cho card
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hiển thị hình ảnh sự kiện nếu có
          if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
            GestureDetector(
              onTap: () {
                // Điều hướng sang màn hình EventDetailScreen khi nhấn vào hình
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailScreen(event: event),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
                child: Image.network(
                  event.imageUrl!,
                  width: double.infinity,
                  height: 250, // Đảm bảo chiều cao hình ảnh là 250
                  fit: BoxFit.contain, // Thay BoxFit.cover thành BoxFit.contain để đảm bảo ảnh không bị cắt
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 250,
                      child: Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                    );
                  },
                ),
              ),
            ),

          // Nội dung ListTile
          Container(
            color: Color(0xFF2E2E2E), // Nền màu xám nhạt hơn dưới chữ
            child: ListTile(
              title: Text(
                event.name,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Chữ màu trắng
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                event.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.grey, // Chữ phụ màu xám
                  fontSize: 14,
                ),
              ),
              onTap: () {
                // Điều hướng sang màn hình EventDetailScreen khi nhấn vào tên hoặc mô tả
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailScreen(event: event),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
