import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _listenForAcceptedProvider();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 50),
          SizedBox(height: 60, width: 60, child: logo()),
          const SizedBox(height: 150),
          Center(
            child: LottieBuilder.network(
              'https://lottie.host/b91cb2f2-1934-4dcd-aca4-30b2f675ccfd/PeSIiXLeX2.json',
              width: 350,
              height: 350,
            ),
          ),
        ],
      ),
    );
  }
}
