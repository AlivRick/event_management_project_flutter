import 'package:flutter/material.dart';
import 'manage_event_screen.dart';

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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageEventScreen()),
                );
              },
              child: Text("Manage Events"),
            ),
            ElevatedButton(
              onPressed: () {
                // Add functionality for viewing user transactions
              },
              child: Text("View Transactions"),
            ),
          ],
        ),
      ),
    );
  }
}
