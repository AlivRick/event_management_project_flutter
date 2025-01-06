import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../widgets/event_card.dart';
import '../../widgets/navigation_helper.dart';
import 'cart_screen.dart';
import 'user_info_screen.dart'; // Import màn hình thông tin người dùng

class EventListScreen extends StatelessWidget {
  final EventService _eventService = EventService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh sách sự kiện"),
        backgroundColor: Colors.blueAccent,
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
              Colors.lightBlueAccent,
              Colors.cyanAccent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Bo góc đều
        ),
        child: CurvedNavigationBar(
          backgroundColor: Colors.transparent, // Để hiển thị gradient
          color: Colors.white, // Màu chính của thanh điều hướng
          buttonBackgroundColor: Colors.lightBlueAccent, // Nút được chọn có màu
          height: 60,
          index: 0, // Đảm bảo trang này được chọn
          animationDuration: Duration(milliseconds: 300),
          items: [
            Icon(Icons.event, size: 30, color: Colors.blueAccent),
            Icon(Icons.person, size: 30, color: Colors.blueAccent),
          ],
          onTap: (index) {
            NavigationHelper.navigateToScreen(context, index);
          },
        ),
      ),
    );
  }
}
