import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_33/google_maps/map.dart';
import 'package:flutter_application_33/service_provider/SP_profile.dart';
import 'package:flutter_application_33/service_provider/dashboard_SP.dart';
import 'package:flutter_application_33/service_provider/invoice_SP.dart';
import 'package:flutter_application_33/service_provider/chat_with_user.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_33/Gemini/gemini_page.dart';
import 'package:flutter_application_33/user/login.dart';
import 'package:flutter_application_33/pop_ups/cancel_sp.dart';
import 'dart:async';

// Create a new file: cancellation_service.dart
class CancellationService {
  static StreamSubscription<QuerySnapshot>? _listener;
  static bool _isInitialLoad = true;

  static void startListening(BuildContext context, String providerId) {
    stopListening(); // Clean up any existing listener

    _isInitialLoad = true;

    _listener = FirebaseFirestore.instance
        .collection('history')
        .where('providerId', isEqualTo: providerId)
        .where('status', isEqualTo: 'canceled')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      if (_isInitialLoad) {
        _isInitialLoad = false;
        return;
      }

      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Your service has been canceled'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );

          // Navigate to dashboard
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Dashboard_SP()),
            (Route<dynamic> route) => false,
          );
          break;
        }
      }
    });
  }

  static void stopListening() {
    _listener?.cancel();
    _listener = null;
  }
}
