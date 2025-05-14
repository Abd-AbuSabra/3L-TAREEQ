import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      await _firebaseFirestore.collection("users").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "email": email,
        "name": userCredential.user!.displayName ?? '',
      }, SetOptions(merge: true));

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception("Sign in failed: ${e.message}");
    }
  }

  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firebaseFirestore.collection("users").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "email": email,
        "name": userCredential.user!.displayName ?? '',
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception("Sign up failed: ${e.message}");
    }
  }


  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    if (gUser == null) return null;

    final GoogleSignInAuthentication gAuth = await gUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    try {
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      await _firebaseFirestore.collection("users").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "email": userCredential.user!.email,
        "name": userCredential.user!.displayName ?? '',
      }, SetOptions(merge: true));

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception("Google sign-in failed: ${e.message}");
    }
  }

  Future<void> addServiceRequest({
    required List<String> selectedServices,
    required List<String> selectedTimes,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception("No user logged in");

    try {
  
      await _firebaseFirestore.collection('userSelections').doc(user.uid).set({
        'services': selectedServices,
        'times': selectedTimes,
        'timestamp': FieldValue.serverTimestamp(),
      });

 
      await _firebaseFirestore.collection('serviceRequests').add({
        'userId': user.uid,
        'services': selectedServices,
        'times': selectedTimes,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to add service request: $e");
    }
  }

  Future<void> acceptServiceRequest({
    required String providerId,
    required String providerName,
    required String imageUrl,
    required int rating,
    required String time,
    required List<String> services,
  }) async {
    try {
      await _firebaseFirestore.collection('acceptedProviders').add({
        'providerId': providerId,
        'providerName': providerName,
        'imageUrl': imageUrl.isNotEmpty ? imageUrl : 'default',
        'rating': rating,
        'time': time,
        'services': services,
        'isAccepted': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to accept service request: $e");
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      throw Exception("Failed to sign out: $e");
    }
  }
}
