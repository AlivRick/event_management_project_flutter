import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../widgets/event_card.dart';
import 'user_info_screen.dart'; // Import màn hình thông tin người dùng

class EventListScreen extends StatelessWidget {
  final EventService _eventService = EventService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Events"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<List<Event>>(
        stream: _eventService.getEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(fontSize: 18, color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No events found", style: TextStyle(fontSize: 18, color: Colors.black54)));
          } else {
            final events = snapshot.data!;
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: EventCard(event: events[index]),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepPurple[700],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        currentIndex: 0, // Giữ index của tab hiện tại
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User Info',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            // Chuyển đến màn hình thông tin người dùng khi chọn 'User Info'
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserInfoScreen()),
            );
          }
        },
      ),
    );
  }
}
