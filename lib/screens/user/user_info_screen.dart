import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/navigation_helper.dart';
import '../auth/login_screen.dart';
import 'TicketScreen.dart';
import 'wallet_screen.dart';

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  int _selectedIndex = 2; // Chỉ số mục được chọn

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    NavigationHelper.navigateToScreen(context, index);
  }

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
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
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
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "Chưa có người dùng nào đăng nhập.",
            style: TextStyle(
                fontSize: 18, color: Colors.white, fontFamily: 'Roboto'),
          ),
        ),
      );
    }

    if (_userData == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "Không tìm thấy dữ liệu người dùng.",
            style: TextStyle(
                fontSize: 18, color: Colors.white, fontFamily: 'Roboto'),
          ),
        ),
      );
    }

    final userName = _userData!['name'] ?? 'N/A';
    final walletBalance = _userData!['walletBalance']?.toDouble() ?? 0.0;
    final role = _userData!['role'] ?? 'user';
    final userId = _currentUser!.uid;

    return Scaffold(
      backgroundColor: Color(0xFF1B1B1B), // Màu nền xám
      appBar: AppBar(
        backgroundColor: Color(0xFF2ECC71),
        title: Text(
          "Thông tin cá nhân",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFFFC0CB),
              child: Icon(Icons.person, size: 60, color: Color(0xFF8E44AD)),
            ),
            SizedBox(height: 20),
            Text(
              userName,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Roboto'),
            ),
            Text(
              _currentUser!.email ?? 'N/A',
              style: TextStyle(
                  fontSize: 16, color: Colors.white70, fontFamily: 'Roboto'),
            ),
            SizedBox(height: 30),
            Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Color(0xFF333333), // Thêm màu xám cho Card
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Icon(Icons.wallet, color: Colors.green),
                      title: Text(
                        "Số dư ví",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontFamily: 'Roboto'),
                      ),
                      subtitle: Text(
                        "${walletBalance.toStringAsFixed(0)}₫",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'Roboto'),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.arrow_forward, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WalletScreen(userId: userId),
                            ),
                          );
                        },
                      ),
                    ),
                    Divider(color: Colors.white),
                    ListTile(
                      leading: Icon(Icons.person_outline, color: Colors.blue),
                      title: Text(
                        "Vai trò",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontFamily: 'Roboto'),
                      ),
                      subtitle: Text(
                        role == 'admin' ? 'Quản trị viên' : 'Người dùng',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'Roboto'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2ECC71),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text(
                  "Đăng xuất",
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Roboto',
                      color: Colors.white),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false, // Xóa tất cả các màn hình trước đó
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF2ECC71), // Màu xanh lá khi chọn
        unselectedItemColor: Colors.white, // Màu trắng khi chưa chọn
        backgroundColor: Colors.grey, // Màu nền
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
