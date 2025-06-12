import 'package:flutter/material.dart';
import 'package:flutter_application_33/Gemini/gemini_page.dart';
import 'package:flutter_application_33/universal_components/Menu.dart';
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
import 'package:flutter_application_33/pop_ups/logout_popup.dart';

class users_profile extends StatefulWidget {
  const users_profile({super.key});

  @override
  State<users_profile> createState() => _users_profileState();
}

class _users_profileState extends State<users_profile> {
  final Color customGreen = const Color.fromARGB(255, 192, 228, 194);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to get latest service from history for current user
  Stream<QuerySnapshot> getLatestService() {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      return _firestore
          .collection('history')
          .where('userId', isEqualTo: currentUser.uid)
          .limit(1) // Get only the most recent one
          .snapshots();
    }
    return const Stream.empty();
  }

  // Method to calculate total price with tax
  double calculateTotalWithTax(Map<String, dynamic> services) {
    double total = 0;
    services.forEach((key, value) {
      if (value is num) {
        total += value.toDouble();
      }
    });
    // Add 16% tax
    return total * 1.16;
  }

  // Method to format timestamp
  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

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
    return Menu(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(
            color: const Color.fromARGB(255, 144, 223, 170),
          ),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Scrollable top content
            Expanded(
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 60,
                        width: 60,
                        child: logo(),
                      ),
                      const SizedBox(height: 18),
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
                                            color:
                                                Color.fromARGB(255, 7, 65, 115),
                                          ),
                                        ),
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromARGB(255, 7, 65, 115),
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
                                  color:
                                      const Color.fromRGBO(22, 121, 171, 1.0),
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
                                  color:
                                      const Color.fromRGBO(22, 121, 171, 1.0),
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
                                  color:
                                      const Color.fromRGBO(22, 121, 171, 1.0),
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
                                        color: Color.fromARGB(255, 7, 40, 89),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
// Get the latest service data
                            final doc = snapshot.data!.docs.first;
                            final data = doc.data() as Map<String, dynamic>;

                            final name = data['username'] as String? ?? "";
                            final services =
                                data['services'] as Map<String, dynamic>? ?? {};
                            final completedAt =
                                data['completedAt'] as Timestamp?;
                            final movedToHistoryAt =
                                data['movedToHistoryAt'] as Timestamp?;
                            final status =
                                (data['status'] as String?)?.toUpperCase() ??
                                    'COMPLETED';

// Determine if service was canceled
                            final isCanceled = status == 'CANCELED';
                            final totalWithTax = isCanceled
                                ? 0.00
                                : calculateTotalWithTax(services);

// Get the first service name (or total count)
                            String serviceDisplay = services.isEmpty
                                ? 'No services'
                                : services.length == 1
                                    ? services.keys.first
                                    : '${services.length} services';

// Set colors based on status
                            final statusColor =
                                isCanceled ? Colors.red : Colors.green;
                            final statusText =
                                isCanceled ? 'CANCELED' : 'COMPLETED';

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Services()),
                                );
                              },
                              child: Container(
                                height: 150,
                                width: 400,
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromRGBO(22, 121, 171, 1.0),
                                  borderRadius: BorderRadius.circular(20),
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
                                            margin:
                                                const EdgeInsets.only(left: 1),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: statusColor,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              statusText,
                                              style: const TextStyle(
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
                                          color: Color.fromARGB(255, 7, 40, 89),
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
                                            'Total: ${totalWithTax.toStringAsFixed(2)} JD',
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
                                              color: Color.fromARGB(
                                                  255, 7, 40, 89),
                                            ),
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
                    ],
                  ),
                ),
              ),
            ),
            // Bottom green container - always at bottom
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
              child: Container(
                width: double.infinity,
                color: customGreen,
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
                    Column(
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
                                    builder: (context) =>
                                        user_details(userData: userData!)),
                              );
                            } else {
                              // Navigate anyway, the details page will handle loading
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const user_details()),
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
                          title: const Text('Register as a service provider',
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
                            showLogoutDialog(context);
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
