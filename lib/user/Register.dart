import 'package:flutter/material.dart';
import 'package:flutter_application_33/components/auth_service.dart';
import 'package:flutter_application_33/components/my_text_field.dart';
import 'package:flutter_application_33/service_provider/apply.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_application_33/user/PhoneNumber.dart';
import 'package:provider/provider.dart';
import 'package:animated_background/animated_background.dart';
import 'login.dart';
import 'package:flutter_application_33/user/dashboard_user.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> with TickerProviderStateMixin {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();
  final carBrandController = TextEditingController();
  final PhoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isObscurePassword = true;
  bool isObscureConfirmPassword = true;

  void SignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmpasswordController.text) {
      setState(() {});
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signUpWithEmailAndPassword(
          emailController.text.trim(), passwordController.text.trim(),
          username: usernameController.text.trim(),
          carBrandAndType: carBrandController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration Successful!")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PN()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final customGreen = const Color.fromARGB(255, 192, 228, 194);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: const Color.fromARGB(255, 144, 223, 170),
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
            particleCount: 4,
            spawnOpacity: 0.1,
            maxOpacity: 0.1,
            baseColor: customGreen,
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(height: 150, width: 150, child: logo()),
                const Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 45,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: TextFormField(
                      controller: usernameController,
                      obscureText: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }

                        if (value.length < 3) {
                          return 'Please enter a valid username';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Username",
                        hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
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
                        hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
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
                        hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
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
                Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: TextFormField(
                      controller: confirmpasswordController,
                      obscureText: isObscureConfirmPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }

                        if (passwordController.text != value) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isObscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          color: Colors.grey,
                          onPressed: () {
                            setState(() {
                              isObscureConfirmPassword =
                                  !isObscureConfirmPassword;
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
                Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: TextFormField(
                      controller: PhoneController,
                      obscureText: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }

                        if (value.length < 10) {
                          return 'Phone number must be at least 10 digits long.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "+962XXXXXXXXX",
                        hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
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
                      controller: carBrandController,
                      obscureText: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter your car brand and type';
                        }

                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Enter your car brand and type",
                        hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
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
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: SignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customGreen,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 150, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 5),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Login()),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
