import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../admin/admin_dashboard.dart';
import '../auth/login_screen.dart';
import 'event_list_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color _primaryColor = Color(0xFF2ECC71); // Green from login screen
  final Color _backgroundColor = Color(0xFF1B1B1B); // Dark background

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  // Function to check the login status and role
  Future<void> _checkUserStatus() async {
    await Future.delayed(Duration(seconds: 3)); // Chờ 3 giây

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Nếu chưa đăng nhập, chuyển đến màn hình đăng nhập
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      // Kiểm tra vai trò của người dùng trong Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final role = userDoc.data()?['role'];

        if (role == 'admin') {
          // Nếu là admin, chuyển đến AdminDashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboard()),
          );
        } else {
          // Nếu là user bình thường, chuyển đến EventListScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EventListScreen()),
          );
        }
      } else {
        // Nếu không có dữ liệu người dùng trong Firestore, chuyển đến màn hình đăng nhập
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 100, color: _primaryColor),
            SizedBox(height: 20),
            Text(
              "Welcome to Event Management App!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
                fontFamily: 'Roboto',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              color: _primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
