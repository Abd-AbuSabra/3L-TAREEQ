import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_application_33/user/dashboard_user.dart';
import 'package:flutter_application_33/user/users_profile.dart';
import 'package:flutter_application_33/Gemini/gemini_page.dart';
import 'package:flutter_application_33/user/login.dart';
import 'package:flutter_application_33/service_provider/SP_details.dart';
import 'package:flutter_application_33/service_provider/SP_profile.dart';
import 'package:flutter_application_33/service_provider/dashboard_SP.dart';
import 'package:flutter_application_33/service_provider/Pricing.dart';
import 'package:flutter_application_33/pop_ups/logout_popup.dart';

import 'package:flutter_application_33/service_provider/upload_profile_photo.dart';
import 'package:flutter_application_33/user/Payment.dart';

class Menu_SP extends StatelessWidget {
  final Widget child;

  const Menu_SP({super.key, required this.child});

  static const Color menuColor = const Color.fromARGB(255, 192, 228, 194);

  @override
  Widget build(BuildContext context) {
    return CircularMenu(
      alignment: Alignment.bottomRight,
      backgroundWidget: child,
      toggleButtonIconColor: Colors.white,
      toggleButtonSize: 32,
      toggleButtonBoxShadow: [
        BoxShadow(
          color: Color.fromARGB(255, 7, 65, 115).withOpacity(0.3),
          blurRadius: 8,
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
              MaterialPageRoute(builder: (_) => const Dashboard_SP()),
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
              MaterialPageRoute(builder: (_) => const SP_profile()),
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
