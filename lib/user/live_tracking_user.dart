import 'package:flutter/material.dart';
import 'package:flutter_application_33/google_maps/map.dart';
import 'package:flutter_application_33/universal_components/Menu.dart';

class live_track_user extends StatefulWidget {
  const live_track_user({super.key});

  @override
  State<live_track_user> createState() => _live_track_userState();
}

class _live_track_userState extends State<live_track_user> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Menu(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 235, 233, 233),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 620,
                  child: MapTrack(),
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: const Color.fromARGB(255, 192, 228, 194),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: 230,
                              width: 350,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        onPressed: () {},
                                        icon: const Icon(Icons.close),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const CircleAvatar(
                                              backgroundColor: Color.fromARGB(
                                                  255, 219, 218, 218),
                                              radius: 45,
                                              backgroundImage: AssetImage(
                                                  'assets/profile.jpg'),
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              "Rating: 4.8",
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    22, 121, 171, 1.0),
                                              ),
                                            ),
                                            const Row(
                                              children: [
                                                Icon(Icons.star,
                                                    color: Colors.yellow,
                                                    size: 15),
                                                Icon(Icons.star,
                                                    color: Colors.yellow,
                                                    size: 15),
                                                Icon(Icons.star,
                                                    color: Colors.yellow,
                                                    size: 15),
                                                Icon(Icons.star,
                                                    color: Colors.yellow,
                                                    size: 15),
                                                Icon(Icons.star,
                                                    color: Colors.yellow,
                                                    size: 15),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 30),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'SP Name',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(
                                                      22, 121, 171, 1.0),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              const Text(
                                                'Service',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color.fromRGBO(
                                                      22, 121, 171, 1.0),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                children: [
                                                  Card(
                                                    child: IconButton(
                                                      onPressed: () {},
                                                      icon: const Icon(
                                                        Icons.message_rounded,
                                                        color: Color.fromRGBO(
                                                            22, 121, 171, 1.0),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Card(
                                                    child: IconButton(
                                                      onPressed: () {},
                                                      icon: const Icon(
                                                        Icons.call,
                                                        color: Color.fromRGBO(
                                                            22, 121, 171, 1.0),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: -20,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  height: 40,
                                  width: 200,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Help is on the way !',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color:
                                              Color.fromRGBO(22, 121, 171, 1.0),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
