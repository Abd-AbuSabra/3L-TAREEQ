import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:animated_background/animated_background.dart';
import 'package:flutter_application_33/user/dashboard_user.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class OTP extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final int? resendToken;

  const OTP({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    this.resendToken,
  });

  @override
  _OTPState createState() => _OTPState();
}

class _OTPState extends State<OTP> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final Color customGreen = const Color.fromARGB(255, 192, 228, 194);

  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 0;
  Timer? _timer;
  String _currentVerificationId = '';
  RecaptchaVerifier? _recaptchaVerifier;

  // @override
  // void initState() {
  //   super.initState();
  //   _currentVerificationId = widget.verificationId;
  //   _startResendCountdown();
  //   if (kIsWeb) {
  //     _initializeRecaptcha();
  //   }
  // }

  // void _initializeRecaptcha() {
  //   if (!kIsWeb) return;

  //   try {
  //     _recaptchaVerifier = RecaptchaVerifier(
  //       auth:AboutDialog(  ),
  //       container: 'recaptcha-container',
  //       size: RecaptchaVerifierSize.compact,
  //       theme: RecaptchaVerifierTheme.light,
  //       onSuccess: () {
  //         log("reCAPTCHA verified successfully for resend.");
  //       },
  //       onError: (FirebaseAuthException error) {
  //         log("reCAPTCHA error during resend: ${error.code} - ${error.message}");
  //       },
  //       onExpired: () {
  //         log("reCAPTCHA expired during resend");
  //       },
  //     );
  //   } catch (e) {
  //     log("Error initializing reCAPTCHA for resend: $e");
  //   }
  // }

  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 60; // 60 seconds countdown
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_resendCountdown > 0) {
          setState(() {
            _resendCountdown--;
          });
        } else {
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }

  String get _otpCode {
    return _otpControllers.map((controller) => controller.text).join();
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && value.length == 1) {
      // Move to next field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // All fields filled, auto-verify
        _focusNodes[index].unfocus();
        if (_otpCode.length == 6) {
          _verifyOTP();
        }
      }
    } else if (value.isEmpty) {
      // Move to previous field on backspace
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    } else if (value.length > 1) {
      // Handle paste operation
      _handlePastedCode(value, index);
    }
  }

  void _handlePastedCode(String pastedValue, int startIndex) {
    // Remove non-digits and limit to 6 characters
    String cleanCode = pastedValue.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanCode.length > 6) {
      cleanCode = cleanCode.substring(0, 6);
    }

    // Clear all fields first
    _clearOtpFields();

    // Fill fields with pasted code
    for (int i = 0; i < cleanCode.length && i < 6; i++) {
      _otpControllers[i].text = cleanCode[i];
    }

    // Focus on the next empty field or unfocus if all filled
    if (cleanCode.length < 6) {
      _focusNodes[cleanCode.length].requestFocus();
    } else {
      _focusNodes[5].unfocus();
      // Auto-verify if 6 digits are pasted
      _verifyOTP();
    }
  }

  Future<void> _verifyOTP() async {
    final otpCode = _otpCode;

    if (otpCode.length != 6) {
      _showSnackBar('Please enter the complete 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _currentVerificationId,
        smsCode: otpCode,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      log("Phone verification successful for user: ${userCredential.user?.uid}");

      if (mounted) {
        // Show success message
        _showSnackBar('Phone number verified successfully!');

        // Small delay to show success message before navigation
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate to dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const user_dashboard()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      String errorMessage = 'Verification failed. Please try again.';

      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage =
              'Invalid verification code. Please check and try again.';
          break;
        case 'session-expired':
          errorMessage =
              'Verification code has expired. Please request a new one.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later.';
          break;
        case 'credential-already-in-use':
          errorMessage = 'This phone number is already registered.';
          break;
        default:
          errorMessage = e.message ?? errorMessage;
      }

      log("OTP Verification Error: ${e.code} - ${e.message}");
      if (mounted) {
        _showSnackBar(errorMessage);
        // Clear OTP fields on error
        _clearOtpFields();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      log("Unexpected error during OTP verification: $e");
      if (mounted) {
        _showSnackBar('An unexpected error occurred. Please try again.');
        _clearOtpFields();
      }
    }
  }

  void _clearOtpFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    if (mounted) {
      _focusNodes[0].requestFocus();
    }
  }

  Future<void> _resendOTP() async {
    if (_resendCountdown > 0 || _isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      // Re-initialize reCAPTCHA if needed for web
      // if (kIsWeb && _recaptchaVerifier == null) {
      //   _initializeRecaptcha();
      // }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: widget.resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          setState(() {
            _isResending = false;
          });
          log("Phone verification completed automatically during resend");

          // Auto-sign in if verification completed
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            if (mounted) {
              _showSnackBar('Phone number verified automatically!');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const user_dashboard()),
              );
            }
          } catch (e) {
            log('Error during auto sign-in: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isResending = false;
          });
          log("Resend verification failed: ${e.code} - ${e.message}");

          String errorMessage = 'Failed to resend code. Please try again.';
          switch (e.code) {
            case 'too-many-requests':
              errorMessage =
                  'Too many requests. Please wait before trying again.';
              break;
            case 'invalid-phone-number':
              errorMessage = 'Invalid phone number format.';
              break;
          }

          if (mounted) {
            _showSnackBar(errorMessage);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isResending = false;
          });

          // Update the verification ID for the new code
          _currentVerificationId = verificationId;

          if (mounted) {
            _showSnackBar('New verification code sent!');
            _startResendCountdown();
            _clearOtpFields();
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _isResending = false;
          });
          log("Code auto-retrieval timeout during resend");
        },
      );
    } catch (e) {
      setState(() {
        _isResending = false;
      });
      log("Error during OTP resend: $e");
      if (mounted) {
        _showSnackBar('Failed to resend code. Please try again.');
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
          duration: const Duration(seconds: 3),
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
      body: AnimatedBackground(
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
                const SizedBox(height: 60),
                const Text(
                  "OTP Verification",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Enter the 6-digit code sent to\n${widget.phoneNumber}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 60),

                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 45,
                      height: 55,
                      child: TextFormField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: customGreen),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: customGreen, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: customGreen.withOpacity(0.5)),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) => _onOtpChanged(value, index),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 40),

                // Resend Code Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Didn't receive the code? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: _resendCountdown > 0 || _isResending
                          ? null
                          : _resendOTP,
                      child: _isResending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _resendCountdown > 0
                                  ? 'Resend in ${_resendCountdown}s'
                                  : 'Resend Code',
                              style: TextStyle(
                                color: _resendCountdown > 0
                                    ? Colors.grey
                                    : customGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Verify Button
                MaterialButton(
                  minWidth: double.infinity,
                  height: 55,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: customGreen,
                  textColor: Colors.white,
                  onPressed: _isLoading ? null : _verifyOTP,
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
                          'Verify Code',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 20),

                // Helper text
                const Text(
                  'You can paste the 6-digit code directly',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}
