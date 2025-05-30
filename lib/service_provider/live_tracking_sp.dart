import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_33/google_maps/map.dart';
import 'package:flutter_application_33/service_provider/SP_profile.dart';
import 'package:flutter_application_33/service_provider/dashboard_SP.dart';
import 'package:flutter_application_33/service_provider/invoice_SP.dart';
import 'package:flutter_application_33/service_provider/chat_with_user.dart';

import 'package:flutter_application_33/Gemini/gemini_page.dart';
import 'package:flutter_application_33/user/login.dart';

const Color customGreen = Color(0xFF00A86B);

class live_track_SP extends StatefulWidget {
  const live_track_SP({super.key});

  @override
  State<live_track_SP> createState() => _live_track_SPState();
}

class _live_track_SPState extends State<live_track_SP> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? userData;
  String? documentId;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        setState(() {
          errorMessage = "Service provider not authenticated";
          isLoading = false;
        });
        return;
      }

      // Query the acceptedProviders collection where the current user is the provider
      final QuerySnapshot querySnapshot = await _firestore
          .collection('acceptedProviders')
          .where('providerId', isEqualTo: currentUser.uid)
          .where('isAccepted', isEqualTo: true)
          //  .orderBy('times', descending: true) // Get the most recent
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        setState(() {
          userData = doc.data() as Map<String, dynamic>;
          documentId = doc.id; // Store document ID for updates
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "No active service found";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching data: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _endService() async {
    try {
      if (documentId != null) {
        // Update the service status to mark as completed
        await _firestore
            .collection('acceptedProviders')
            .doc(documentId)
            .update({
          'isAccepted': false, // or add a 'completed' field
          'completedAt': FieldValue.serverTimestamp(),
        });

        // Navigate to invoice
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const invoice_SP(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error ending service: $e')),
      );
    }
  }

  String _getServicesText() {
    if (userData?['services'] == null) return 'Service details';

    Map<String, dynamic> services = userData!['services'];
    List<String> serviceList = [];

    services.forEach((key, value) {
      if (value is num && value > 0 && key != 'Service') {
        serviceList.add(key);
      }
    });

    return serviceList.isEmpty ? 'Service details' : serviceList.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 233, 233),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
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
                      color: const Color.fromRGBO(22, 121, 171, 1.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  height: 300,
                                  width: 350,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: IconButton(
                                            onPressed: () {
                                              // Refresh data
                                              _fetchUserData();
                                            },
                                            icon: const Icon(Icons.refresh),
                                          ),
                                        ),
                                        _buildContent(),
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
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Service in Progress',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Color.fromRGBO(
                                                22, 121, 171, 1.0),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
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
                  ),
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

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color.fromRGBO(22, 121, 171, 1.0),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 50,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchUserData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (userData == null) {
      return const Center(
        child: Text(
          'No user data available',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        // User Avatar (default since no profile image in your structure)
        const CircleAvatar(
          radius: 40,
          backgroundColor: Color.fromARGB(255, 219, 218, 218),
          child: Icon(Icons.person, size: 40, color: Colors.grey),
        ),

        Text(
          userData!['username'] ?? 'Unknown User',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),

        Text(
          _getServicesText(),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 5),
        if (userData!['userEmail'] != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: Colors.white,
                child: IconButton(
                  onPressed: () {
                    if (userData!['userId'] != null &&
                        userData!['userEmail'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatWithCustomer(
                            receiverUserID: userData!['userId'],
                            receiverEmail: userData!['userEmail'],
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.message_rounded,
                    size: 30,
                    color: Color.fromRGBO(22, 121, 171, 1.0),
                  ),
                ),
              ),
              const SizedBox(width: 40),
              Card(
                color: Colors.white,
                child: IconButton(
                  onPressed: () {
                    // Handle call functionality
                    String phoneNumber = userData!['userMobile'] ?? '';
                    if (phoneNumber.isNotEmpty) {
                      print('Call: $phoneNumber');
                      // You can use url_launcher here to make actual calls
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('No phone number available')),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.call,
                    size: 30,
                    color: Color.fromRGBO(22, 121, 171, 1.0),
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _endService,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'End the service',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
