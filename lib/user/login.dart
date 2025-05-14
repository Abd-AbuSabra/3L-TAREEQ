import 'package:flutter/material.dart';
import 'package:flutter_application_33/universal_components/Botton_nav_bar.dart';
import 'package:flutter_application_33/components/auth_service.dart';
import 'package:flutter_application_33/components/my_text_field.dart'; // Make sure to import your custom widget here
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_application_33/user/Register.dart';
import 'package:flutter_application_33/user/Users_profile.dart';
import 'package:flutter_application_33/user/dashboard_user.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animated_background/animated_background.dart';
import 'package:flutter_application_33/components/Google_Signin.dart'; // Make sure to import your custom widget here

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isObscurePassword = true;

  void login() async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      // Try signing in the user with Firebase
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If the login is successful, proceed with the dashboard
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => users_profile()),
      );
    } catch (e) {
      // Check if it's a FirebaseAuthException and handle specific errors
      if (e is FirebaseAuthException) {
        if (e.code == 'invalid-email') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user found with this email')),
          );
        } else if (e.code == 'invalid-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect password')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${e.code}')),
          );
          print(e.message);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customGreen = const Color.fromARGB(255, 192, 228, 194);

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBackground(
        vsync: this,
        behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
            spawnMaxRadius: 200,
            spawnMinRadius: 10,
            spawnMinSpeed: 10,
            spawnMaxSpeed: 15,
            particleCount: 4,
            spawnOpacity: 0.1,
            maxOpacity: 0.1,
            baseColor: customGreen,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: logo(),
                  ),
                  const SizedBox(height: 50),
                  const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 45,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: TextFormField(
                        controller: emailController,
                        obscureText: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          final emailRegex =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle:
                              TextStyle(fontSize: 16, color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFFF1F1F1),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      )),
                  Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: isObscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle:
                              TextStyle(fontSize: 16, color: Colors.grey),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isObscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            color: Colors.grey,
                            onPressed: () {
                              setState(() {
                                isObscurePassword = !isObscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF1F1F1),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      )),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customGreen,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 150, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GoogleSignInPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const FaIcon(
                        FontAwesomeIcons.google,
                        color: Colors.grey,
                        size: 25,
                      ),
                      label: const Text(
                        "Sign in with Google",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 5),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Register()),
                            );
                          },
                          child: const Text(
                            "Register",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
