import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_application_33/user/otp.dart';
import 'package:animated_background/animated_background.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PN extends StatefulWidget {
  const PN({super.key});

  @override
  _PNState createState() => _PNState();
}

class _PNState extends State<PN> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _phoneController = TextEditingController();
  final Color customGreen = const Color.fromARGB(255, 192, 228, 194);
  bool _isLoading = false;
  RecaptchaVerifier? _recaptchaVerifier;

  // @override
  // void initState() {
  //   super.initState();
  //   if (kIsWeb) {
  //     _initializeRecaptcha();
  //   }
  // }

  // void _initializeRecaptcha() {
  //   if (!kIsWeb) return;

  //   try {
  //     _recaptchaVerifier = RecaptchaVerifier(
  //       container: 'recaptcha-container',
  //       size: RecaptchaVerifierSize.normal,
  //       theme: RecaptchaVerifierTheme.light,
  //       onSuccess: () {
  //         log("reCAPTCHA verified successfully.");
  //       },
  //       onError: (FirebaseAuthException error) {
  //         log("reCAPTCHA error: ${error.code} - ${error.message}");
  //       },
  //       onExpired: () {
  //         log("reCAPTCHA expired");
  //       },
  //     );
  //   } catch (e) {
  //     log("Error initializing reCAPTCHA: $e");
  //   }
  // }

  // Phone number validation
  bool _isValidPhoneNumber(String phone) {
    // Remove spaces and special characters except +
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Check if it starts with +962 (Jordan) and has correct length
    if (cleanPhone.startsWith('+962')) {
      // Jordan mobile numbers: +962 7XXXXXXXX (total 13 characters)
      return cleanPhone.length == 13 && cleanPhone.substring(4, 5) == '7';
    }

    return false;
  }

  // Format phone number to ensure it starts with +962
  String _formatPhoneNumber(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    // If starts with 962, add +
    if (cleanPhone.startsWith('962')) {
      return '+$cleanPhone';
    }

    // If starts with 07, replace with +9627
    if (cleanPhone.startsWith('07')) {
      return '+962${cleanPhone.substring(1)}';
    }

    // If starts with 7, add +962
    if (cleanPhone.startsWith('7') && cleanPhone.length == 9) {
      return '+962$cleanPhone';
    }

    // Return as is if already formatted
    return phone.startsWith('+') ? phone : '+962$cleanPhone';
  }

  Future<void> _sendVerificationCode() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showSnackBar('Please enter your phone number');
      return;
    }

    final formattedPhone = _formatPhoneNumber(phone);
    if (!_isValidPhoneNumber(formattedPhone)) {
      _showSnackBar('Please enter a valid Jordanian phone number');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (kIsWeb) {
        // WEB PLATFORM: Use signInWithPhoneNumber
        // if (_recaptchaVerifier == null) {
        //   _initializeRecaptcha();
        // }

        // This returns a ConfirmationResult, not a void
        final ConfirmationResult confirmationResult = await FirebaseAuth
            .instance
            .signInWithPhoneNumber(formattedPhone, _recaptchaVerifier);

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          _showSnackBar('Verification code sent!');
          // Navigate to OTP screen with confirmationResult for web
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTP(
                verificationId: '', // Not used for web
                phoneNumber: formattedPhone,
                resendToken: null,
                //  confirmationResult: confirmationResult, // Pass this for web
              ),
            ),
          );
        }
      } else {
        // MOBILE PLATFORMS: Use verifyPhoneNumber (no reCAPTCHA parameters)
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: formattedPhone,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async {
            setState(() {
              _isLoading = false;
            });
            try {
              await FirebaseAuth.instance.signInWithCredential(credential);
              log('Phone number automatically verified and user signed in.');
              if (mounted) {
                _showSnackBar('Phone number verified successfully!');
                // Add navigation logic here
              }
            } catch (e) {
              log('Error signing in with credential: $e');
              if (mounted) {
                _showSnackBar('Error during automatic verification');
              }
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            setState(() {
              _isLoading = false;
            });
            log('Phone number verification failed: ${e.code} - ${e.message}');

            String errorMessage;
            switch (e.code) {
              case 'invalid-phone-number':
                errorMessage = 'The phone number format is invalid';
                break;
              case 'too-many-requests':
                errorMessage = 'Too many requests. Please try again later';
                break;
              case 'invalid-app-credential':
                errorMessage = 'App verification failed. Please try again';
                break;
              default:
                errorMessage = 'Verification failed: ${e.message}';
            }

            if (mounted) {
              _showSnackBar(errorMessage);
            }
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() {
              _isLoading = false;
            });
            log('Verification code sent to $formattedPhone');

            if (mounted) {
              _showSnackBar('Verification code sent!');
              // Navigate to OTP screen for mobile
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OTP(
                    verificationId: verificationId,
                    phoneNumber: formattedPhone,
                    resendToken: resendToken,
                  ),
                ),
              );
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            log('Code auto-retrieval timeout for verificationId: $verificationId');
          },
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      log("Error during phone verification: $e");

      String errorMessage = 'An error occurred. Please try again.';
      if (e.toString().contains('reCAPTCHA')) {
        errorMessage =
            'reCAPTCHA verification failed. Please refresh and try again.';
        // if (kIsWeb) {
        //   _initializeRecaptcha();
        // }
      }

      if (mounted) {
        _showSnackBar(errorMessage);
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: customGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(
          color: Color.fromARGB(255, 144, 223, 170),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 30),
                    SizedBox(width: 100, height: 100, child: logo()),
                    const SizedBox(height: 100),
                    const Text(
                      "Enter your phone number",
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "We'll send you a verification code",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 80),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: customGreen),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset('lib/images/jordan.png',
                              height: 20, width: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: customGreen),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '07XXXXXXXX or +9627XXXXXXXX',
                                hintStyle: TextStyle(fontSize: 12),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                final formatted = _formatPhoneNumber(value);
                                if (!_isValidPhoneNumber(formatted)) {
                                  return 'Please enter a valid Jordanian phone number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    MaterialButton(
                      minWidth: double.infinity,
                      height: 55,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: customGreen,
                      textColor: Colors.white,
                      onPressed: _isLoading ? null : _sendVerificationCode,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Submit',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // reCAPTCHA container for web
          if (kIsWeb)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 0,
                child: const HtmlElementView(viewType: 'recaptcha-container'),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
