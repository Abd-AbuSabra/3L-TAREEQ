import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_33/Gemini/constt.dart';

import 'package:flutter_application_33/components/Google_Signin.dart';
import 'package:flutter_application_33/components/auth_service.dart';
import 'package:flutter_application_33/components/ver_code.dart';
import 'package:flutter_application_33/google_maps/SP_map.dart';
import 'package:flutter_application_33/google_maps/user_map.dart';
import 'package:flutter_application_33/service_provider/SP_details.dart';
import 'package:flutter_application_33/service_provider/SP_profile.dart';
import 'package:flutter_application_33/service_provider/dashboard_SP.dart';
import 'package:flutter_application_33/service_provider/Pricing.dart';

import 'package:flutter_application_33/service_provider/upload_profile_photo.dart';
import 'package:flutter_application_33/user/Payment.dart';
import 'package:flutter_application_33/user/PhoneNumber.dart';
import 'package:flutter_application_33/user/Users_details.dart';
import 'package:flutter_application_33/user/Users_profile.dart';
import 'package:flutter_application_33/user/dashboard_user.dart';

import 'package:flutter_application_33/user/invoice_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_33/user/live_tracking_user.dart';
import 'package:flutter_application_33/user/provider_reviews.dart';
import 'package:flutter_application_33/user/service_history.dart';
import 'package:flutter_application_33/user/service_prodiver_details.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

import 'components/firebase_options.dart';

import 'package:flutter_application_33/google_maps/map.dart';
import 'package:flutter_application_33/pop_ups/cancel_1.dart';
import 'package:flutter_application_33/pop_ups/confirm_1.dart';
import 'package:flutter_application_33/pop_ups/confirm_2.dart';
import 'package:flutter_application_33/pop_ups/received_popup.dart';
import 'package:flutter_application_33/pop_ups/rating.dart';
import 'package:flutter_application_33/service_provider/apply.dart';
import 'package:flutter_application_33/service_provider/invoice_SP.dart';
import 'package:flutter_application_33/user/Register.dart';
import 'package:flutter_application_33/universal_components/loading.dart';
import 'package:flutter_application_33/user/login.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_application_33/user/search_for_service.dart';
import 'package:flutter_application_33/user/select_service_provider.dart';
import 'package:flutter_application_33/universal_components/splash_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  Gemini.init(apiKey: GEMINI_API_KEY);
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((_) {
    print("Firebase Initialized Successfully!");
  }).catchError((e) {
    print("Error initializing Firebase: $e");
  });

  runApp(ChangeNotifierProvider(
    create: (context) => AuthService(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3l tareeq',
      debugShowCheckedModeBanner: false,
      home: FirebaseAuth.instance.currentUser != null
          ? user_dashboard()
          : Login(),
    );
  }
}
