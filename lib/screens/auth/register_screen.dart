import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Full Name"),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final user = await _authService.registerWithEmail(
                  _emailController.text,
                  _passwordController.text,
                  _nameController.text,
                );
                if (user != null) {
                  Navigator.pushReplacementNamed(context, '/event_list');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Registration failed")),
                  );
                }
              },
              child: Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
