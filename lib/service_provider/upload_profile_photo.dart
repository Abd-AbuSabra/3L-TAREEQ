import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_33/universal_components/Menu.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:animated_background/animated_background.dart';


class UploadPhotoSP extends StatefulWidget {
  const UploadPhotoSP({super.key});

  @override
  State<UploadPhotoSP> createState() => _UploadPhotoSPState();
}

class _UploadPhotoSPState extends State<UploadPhotoSP> with TickerProviderStateMixin {
  final Color customGreen = const Color.fromARGB(255, 192, 228, 194);
  Uint8List? _webImageBytes; 

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes(); 
      setState(() {
        _webImageBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Menu(
      child: Scaffold(
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
                children: [
                  const SizedBox(height: 20),
                  SizedBox(height: 60, width: 60, child: logo()),
                  const SizedBox(height: 100),
                  Text(
                    "Pick your profile photo",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 192, 228, 194),
                      fontSize: 25,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 150,
                          backgroundColor: Colors.grey.shade100,
                          backgroundImage: _webImageBytes != null
                              ? MemoryImage(_webImageBytes!)
                              : null,
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(Icons.edit, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                  ElevatedButton(
                    onPressed: () {
                      if (_webImageBytes == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please pick an image first")),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Image selected successfully")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF072859),
                      padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 14),
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
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
