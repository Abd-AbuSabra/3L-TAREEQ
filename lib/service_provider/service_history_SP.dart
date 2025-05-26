import 'package:flutter/material.dart';
import 'package:flutter_application_33/service_provider/SP_profile.dart';
import 'package:flutter_application_33/service_provider/dashboard_SP.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:animated_background/animated_background.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_application_33/Gemini/gemini_page.dart';
import 'package:flutter_application_33/user/login.dart';

import 'package:circular_menu/circular_menu.dart';

class Services_SP extends StatefulWidget {
  const Services_SP({super.key});

  @override
  State<Services_SP> createState() => _Services_SPState();
}

class _Services_SPState extends State<Services_SP> with TickerProviderStateMixin {
  String? selectedPayment;

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
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const SizedBox(
                      height: 60,
                      width: 60,
                      child: logo(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Service History",
                            style: TextStyle(
                              fontSize: 25,
                              color: customGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimationLimiter(
                      child: Column(
                        children: AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 1600),
                          childAnimationBuilder: (widget) => SlideAnimation(
                            horizontalOffset: 100.0,
                            child: FadeInAnimation(child: widget),
                          ),
                          children: List.generate(4, (index) {
                            final bool isEven = index % 2 == 0;
                            final Color cardColor = isEven
                                ? const Color.fromRGBO(22, 121, 171, 1.0)
                                : const Color.fromARGB(255, 7, 40, 89);
                            final Color textColor = isEven
                                ? const Color.fromARGB(255, 7, 40, 89)
                                : const Color.fromRGBO(22, 121, 171, 1.0);

                            return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Container(
                                height: 170,
                                width: 400,
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: const [
                                        SizedBox(width: 20),
                                        Icon(Icons.replay,
                                            size: 45, color: Colors.white),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const SizedBox(height: 10),
                                        const Text(
                                          '"Last Service"',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '"Details"',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        
          CircularMenu(
            alignment: Alignment.bottomRight,
            toggleButtonColor: customGreen,
            toggleButtonIconColor: Colors.white,
            items: [
               CircularMenuItem(
                icon: Icons.home,
                color: customGreen,
                iconColor: Colors.white,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Dashboard_SP()),
                  );
                },
              ),

              CircularMenuItem(
                icon: Icons.person,
                color: customGreen,
                iconColor: Colors.white,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SP_profile()),
                  );
                },
              ),
              CircularMenuItem(
                icon: Icons.chat,
                color: customGreen,
                iconColor: Colors.white,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GeminiPage()),
                  );
                },
              ),
              CircularMenuItem(
                icon: Icons.logout,
                color: Colors.red,
                iconColor: Colors.white,
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
