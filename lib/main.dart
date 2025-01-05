import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
// Import màn hình đăng nhập
import 'screens/admin/admin_dashboard.dart'; // Import màn hình dành cho Admin
import 'screens/user/event_list_screen.dart';
import 'screens/user/home_screen.dart'; // Import màn hình dành cho User

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AuthWrapper(), // Kiểm tra trạng thái và điều hướng
      debugShowCheckedModeBanner: false,
    );
  }
}

// AuthWrapper để điều hướng giữa Admin, User và màn hình đăng nhập
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Nếu chưa có dữ liệu từ Firebase Auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;

        if (user == null) {
          // Nếu chưa đăng nhập, hiển thị trang Home
          return HomeScreen();
        } else {
          // Nếu đã đăng nhập, kiểm tra vai trò
          return FutureBuilder<bool>(
            future: checkIfAdmin(user),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Đã xảy ra lỗi: ${snapshot.error}'),
                );
              } else if (snapshot.hasData && snapshot.data == true) {
                return AdminDashboard(); // Màn hình Admin
              } else {
                return EventListScreen(); // Màn hình User
              }
            },
          );
        }
      },
    );
  }

  // Hàm kiểm tra vai trò người dùng từ Firestore
  Future<bool> checkIfAdmin(User user) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Kiểm tra dữ liệu từ Firestore
      if (userDoc.exists) {
        final role = userDoc.data()?['role'];
        return role == 'admin'; // Trả về true nếu là admin
      } else {
        return false; // Người dùng không tồn tại trong Firestore
      }
    } catch (e) {
      throw Exception('Không thể kiểm tra vai trò người dùng: $e');
    }
  }
}

