import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../widgets/event_card.dart';
import '../../widgets/navigation_helper.dart';
import 'cart_screen.dart';

class EventListScreen extends StatefulWidget {
  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final EventService _eventService = EventService();
  int _selectedIndex = 0; // Giữ chỉ số mục được chọn

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    NavigationHelper.navigateToScreen(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "TICKET BỜ RỒ",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Colors.white, // Chữ màu trắng
          ),
        ),
        backgroundColor: Color(0xFF2ECC71), // Màu xanh lá
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white), // Giỏ hàng màu trắng
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Color(0xFF1B1B1B), // Nền đen xám
        child: StreamBuilder<List<Event>>(
          stream: _eventService.getEvents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: Color(0xFF2ECC71)), // Xanh lá
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "LỖI: ${snapshot.error}",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    color: Color(0xFF2ECC71), // Xanh lá
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  "KHÔNG CÓ SỰ KIỆN NÀO.",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              );
            } else {
              final events = snapshot.data!
                  .where((event) => event.status == "OPEN") // Filter events by status "open"
                  .toList();
              if (events.isEmpty) {
                return Center(
                  child: Text(
                    "KHÔNG CÓ SỰ KIỆN MỞ.",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  // Lọc sự kiện theo ngày hiện tại
                  final event = events[index];
                  if (event.date.isBefore(DateTime.now())) {
                    return SizedBox.shrink(); // Không hiển thị nếu ngày đã qua
                  }
                  return EventCard(event: event);
                },
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF2ECC71), // Màu xanh lá khi chọn
        unselectedItemColor: Colors.white, // Màu trắng khi chưa chọn
        backgroundColor: Colors.grey, // Màu nền đen
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Sự kiện',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Vé',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
