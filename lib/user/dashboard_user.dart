import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_application_33/circles/battery_circle.dart';
import 'package:flutter_application_33/circles/gas_circle_.dart';
import 'package:flutter_application_33/circles/tile_circle.dart';
import 'package:flutter_application_33/google_maps/user_map.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_application_33/user/search_for_service.dart';

class user_dashboard extends StatefulWidget {
  const user_dashboard({super.key});

  @override
  State<user_dashboard> createState() => _user_dashboardState();
}

class _user_dashboardState extends State<user_dashboard> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                                  color: Colors.grey,
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
            ],
          ),
        ),
        bottomNavigationBar: CurvedNavigationBar(
          height: 40,
          backgroundColor: const Color.fromARGB(255, 192, 228, 194),
          color: const Color.fromARGB(255, 192, 228, 194),
          animationDuration: Duration(milliseconds: 300),
          items: [
            Icon(Icons.chat_bubble_outline_rounded, size: 25, color: Colors.white),
            Icon(Icons.home_rounded, size: 25, color: Colors.white),
            Icon(Icons.person_2_rounded, size: 25, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
