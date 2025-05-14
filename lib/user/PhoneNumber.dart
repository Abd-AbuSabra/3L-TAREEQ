import 'package:flutter/material.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animated_background/animated_background.dart'; 
import 'package:flutter_application_33/main.dart';
import 'package:flutter_application_33/user/OTTP.dart';
import 'package:provider/provider.dart'; 
import 'package:intl_phone_field/countries.dart';
import 'package:flutter_application_33/components/authprovider.dart';

import 'Register.dart';

class PN extends StatefulWidget {
  const PN({super.key});

  @override
  _PNState createState() => _PNState();
}


class AuthProvider with ChangeNotifier {
  void signInWithPhone(BuildContext context, String phoneNumber) {
    print('Sending OTP to $phoneNumber');
  }
}

class _PNState extends State<PN> with TickerProviderStateMixin { 
  final GlobalKey<FormState> _formKey = GlobalKey();
  final FocusNode focusNode = FocusNode();
  final TextEditingController phoneController = TextEditingController();
  late Country selectedCountry; // ADD THIS
  final Color customGreen = const Color.fromARGB(255, 192, 228, 194);

  @override
  Widget build(BuildContext context) {
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
            particleCount: 3,
            spawnOpacity: 0.1,
            maxOpacity: 0.1,
            baseColor: const Color.fromARGB(255, 192, 228, 194),
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
                SizedBox(
                  width: 100,
                  height: 100,
                  child: logo(),
                ),
                const SizedBox(height: 100),
                const Text(
                  "Enter your phone number",
                  style: TextStyle(
                      fontSize: 28,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
                const Text(
                  "we'll send you a 4-digit verification code",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 80),
                IntlPhoneField(
                  focusNode: focusNode,
                  controller: phoneController, 
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color: customGreen),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 192, 228, 194),
                          width: 2.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 192, 228, 194),
                          width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 192, 228, 194)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: phoneController.text.length > 9
                        ? Container(
                            height: 30,
                            width: 30,
                            margin: const EdgeInsets.all(10.0),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                            child: const Icon(
                              Icons.done,
                              color: Colors.white,
                              size: 20,
                            ),
                          )
                        : null,
                  ),
                  languageCode: "en",
                  onChanged: (phone) {
                    setState(() {}); 
                    print(phone.completeNumber);
                  },
                  onCountryChanged: (country) {
                    setState(() {
                      selectedCountry = country; 
                    });
                    print('Country changed to: ${country.name}');
                  },
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
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      sendPhoneNumber();
                    }
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void sendPhoneNumber() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String phoneNumber = phoneController.text.trim();
    ap.signInWithPhone(context, "+${selectedCountry.dialCode}$phoneNumber"); 
  }
}
