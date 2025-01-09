import 'package:flutter/material.dart';
import '../user/event_list_screen.dart';
import 'manage_event_screen.dart'; // Import trang ManageEventScreen
import 'create_event_screen.dart'; // Import trang CreateEventScreen
import 'QRScanner.dart'; // Import trang QRScanner

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B1B1B), // Nền xám đậm
      appBar: AppBar(
        title: Text(
          "Admin Dashboard",
          style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF2ECC71), // Màu xanh lá cây
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildElevatedButton(
                context,
                "Manage Events",
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManageEventScreen()),
                  );
                },
              ),
              SizedBox(height: 20),
              _buildElevatedButton(
                context,
                "Create New Event",
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateEventScreen()),
                  );
                },
              ),
              SizedBox(height: 20),
              _buildElevatedButton(
                context,
                "View Transactions",
                    () {
                  // Add functionality for viewing user transactions
                },
              ),
              SizedBox(height: 20),
              _buildElevatedButton(
                context,
                "Go to User Event List",
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EventListScreen()),
                  );
                },
              ),
              SizedBox(height: 20),
              _buildElevatedButton(
                context,
                "QR Scanner",
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QRScanner()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget để tạo một ElevatedButton đồng nhất với phong cách của ứng dụng
  ElevatedButton _buildElevatedButton(BuildContext context, String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF2ECC71), // Màu xanh lá cây
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        elevation: 5, // Bóng đổ cho nút
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Roboto',
          color: Colors.white,
        ),
      ),
    );
  }
}
