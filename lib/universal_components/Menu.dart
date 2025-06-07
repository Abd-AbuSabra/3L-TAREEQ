import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_33/pop_ups/logout_popup.dart';

import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_application_33/user/dashboard_user.dart';
import 'package:flutter_application_33/user/users_profile.dart';
import 'package:flutter_application_33/Gemini/gemini_page.dart';
import 'package:flutter_application_33/user/login.dart';

class Menu extends StatelessWidget {
  final Widget child;

  const Menu({super.key, required this.child});

  static const Color menuColor = Color.fromRGBO(22, 121, 171, 1.0);

  @override
  Widget build(BuildContext context) {
    return CircularMenu(
      alignment: Alignment.bottomRight,
      backgroundWidget: child,
      toggleButtonSize: 32,
      toggleButtonBoxShadow: [
        BoxShadow(
          color: Color.fromARGB(255, 7, 65, 115).withOpacity(0.3),
          blurRadius: 15,
          offset: Offset(0, 4),
        ),
      ],
      toggleButtonColor: menuColor,
      items: [
        CircularMenuItem(
          icon: Icons.home,
          iconSize: 26,
          color: menuColor,
          iconColor: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 7, 65, 115).withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const user_dashboard()),
            );
          },
        ),
        CircularMenuItem(
          iconSize: 26,
          icon: Icons.person,
          color: menuColor,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 7, 65, 115).withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
          iconColor: Colors.white,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const users_profile()),
            );
          },
        ),
        CircularMenuItem(
          iconSize: 26,
          icon: Icons.chat,
          color: menuColor,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 7, 65, 115).withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
          iconColor: Colors.white,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GeminiPage()),
            );
          },
        ),
        CircularMenuItem(
          iconSize: 26,
          icon: Icons.logout,
          color: Colors.red,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 7, 65, 115).withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
          iconColor: Colors.white,
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            showLogoutDialog(context);
          },
        ),
      ],
    );
  }
}
