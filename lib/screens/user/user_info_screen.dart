import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("User Info"),
          backgroundColor: Colors.deepPurple,
        ),
        body: Center(child: Text("No user is logged in.", style: TextStyle(fontSize: 18))),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text("User Info"),
              backgroundColor: Colors.deepPurple,
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text("User Info"),
              backgroundColor: Colors.deepPurple,
            ),
            body: Center(child: Text("Error: ${snapshot.error}", style: TextStyle(fontSize: 18))),
          );
        } else if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(
              title: Text("User Info"),
              backgroundColor: Colors.deepPurple,
            ),
            body: Center(child: Text("No user data found.", style: TextStyle(fontSize: 18))),
          );
        } else {
          // Lấy dữ liệu người dùng từ Firestore
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final userName = userData['name'] ?? 'N/A';
          final walletBalance = userData['wallet_balance']?.toDouble() ?? 0.0;
          final role = userData['role'] ?? 'user';

          return Scaffold(
            appBar: AppBar(
              title: Text("User Info"),
              backgroundColor: Colors.deepPurple,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Name: $userName",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Email: ${user.email ?? 'N/A'}",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Role: ${role == 'admin' ? 'Quản trị viên' : 'Người dùng'}",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Wallet Balance: \$${walletBalance.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 18, color: Colors.green[700]),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pop(context); // Đăng xuất và quay lại màn hình đăng nhập
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    ),
                    child: Text("Sign Out", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
