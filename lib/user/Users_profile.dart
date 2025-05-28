import 'package:flutter/material.dart';
import 'package:flutter_application_33/Gemini/gemini_page.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_application_33/service_provider/apply.dart';
import 'package:flutter_application_33/user/Users_details.dart';
import 'package:flutter_application_33/user/dashboard_user.dart';
import 'package:flutter_application_33/user/login.dart';
import 'package:flutter_application_33/user/service_history.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class users_profile extends StatefulWidget {
  const users_profile({super.key});

  @override
  State<users_profile> createState() => _users_profileState();
}

class _users_profileState extends State<users_profile> {
  final Color customGreen = const Color.fromARGB(255, 192, 228, 194);

  // User data variables
  String userName = '"Name"';
  String formattedDate = "date";
  Map<String, dynamic>? userData;

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
            .collection('users')
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
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                    "User's profile",
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
                              backgroundColor: avatarColor,
                              child: Text(
                                getInitials(userName),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 30),
                                Column(
                                  children: [
                                    const SizedBox(width: 60),
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 7, 65, 115),
                                      ),
                                    ),
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 7, 65, 115),
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
                        color: const Color.fromRGBO(22, 121, 171, 1.0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              SizedBox(width: 20),
                              Icon(Icons.replay, size: 45, color: Colors.white),
                            ],
                          ),
                          Column(
                            children: const [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '"Last Service"',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '"Details"',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 7, 40, 89),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: customGreen,
                      child: Column(
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
                          ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 15),
                              ListTile(
                                title: const Text(
                                  'Profile',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white),
                                onTap: () {
                                  if (userData != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => user_details(
                                              userData: userData!)),
                                    );
                                  } else {
                                    // Navigate anyway, the details page will handle loading
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const user_details()),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 15),
                              ListTile(
                                title: const Text('Service history',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Services()),
                                  );
                                },
                              ),
                              const SizedBox(height: 15),
                              ListTile(
                                title: const Text(
                                    'Register as a service provider',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Apply()),
                                  );
                                },
                              ),
                            ],
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
                                    (Route<dynamic> route) => false,
                                  );
                                },
                                icon: const Icon(Icons.logout,
                                    color: Colors.white),
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          CircularMenu(
            alignment: Alignment.bottomRight,
            toggleButtonColor: customGreen,
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
                },
              ),
              CircularMenuItem(
                icon: Icons.person,
                color: customGreen,
                iconColor: Colors.white,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('You are already on the profile page')),
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
                    (Route<dynamic> route) => false,
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
