import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_33/Gemini/gemini_page.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_application_33/user/select_service_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  final _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot>? _subscription;
  bool _showButton = false;
  Timer? _buttonTimer;

  @override
  void initState() {
    super.initState();
    _listenForAcceptedProvider();
    _startButtonTimer();
  }

  void _startButtonTimer() {
    _buttonTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _showButton = true;
        });
      }
    });
  }

  void _listenForAcceptedProvider() {
    final user = _auth.currentUser;
    if (user == null) return;

    _subscription = FirebaseFirestore.instance
        .collection('acceptedProviders')
        .where('userId', isEqualTo: user.uid)
        .where('isAccepted', isEqualTo: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final providerData =
            snapshot.docs.first.data() as Map<String, dynamic>?;
        if (providerData != null && mounted) {
          _subscription?.cancel(); // prevent multiple triggers
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ServiceProviderPage(providerData: providerData),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _buttonTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 50),
          SizedBox(height: 90, width: 90, child: logo()),
          const SizedBox(height: 150),
          Center(
            child: LottieBuilder.network(
              'https://lottie.host/b91cb2f2-1934-4dcd-aca4-30b2f675ccfd/PeSIiXLeX2.json',
              width: 350,
              height: 350,
            ),
          ),
          const SizedBox(height: 50),
          if (_showButton)
            Column(
              children: [
                const Text(
                  'Searching for service providers.',
                  style: TextStyle(
                    color: Color.fromARGB(255, 7, 65, 115),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Text(
                  'In the meantime, our chatbot is here with helpful',
                  style: TextStyle(
                    color: Color.fromARGB(255, 7, 65, 115),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Text(
                  'tips and tricks.',
                  style: TextStyle(
                    color: Color.fromARGB(255, 7, 65, 115),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      // Replace with your desired navigation
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GeminiPage(), // Replace with your target page
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 192, 228, 194),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    )),
              ],
            ),
        ],
      ),
    );
  }
}
