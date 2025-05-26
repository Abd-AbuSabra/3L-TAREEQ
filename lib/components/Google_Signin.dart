import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInPage extends StatefulWidget {
  @override
  _GoogleSignInPageState createState() => _GoogleSignInPageState();
}

class _GoogleSignInPageState extends State<GoogleSignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;

  // Sign-in with Google using redirect mode
  Future<void> _signInWithGoogle() async {
    try {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      // Start the redirect flow
      await _auth.signInWithRedirect(authProvider);
    } catch (e) {
      print("Error during sign-in: $e");
    }
  }

  // Check for the redirect result after the sign-in flow completes
  Future<void> _checkRedirect() async {
    try {
      final result = await _auth.getRedirectResult();
      if (result.user != null) {
        setState(() {
          _user = result.user;
        });
      }
    } catch (e) {
      print("Error retrieving redirect result: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    // Only check the redirect result when the page is ready
    Future.delayed(
        Duration(seconds: 1), _checkRedirect); // Check after 1 second
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Google Sign-In (Redirect Mode)")),
      body: Center(
        child: _user == null
            ? CircularProgressIndicator() // Show a loading indicator while waiting for sign-in
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(_user!.photoURL ??
                        'https://www.example.com/default-avatar.png'),
                    radius: 30,
                  ),
                  SizedBox(height: 10),
                  Text("Hello, ${_user!.displayName}!"),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      setState(() {
                        _user = null;
                      });
                    },
                    child: Text("Sign Out"),
                  ),
                ],
              ),
      ),
    );
  }
}
