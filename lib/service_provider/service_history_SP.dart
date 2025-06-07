import 'package:flutter/material.dart';
import 'package:flutter_application_33/service_provider/SP_profile.dart';
import 'package:flutter_application_33/service_provider/dashboard_SP.dart';
import 'package:flutter_application_33/universal_components/menu_sp.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:animated_background/animated_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_33/Gemini/gemini_page.dart';
import 'package:flutter_application_33/user/login.dart';
import 'package:circular_menu/circular_menu.dart';
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

class Services_SP extends StatefulWidget {
  const Services_SP({super.key});

  @override
  State<Services_SP> createState() => _Services_SPState();
}

class _Services_SPState extends State<Services_SP>
    with TickerProviderStateMixin {
  final Color customGreen = const Color.fromARGB(255, 192, 228, 194);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to get history for current user
  Stream<QuerySnapshot> getServiceHistory() {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      return _firestore
          .collection('history')
          .where('providerId', isEqualTo: currentUser.uid)
          .orderBy('movedToHistoryAt', descending: true)
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
                      StreamBuilder<QuerySnapshot>(
                        stream: getServiceHistory(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(50.0),
                                child: Text(
                                  'No service history found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          }

                          final docs = snapshot.data!.docs;

                          return AnimationLimiter(
                            child: Column(
                              children: AnimationConfiguration.toStaggeredList(
                                duration: const Duration(milliseconds: 1600),
                                childAnimationBuilder: (widget) =>
                                    SlideAnimation(
                                  horizontalOffset: 100.0,
                                  child: FadeInAnimation(child: widget),
                                ),
                                children: docs.map<Widget>((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  final services = data['services']
                                          as Map<String, dynamic>? ??
                                      {};
                                  final username =
                                      data['name'] ?? 'Unknown User';
                                  final money = data['providerEarnings'] ?? 0;
                                  final completedAt =
                                      data['completedAt'] as Timestamp?;
                                  final totalWithTax =
                                      calculateTotalWithTax(services);

                                  final int index = docs.indexOf(doc);
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
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.history,
                                                  size: 35,
                                                  color: Colors.white),
                                              const SizedBox(width: 15),
                                              Expanded(
                                                child: Text(
                                                  username,
                                                  style: const TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          Text(
                                            'Services:',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ...services.entries
                                              .map<Widget>((entry) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '• ${entry.key}',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white70,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    '\$${entry.value}',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white70,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          const SizedBox(height: 10),
                                          const Divider(
                                              color: Colors.white30,
                                              thickness: 1),
                                          const SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Total (incl. 20% platform tax):',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
                                                ),
                                              ),
                                              Text(
                                                '${money.toStringAsFixed(2)} JD',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Completed: ${formatDate(completedAt)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white60,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
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
