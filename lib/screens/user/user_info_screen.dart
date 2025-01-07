import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../../widgets/navigation_helper.dart';
import 'wallet_screen.dart'; // Import WalletScreen

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final docSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _currentUser = user;
        _userData = docSnapshot.data();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Thông tin người dùng"),
          backgroundColor: Color(0xFF3498DB),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Thông tin người dùng"),
          backgroundColor: Color(0xFF3498DB),
        ),
        body: Center(
          child: Text(
            "Chưa có người dùng nào đăng nhập.",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    if (_userData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Thông tin người dùng"),
          backgroundColor: Color(0xFF3498DB),
        ),
        body: Center(
          child: Text(
            "Không tìm thấy dữ liệu người dùng.",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final userName = _userData!['name'] ?? 'N/A';
    final walletBalance = _userData!['walletBalance']?.toDouble() ?? 0.0;
    final role = _userData!['role'] ?? 'user';
    final userId = _currentUser!.uid; // Lấy userId từ currentUser

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF3498DB),
        title: Text("Thông tin cá nhân"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFFFC0CB), // Hồng nhạt
              child: Icon(Icons.person, size: 60, color: Color(0xFF8E44AD)),
            ),
            SizedBox(height: 20),
            Text(
              userName,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              _currentUser!.email ?? 'N/A',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 30),
            Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Icon(Icons.wallet, color: Colors.green),
                      title: Text(
                        "Số dư ví",
                        style: TextStyle(fontSize: 18),
                      ),
                      subtitle: Text(
                        "\$${walletBalance.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.arrow_forward, color: Colors.blue),
                        onPressed: () {
                          // Chuyển qua màn hình WalletScreen và truyền userId
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WalletScreen(userId: userId),
                            ),
                          );
                        },
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.person_outline, color: Colors.blue),
                      title: Text(
                        "Vai trò",
                        style: TextStyle(fontSize: 18),
                      ),
                      subtitle: Text(
                        role == 'admin' ? 'Quản trị viên' : 'Người dùng',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF8E44AD),
              Color(0xFF3498DB),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: CurvedNavigationBar(
          backgroundColor: Colors.transparent,
          color: Colors.white,
          buttonBackgroundColor: Color(0xFFFFC0CB),
          height: 60,
          index: 1,
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
