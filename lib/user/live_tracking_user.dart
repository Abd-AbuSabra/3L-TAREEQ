import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_33/google_maps/map.dart';
import 'package:flutter_application_33/universal_components/Menu.dart';
import 'package:flutter_application_33/user/chat_with_provider.dart';
import 'package:flutter_application_33/service_provider/dashboard_SP.dart';
import 'package:flutter_application_33/service_provider/SP_profile.dart';
import 'package:flutter_application_33/service_provider/upload_profile_photo.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:flutter_application_33/components/auth_service.dart';
import 'package:flutter_application_33/components/my_text_field.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_application_33/user/Register.dart';
import 'package:flutter_application_33/user/Users_profile.dart';
import 'package:flutter_application_33/user/search_for_service.dart';
import 'package:flutter_application_33/user/PhoneNumber.dart';
import 'package:flutter_application_33/user/chat_with_provider.dart';
import 'package:flutter_application_33/user/Invoice_user.dart'; // Add this import

import 'package:flutter_application_33/user/dashboard_user.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animated_background/animated_background.dart';
import 'package:flutter_application_33/components/Google_Signin.dart';

class live_track_user extends StatefulWidget {
  const live_track_user({super.key});

  @override
  State<live_track_user> createState() => _live_track_userState();
}

class _live_track_userState extends State<live_track_user> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? providerData;
  bool isLoading = true;
  String? errorMessage;
  StreamSubscription<DocumentSnapshot>? _acceptedProviderSubscription;
  String? _documentId; // Store the document ID for monitoring

  @override
  void initState() {
    super.initState();
    _fetchProviderData();
  }

  @override
  void dispose() {
    _acceptedProviderSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchProviderData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        setState(() {
          errorMessage = "User not authenticated";
          isLoading = false;
        });
        return;
      }

      // Query the acceptedProviders collection based on user UID
      final QuerySnapshot querySnapshot = await _firestore
          .collection('acceptedProviders')
          .where('userId', isEqualTo: currentUser.uid)
          .limit(1) // Assuming you want the most recent accepted provider
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        _documentId = doc.id; // Store the document ID

        setState(() {
          providerData = doc.data() as Map<String, dynamic>;
          isLoading = false;
        });

        // Start monitoring the isAccepted field
        _startMonitoringAcceptedStatus();
      } else {
        setState(() {
          errorMessage = "No accepted provider found";
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

  void _startMonitoringAcceptedStatus() {
    if (_documentId == null) return;

    _acceptedProviderSubscription = _firestore
        .collection('acceptedProviders')
        .doc(_documentId)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final isAccepted = data['isAccepted'] ?? true;

        if (!isAccepted) {
          // Navigate to Invoice_user page when isAccepted becomes false
          _acceptedProviderSubscription?.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Invoice_user(),
            ),
          );
        }
      }
    });
  }

  String _getServicesText() {
    if (providerData?['services'] == null) return 'Service details';

    Map<String, dynamic> services = providerData!['services'];
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
                                        color: Colors.red,
                                        onPressed: () {},
                                        icon: const Icon(Icons.cancel),
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
          ],
        ),
      );
    }

    if (providerData == null) {
      return const Center(
        child: Text(
          'No provider data available',
          style: TextStyle(
            fontSize: 16,
            color: Color.fromRGBO(22, 121, 171, 1.0),
          ),
        ),
      );
    }

    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: const Color.fromARGB(255, 219, 218, 218),
              radius: 45,
              backgroundImage: providerData!['profileImageUrl'] != null
                  ? NetworkImage(providerData!['profileImageUrl'])
                  : const AssetImage('assets/profile.jpg') as ImageProvider,
            ),
            const SizedBox(height: 8),
            RatingBarIndicator(
              rating: providerData!['rating']?.toDouble() ?? 0.0,
              itemBuilder: (context, index) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              itemCount: 5,
              itemSize: 20.0,
              direction: Axis.horizontal,
            ),
          ],
        ),
        const SizedBox(width: 30),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                providerData!['username'] ?? 'Unknown Provider',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(22, 121, 171, 1.0),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _getServicesText(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromRGBO(22, 121, 171, 1.0),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Card(
                    child: IconButton(
                      onPressed: () {
                        // Navigate to chat/message screen
                        if (providerData!['providerId'] != null &&
                            providerData!['name'] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                receiverUserID: providerData!['providerId'],
                                receiverName: providerData!['name'],
                              ),
                            ),
                          );
                        } else {
                          print(
                              "${providerData!['providerId']}${providerData!['providerEmail']}");
                        }
                      },
                      icon: const Icon(
                        Icons.message_rounded,
                        color: Color.fromRGBO(22, 121, 171, 1.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Card(
                    child: IconButton(
                      onPressed: () {
                        // Handle call functionality
                        // You might want to use url_launcher to make a phone call
                        // or navigate to a calling screen
                        print('Call: ${providerData!['phoneNumber']}');
                      },
                      icon: const Icon(
                        Icons.call,
                        color: Color.fromRGBO(22, 121, 171, 1.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStarRating(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(const Icon(Icons.star, color: Colors.yellow, size: 15));
      } else if (i == fullStars && hasHalfStar) {
        stars.add(const Icon(Icons.star_half, color: Colors.yellow, size: 15));
      } else {
        stars
            .add(const Icon(Icons.star_border, color: Colors.yellow, size: 15));
      }
    }

    return Row(children: stars);
  }
}
