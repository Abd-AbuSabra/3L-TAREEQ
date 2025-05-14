import 'package:flutter/material.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_33/main.dart';
import 'package:flutter_application_33/user/dashboard_user.dart'; 
import 'package:flutter_application_33/user/Register.dart'; 
import 'package:flutter_application_33/components/authprovider.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  const OtpScreen({super.key, required this.verificationId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String? otpCode;

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 144, 223, 170),
                ),
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 30),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.arrow_back),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                       child: logo(),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Verification",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Enter the OTP sent to your phone number",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Pinput(
                        length: 6,
                        showCursor: true,
                        defaultPinTheme: PinTheme(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Color.fromARGB(255, 192, 228, 194),
                            ),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onCompleted: (value) {
                          setState(() {
                            otpCode = value;
                          });
                        },
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (otpCode != null) {
                              verifyOtp(context, otpCode!);
                            } else {
                              showSnackBar(context, "Enter 6-Digit code");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 192, 228, 194),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: Size(MediaQuery.of(context).size.width, 50),
                          ),
                          child: const Text(
                            "Verify",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Didn't receive any code?",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Resend New Code",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 192, 228, 194),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void verifyOtp(BuildContext context, String userOtp) {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    ap.verifyOtp(
      context: context,
      verificationId: widget.verificationId,
      userOtp: userOtp,
      onSuccess: () {
        ap.checkExistingUser().then((value) async {
          if (value == true) {
            ap.getDataFromFirestore().then(
              (value) => ap.saveUserDataToSP().then(
                    (value) => ap.setSignIn().then(
                          (value) => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const user_dashboard(),

                              ),
                              (route) => false),
                        ),
                  ),
            );
          } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Register()),
            (route) => false,
          );
        }
      });
    },
  );
}

  void showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }
}
