import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_application_33/circles/battery_circle.dart';
import 'package:flutter_application_33/circles/gas_circle_.dart';
import 'package:flutter_application_33/circles/tile_circle.dart';
import 'package:flutter_application_33/google_maps/map.dart';
import 'package:flutter_application_33/google_maps/user_map.dart';
import 'package:flutter_application_33/pop_over/my_buuton.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_application_33/user/search_for_service.dart';

class live_track_user extends StatefulWidget {
  const live_track_user({super.key});

  @override
  State<live_track_user> createState() => _live_track_userState();
}

class _live_track_userState extends State<live_track_user> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 235, 233, 233),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 620,
                child: Map_track(),
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
                      SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          //mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 40,
                            ),
                            Container(
                              height: 55,
                              width: 300,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: const [
                                    Text(
                                      "Help is on the way",
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 192, 228, 194),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                MyButton(),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 150,
                            width: 350,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 50,
                                        backgroundImage:
                                            AssetImage('assets/profile.jpg'),
                                      ),
                                      const SizedBox(width: 20),
                                      Column(
                                        children: const [
                                          SizedBox(height: 20),
                                          Text(
                                            'ayah',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Text(
                                                'service',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.yellow,
                                              ),
                                              Icon(
                                                Icons.star,
                                                color: Colors.yellow,
                                              ),
                                              Icon(
                                                Icons.star,
                                                color: Colors.yellow,
                                              ),
                                              Icon(
                                                Icons.star,
                                                color: Colors.yellow,
                                              ),
                                              Icon(
                                                Icons.star,
                                                color: Colors.yellow,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
