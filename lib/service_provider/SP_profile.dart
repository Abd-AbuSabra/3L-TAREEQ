import 'package:flutter/material.dart';
import 'package:flutter_application_33/pop_ups/logout_popup.dart';
import 'package:flutter_application_33/service_provider/dashboard_SP.dart';
import 'package:flutter_application_33/service_provider/manage_services.dart';
import 'package:flutter_application_33/universal_components/menu_sp.dart';
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
import 'package:firebase_auth/firebase_auth.dart';

import 'package:circular_menu/circular_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
  double providerRating = 0;

  Map<String, dynamic> services = {}; // Initialize as empty map
  List<String> servicesList = []; // List of service names to pass
  String? profileImageUrl;
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
            providerRating = (userData!['rating'] ?? 0).toDouble();

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

  // Method to get latest service from history for current user
  Stream<QuerySnapshot> getLatestService() {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      return _firestore
          .collection('history')
          .where('providerId', isEqualTo: currentUser.uid)
          .orderBy('movedToHistoryAt', descending: true)
          .limit(1) // Get only the most recent one
          .snapshots();
    }
    return const Stream.empty();
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  final Color customGreen = const Color.fromARGB(255, 192, 228, 194);

  @override
  Widget build(BuildContext context) {
    return Menu_SP(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(
            color: const Color.fromARGB(255, 144, 223, 170),
          ),
        ),
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
                          const SizedBox(height: 10),
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
                                      backgroundColor: Colors.grey.shade100,
                                      radius: 45,
                                      backgroundImage: profileImageUrl != null
                                          ? NetworkImage(profileImageUrl!)
                                          : const AssetImage(
                                                  'assets/profile.jpg')
                                              as ImageProvider,
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 20),
                                        Column(
                                          children: [
                                            Text(
                                              userName,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 7, 65, 115),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            RatingBarIndicator(
                                              rating: providerRating,
                                              itemBuilder: (context, index) =>
                                                  Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              itemCount: 5,
                                              itemSize: 20.0,
                                              direction: Axis.horizontal,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              formattedDate,
                                              style: const TextStyle(
                                                fontSize: 12,
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
                            padding: const EdgeInsets.only(
                                top: 5.0, left: 20, right: 20, bottom: 10),
                            child: StreamBuilder<QuerySnapshot>(
                              stream: getLatestService(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container(
                                    height: 170,
                                    width: 400,
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                          22, 121, 171, 1.0),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.white),
                                    ),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return Container(
                                    height: 170,
                                    width: 400,
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                          22, 121, 171, 1.0),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Error loading service',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }

                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return Container(
                                    height: 170,
                                    width: 400,
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                          22, 121, 171, 1.0),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: const [
                                            SizedBox(width: 20),
                                            Icon(Icons.replay,
                                                size: 45, color: Colors.white),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        const Text(
                                          'No Service History',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Complete your first service',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                Color.fromARGB(255, 7, 40, 89),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                // Get the latest service data
                                final doc = snapshot.data!.docs.first;
                                final data = doc.data() as Map<String, dynamic>;

                                final name = data['name'] as String? ?? "";
                                final services =
                                    data['services'] as Map<String, dynamic>? ??
                                        {};
                                final completedAt =
                                    data['completedAt'] as Timestamp?;
                                final movedToHistoryAt =
                                    data['movedToHistoryAt'] as Timestamp?;
                                final money = data['providerEarnings'] ?? 0;

                                // Get the first service name (or total count)
                                String serviceDisplay = services.isEmpty
                                    ? 'No services'
                                    : services.length == 1
                                        ? services.keys.first
                                        : '${services.length} services';

                                return GestureDetector(
                                  onTap: () {
                                    // Navigate to another page - replace YourDestinationPage with your actual page
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Services_SP(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 150,
                                    width: 400,
                                    decoration: BoxDecoration(
                                      color:
                                          const Color.fromARGB(255, 7, 40, 89),
                                      borderRadius: BorderRadius.circular(20),
                                      // Add a subtle shadow to indicate it's pressable
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              const Color.fromARGB(255, 0, 0, 0)
                                                  .withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Last Service',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                name,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: 1),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                        vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  'COMPLETED',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            serviceDisplay,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: const Color.fromRGBO(
                                                  22, 121, 171, 1.0),
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Total: ${money.toStringAsFixed(2)} JD',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                formatDate(completedAt ??
                                                    movedToHistoryAt),
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: const Color.fromRGBO(
                                                        22, 121, 171, 1.0)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
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
                                showLogoutDialog(context);
                              },
                              icon:
                                  const Icon(Icons.logout, color: Colors.white),
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
          ],
        ),
      ),
    );
  }
}
