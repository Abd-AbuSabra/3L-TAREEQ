import 'package:flutter/material.dart';
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

class Services extends StatefulWidget {
  const Services({super.key});

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> with TickerProviderStateMixin {
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
  Widget build(BuildContext context) {
    return Menu(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            AnimatedBackground(
              vsync: this,
              behaviour: RandomParticleBehaviour(
                options: ParticleOptions(
                  spawnMaxRadius: 200,
                  spawnMinRadius: 10,
                  spawnMinSpeed: 10,
                  spawnMaxSpeed: 15,
                  particleCount: 3,
                  spawnOpacity: 0.1,
                  maxOpacity: 0.1,
                  baseColor: customGreen,
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      SizedBox(height: 60, width: 60, child: logo()),
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Service History",
                              style: TextStyle(
                                fontSize: 25,
                                color: customGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimationLimiter(
                        child: Column(
                          children: AnimationConfiguration.toStaggeredList(
                            duration: const Duration(milliseconds: 1600),
                            childAnimationBuilder: (widget) => SlideAnimation(
                              horizontalOffset: 100.0,
                              child: FadeInAnimation(child: widget),
                            ),
                            children: List.generate(4, (index) {
                              final bool isEven = index % 2 == 0;
                              final Color cardColor = isEven
                                  ? const Color.fromRGBO(22, 121, 171, 1.0)
                                  : const Color.fromARGB(255, 7, 40, 89);
                              final Color textColor = isEven
                                  ? const Color.fromARGB(255, 7, 40, 89)
                                  : const Color.fromRGBO(22, 121, 171, 1.0);

                              return Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Container(
                                  height: 170,
                                  width: 400,
                                  decoration: BoxDecoration(
                                    color: cardColor,
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
                                      Column(
                                        children: [
                                          const SizedBox(height: 10),
                                          const Text(
                                            '"Last Service"',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '"Details"',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
