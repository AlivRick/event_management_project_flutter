import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../../widgets/navigation_helper.dart';

class UserInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Thông tin người dùng"),
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(
          child: Text(
            "Chưa có người dùng nào đăng nhập.",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Lỗi: ${snapshot.error}",
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Text(
              "Không tìm thấy dữ liệu người dùng.",
              style: TextStyle(fontSize: 18),
            ),
          );
        } else {
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final userName = userData['name'] ?? 'N/A';
          final walletBalance = userData['wallet_balance']?.toDouble() ?? 0.0;
          final role = userData['role'] ?? 'user';

          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              backgroundColor: Colors.blueAccent,
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
                    backgroundColor: Colors.lightBlueAccent[100],
                    child: Icon(Icons.person, size: 60, color: Colors.blueAccent),
                  ),
                  SizedBox(height: 20),
                  Text(
                    userName,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user.email ?? 'N/A',
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
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.person_outline, color: Colors.lightBlue),
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
                  colors: [Colors.lightBlueAccent, Colors.cyanAccent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: CurvedNavigationBar(
                backgroundColor: Colors.transparent,
                color: Colors.white,
                buttonBackgroundColor: Colors.lightBlueAccent,
                height: 60,
                index: 1,
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
      },
    );
  }
}
