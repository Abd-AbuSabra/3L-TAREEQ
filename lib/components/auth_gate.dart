import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_33/user/Register.dart';
import 'package:flutter_application_33/user/dashboard_user.dart';
import 'package:flutter_application_33/user/login.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  body: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), 
  builder: (context,snapshot)
  {

    if(snapshot.hasData){
return const user_dashboard();
    }

    else{
      return const Register();
    }
  }),
    );
  }
}