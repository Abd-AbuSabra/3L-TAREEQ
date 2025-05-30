import 'package:flutter/material.dart';
import 'package:flutter_application_33/service_provider/dashboard_SP.dart';
import 'package:flutter_application_33/service_provider/manage_services.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_application_33/service_provider/Pricing.dart';
import 'package:flutter_application_33/service_provider/SP_details.dart';
import 'package:flutter_application_33/service_provider/service_history_SP.dart';
import 'package:flutter_application_33/user/login.dart';
import 'package:flutter_application_33/user/service_history.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:circular_menu/circular_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_application_33/Gemini/gemini_page.dart';
import 'package:flutter_application_33/user/login.dart';

class SP_profile extends StatefulWidget {
  const SP_profile({super.key});

  @override
  State<SP_profile> createState() => _SP_profileState();
}

class _SP_profileState extends State<SP_profile> {
  String? selectedPayment;
  String userName = '"Name"';
  String formattedDate = "date";
  Map<String, dynamic>? userData;
  Map<String, dynamic> services = {}; // Initialize as empty map
  List<String> servicesList = []; // List of service names to pass
  String? profileImageUrl;
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  String getInitials(String name) {
    List<String> names = name.trim().split(" ");
    String initials = names.isNotEmpty ? names[0][0] : '';
    if (names.length > 1) initials += names[1][0];
    return initials.toUpperCase();
  }

  final Color avatarColor = Colors.teal; // Or generate randomly

  Future<void> fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('providers')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          userData = userDoc.data() as Map<String, dynamic>;

          setState(() {
            userName = userData!['username'] ?? '"Name"';
            Timestamp createdAt = userData!['createdAt'];
            DateTime createdAtDate = createdAt.toDate();
            formattedDate =
                "Joined: ${DateFormat('MMMM yyyy').format(createdAtDate)}"; // Example: May 2025
            profileImageUrl = userData!['profileImageUrl'];
            print("Profile Image URL: $profileImageUrl");
            // Properly extract services
            services = Map<String, dynamic>.from(
              userData!['services'] ?? {},
            );

            // Convert services map keys to a list
            servicesList = services.keys.toList();
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  final Color customGreen = const Color.fromARGB(255, 192, 228, 194);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // Fixed white content area
              Expanded(
                child: SafeArea(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 60,
                          width: 60,
                          child: logo(),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Service provider's profile",
                          style: TextStyle(
                            fontSize: 25,
                            color: customGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            height: 120,
                            width: 400,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 45,
                                    backgroundImage: profileImageUrl != null
                                        ? NetworkImage(profileImageUrl!)
                                        : const AssetImage('assets/profile.jpg')
                                            as ImageProvider,
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 30),
                                      Column(
                                        children: [
                                          Text(
                                            userName,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 7, 65, 115),
                                            ),
                                          ),
                                          Text(
                                            formattedDate,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 7, 65, 115),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            height: 170,
                            width: 400,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 7, 40, 89),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    SizedBox(width: 20),
                                    Icon(Icons.replay,
                                        size: 45, color: Colors.white),
                                  ],
                                ),
                                Column(
                                  children: const [
                                    SizedBox(height: 10),
                                    Text(
                                      '"Last Service"',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      '"Details"',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromRGBO(22, 121, 171, 1.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // This Spacer will push the blue container to the bottom
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
              // Fixed blue container at the bottom
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                child: Container(
                  width: double.infinity,
                  color: const Color.fromRGBO(22, 121, 171, 1.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 30),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              'Settings',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      ListTile(
                        title: const Text(
                          'Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.white),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SP_details()),
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                      ListTile(
                        title: const Text(
                          'Service history',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.white),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Services_SP()),
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                      ListTile(
                        title: const Text(
                          'Manage services',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.white),
                        onTap: () {
                          // Pass the services list to Manage_Services
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Manage_Services(
                                      selectedServices:
                                          servicesList, // Pass the list of service names
                                    )),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Login()),
                                (route) => false,
                              );
                            },
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: const Text(
                              'Log Out',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
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
                        builder: (context) => const Dashboard_SP()),
                  );
                },
              ),
              CircularMenuItem(
                icon: Icons.person,
                color: customGreen,
                iconColor: Colors.white,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SP_profile()),
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
                    MaterialPageRoute(builder: (context) => const GeminiPage()),
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
                    MaterialPageRoute(builder: (context) => const Login()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
