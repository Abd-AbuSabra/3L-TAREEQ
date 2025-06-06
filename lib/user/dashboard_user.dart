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
import 'package:flutter_application_33/Gemini/gemini_page.dart';
import 'package:flutter_application_33/universal_components/Menu.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_application_33/user/Users_profile.dart';
import 'package:flutter_application_33/user/dashboard_user.dart';
import 'package:flutter_application_33/user/login.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:animated_background/animated_background.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class user_dashboard extends StatefulWidget {
  const user_dashboard({super.key});

  @override
  State<user_dashboard> createState() => _user_dashboardState();
}

class _user_dashboardState extends State<user_dashboard> {
  final Color customGreen = const Color.fromARGB(255, 192, 228, 194);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to move document from acceptedProviders to history
  Future<bool> moveToHistory(String userId) async {
    try {
      // Start a batch write to ensure atomicity
      WriteBatch batch = _firestore.batch();

      // Query the acceptedProviders collection for the document with matching userId
      QuerySnapshot acceptedProvidersQuery = await _firestore
          .collection('acceptedProviders')
          .where('userId', isEqualTo: userId)
          .get();

      if (acceptedProvidersQuery.docs.isEmpty) {
        print('No document found with userId: $userId');
        return false;
      }

      // Get the first matching document
      QueryDocumentSnapshot docToMove = acceptedProvidersQuery.docs.first;
      Map<String, dynamic> docData = docToMove.data() as Map<String, dynamic>;

      // Add timestamp for when it was moved to history
      docData['movedToHistoryAt'] = FieldValue.serverTimestamp();
      docData['status'] = 'completed'; // Optional: add status field

      // Add the document to history collection
      DocumentReference historyRef = _firestore.collection('history').doc();
      batch.set(historyRef, docData);

      // Delete the document from acceptedProviders collection
      batch.delete(docToMove.reference);

      // Commit the batch
      await batch.commit();

      print('Successfully moved document to history for userId: $userId');
      return true;
    } catch (e) {
      print('Error moving document to history: $e');
      return false;
    }
  }

  StreamSubscription<QuerySnapshot>? _bothEndsListener;

  void startListeningForBothEnds() {
    try {
      // Get current user ID
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId != null) {
        // Start listening to the document changes
        _bothEndsListener = FirebaseFirestore.instance
            .collection('acceptedProviders')
            .where('userId', isEqualTo: currentUserId)
            .snapshots()
            .listen((QuerySnapshot querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            final doc = querySnapshot.docs.first;
            final data = doc.data() as Map<String, dynamic>;

            bool userEnd = data['userEnd'] ?? false;
            bool providerEnd = data['providerEnd'] ?? false;

            if (userEnd && providerEnd) {
              print('Both userEnd and providerEnd are now true');
              // Trigger your action here
              _onBothEndsComplete();
            }
          }
        });
      } else {
        print('No current user found');
      }
    } catch (e) {
      print('Error setting up listener: $e');
    }
  }

  void _onBothEndsComplete() {
    // Call moveCurrentUserServiceToHistory when both ends are true
    print('Both ends completed - moving service to history');
    moveCurrentUserServiceToHistory();

    // Stop listening once both are true (optional)
    stopListening();
  }

  void stopListening() {
    _bothEndsListener?.cancel();
    _bothEndsListener = null;
  }

  // Method to move current user's service to history
  Future<void> moveCurrentUserServiceToHistory() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      bool success = await moveToHistory(currentUser.uid);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service moved to history successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the UI if needed
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to move service to history.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Method to get accepted providers for current user
  Stream<QuerySnapshot> getAcceptedProviders() {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      return _firestore
          .collection('acceptedProviders')
          .where('userId', isEqualTo: currentUser.uid)
          .snapshots();
    }
    return const Stream.empty();
  }

  // Method to get history for current user
  Stream<QuerySnapshot> getServiceHistory() {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      return _firestore
          .collection('history')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('movedToHistoryAt', descending: true)
          .snapshots();
    }
    return const Stream.empty();
  }

  @override
  void initState() {
    super.initState();
    startListeningForBothEnds();
  }

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
