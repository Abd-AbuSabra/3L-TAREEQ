import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String userOtp,
    required Function onSuccess,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

    
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOtp,
      );

     
      await _auth.signInWithCredential(credential);

      
      onSuccess();
    } catch (e) {
 
      _isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Verification failed: $e")));
    }
  }

  Future<bool> checkExistingUser() async {
   
    return true; 
  }

  
  Future<void> getDataFromFirestore() async {
    
  }

  Future<void> saveUserDataToSP() async {
  
  }

  Future<void> setSignIn() async {
 
  }
}
