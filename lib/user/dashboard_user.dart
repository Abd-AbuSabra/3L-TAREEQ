import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_33/Gemini/gemini_page.dart';
import 'package:flutter_application_33/components/auth_service.dart';
import 'package:flutter_application_33/google_maps/user_map.dart';
import 'package:flutter_application_33/universal_components/Menu.dart';
import 'package:flutter_application_33/user/Users_profile.dart';
import 'package:flutter_application_33/user/login.dart';
import 'package:flutter_application_33/user/search_for_service.dart';
import 'package:provider/provider.dart';

class user_dashboard extends StatefulWidget {
  const user_dashboard({super.key});

  @override
  State<user_dashboard> createState() => _user_dashboardState();
}

class _user_dashboardState extends State<user_dashboard> {
  @override
  Widget build(BuildContext context) {
    var customGreen;
    return SafeArea(
      child: Menu(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 235, 233, 233),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 750,
                  child: User_Map(),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: const Color.fromARGB(255, 192, 228, 194),
                    child: Column(
                      children: [
                        SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Looking for help?",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchForService(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(22, 121, 171, 1.0),
                            padding: EdgeInsets.symmetric(
                                horizontal: 80, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Request a service',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
                CircularMenu(
                  alignment: Alignment.bottomRight,
                  toggleButtonColor: customGreen,
                  toggleButtonIconColor: Colors.white,
                  items: [
                    CircularMenuItem(
                        icon: Icons.home,
                        color: customGreen,
                        iconColor: Colors.white,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const user_dashboard()),
                          );
                        }),
                    CircularMenuItem(
                      icon: Icons.person,
                      color: customGreen,
                      iconColor: Colors.white,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const users_profile()),
                        );
                      },
                    ),
                    CircularMenuItem(
                      icon: Icons.chat,
                      color: customGreen,
                      iconColor: Colors.white,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const GeminiPage()));
                      },
                    ),
                    CircularMenuItem(
                      icon: Icons.logout,
                      color: Colors.red,
                      iconColor: Colors.white,
                      onTap: () async {
                        await Provider.of<AuthService>(context, listen: false)
                            .signOut();

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login()),
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
