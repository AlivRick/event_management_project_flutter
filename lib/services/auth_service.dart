import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Đăng ký người dùng mới với email và mật khẩu
  Future<User?> registerWithEmail(
      String email, String password, String name) async {
    try {
      UserCredential userCredential =
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Thêm thông tin người dùng vào Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'user', // Vai trò mặc định
          'walletBalance': 0.0, // Số dư ví khởi tạo
        }, SetOptions(merge: true)); // Tránh ghi đè dữ liệu đã có

        return user;
      }
    } catch (e) {
      print("Error in registerWithEmail: $e");
    }
    return null;
  }

  // Đăng nhập với email và mật khẩu
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential =
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw "No user found for that email.";
        case 'wrong-password':
          throw "Wrong password provided for that user.";
        case 'invalid-email':
          throw "The email address is not valid.";
        default:
          throw "An error occurred. Please try again.";
      }
    } catch (e) {
      throw "An error occurred: $e";
    }
  }
}
