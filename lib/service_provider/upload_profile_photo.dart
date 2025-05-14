import 'package:flutter/material.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:animated_background/animated_background.dart';

class UploadPhotoSP extends StatefulWidget {
  const UploadPhotoSP({super.key});

  @override
  State<UploadPhotoSP> createState() => _UploadPhotoSPState();
}

class _UploadPhotoSPState extends State<UploadPhotoSP> with TickerProviderStateMixin {
  final Color customGreen = const Color.fromARGB(255, 192, 228, 194);

  @override
  Widget build(BuildContext context) {
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
            particleCount: 5,
            spawnOpacity: 0.1,
            maxOpacity: 0.1,
            baseColor: customGreen,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                SizedBox(
                  height: 60,
                  width: 60,
                  child: logo(),
                ),

                const SizedBox(height: 100),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 180,
                        backgroundColor: const Color.fromARGB(255, 7, 40, 89),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.camera_front_rounded,
                            color: Colors.white,
                            size: 100,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 120),

                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 7, 40, 89),
                    padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
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
