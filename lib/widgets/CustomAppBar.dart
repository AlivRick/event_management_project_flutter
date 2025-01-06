import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../screens/user/cart_screen.dart';

// Widget để tái sử dụng AppBar với nút giỏ hàng
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: Icon(Icons.shopping_cart),
          onPressed: () {
            // Khi nhấn nút giỏ hàng, chuyển sang màn hình giỏ hàng
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartScreen(), // Giỏ hàng
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
