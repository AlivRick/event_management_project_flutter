import 'package:flutter/material.dart';

import '../screens/user/TicketScreen.dart';
import '../screens/user/event_list_screen.dart';
import '../screens/user/user_info_screen.dart';

class NavigationHelper {
  static void navigateToScreen(BuildContext context, int index) {
    Widget screen;
    switch (index) {
      case 0:
        screen = EventListScreen();
        break;
      case 1:
        screen = TicketScreen();  // Thêm trường hợp cho TicketScreen
        break;
      case 2:
        screen = UserInfoScreen();
        break;
      default:
        screen = EventListScreen();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}