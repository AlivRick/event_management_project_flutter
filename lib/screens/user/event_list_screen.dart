import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../widgets/event_card.dart';
import '../../widgets/navigation_helper.dart';
import 'cart_screen.dart';

class EventListScreen extends StatelessWidget {
  final EventService _eventService = EventService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ticket Bờ Rồ"),
        backgroundColor: Color(0xFF3498DB), // Màu xanh lam
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
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
      body: StreamBuilder<List<Event>>(
        stream: _eventService.getEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Không có sự kiện nào."));
          } else {
            final events = snapshot.data!;
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return EventCard(event: events[index]);
              },
            );
          }
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF8E44AD), // Tím
              Color(0xFF3498DB), // Xanh lam
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: CurvedNavigationBar(
          backgroundColor: Colors.transparent,
          color: Colors.white,
          buttonBackgroundColor: Color(0xFFFFC0CB), // Hồng nhạt
          height: 60,
          index: 0,
          animationDuration: Duration(milliseconds: 300),
          items: [
            Icon(Icons.event, size: 30, color: Colors.deepPurple),
            Icon(Icons.person, size: 30, color: Colors.deepPurple),
          ],
          onTap: (index) {
            NavigationHelper.navigateToScreen(context, index);
          },
        ),
      ),
    );
  }
}
