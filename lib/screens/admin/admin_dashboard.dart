import 'package:flutter/material.dart';
import '../user/event_list_screen.dart';
import 'manage_event_screen.dart'; // Import trang ManageEventScreen
import 'create_event_screen.dart'; // Import trang CreateEventScreen


class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Nút để chuyển sang trang ManageEventScreen
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageEventScreen()),
                );
              },
              child: Text("Manage Events"),
            ),
            SizedBox(height: 20), // Khoảng cách giữa các nút
            // Nút để chuyển sang trang CreateEventScreen
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateEventScreen()),
                );
              },
              child: Text("Create New Event"),
            ),
            SizedBox(height: 20), // Khoảng cách giữa các nút
            // Nút để xem giao dịch (chưa có chức năng)
            ElevatedButton(
              onPressed: () {
                // Add functionality for viewing user transactions
              },
              child: Text("View Transactions"),
            ),
            SizedBox(height: 20), // Khoảng cách giữa các nút
            // Nút để chuyển đến trang EventListScreen (cho người dùng)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventListScreen()), // Điều hướng tới trang người dùng
                );
              },
              child: Text("Go to User Event List"),
            ),
          ],
        ),
      ),
    );
  }
}
