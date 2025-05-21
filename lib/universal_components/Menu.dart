import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:circular_menu/circular_menu.dart';

// Import your custom widgets/screens
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_application_33/user/dashboard_user.dart';
import 'package:flutter_application_33/user/users_profile.dart';
import 'package:flutter_application_33/Gemini/gemini_page.dart';
import 'package:flutter_application_33/user/login.dart';

class Menu extends StatelessWidget {
  final Widget child; // Add this

  const Menu({super.key, required this.child}); // Require child

  @override
  Widget build(BuildContext context) {
    return CircularMenu(
      alignment: Alignment.bottomRight,
      backgroundWidget: child, // Use passed child as background
      items: [
        CircularMenuItem(
          icon: Icons.home,
          color: Colors.green,
          iconColor: Colors.white,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const user_dashboard()),
            );
          },
        ),
        CircularMenuItem(
          icon: Icons.person,
          color: Colors.green,
          iconColor: Colors.white,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const users_profile()),
            );
          },
        ),
        CircularMenuItem(
          icon: Icons.chat,
          color: Colors.green,
          iconColor: Colors.white,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GeminiPage()),
            );
          },
        ),
        CircularMenuItem(
          icon: Icons.logout,
          color: Colors.red,
          iconColor: Colors.white,
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const Login()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }
}
