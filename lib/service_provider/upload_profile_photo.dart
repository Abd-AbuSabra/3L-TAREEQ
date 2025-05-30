import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_33/universal_components/Menu.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:animated_background/animated_background.dart';

class UploadPhotoSP extends StatefulWidget {
  String? profileImage;

  UploadPhotoSP({super.key, this.profileImage});

  @override
  State<UploadPhotoSP> createState() => _UploadPhotoSPState();
}

class _UploadPhotoSPState extends State<UploadPhotoSP>
    with TickerProviderStateMixin {
  final Color customGreen = const Color.fromARGB(255, 192, 228, 194);
  Uint8List? _webImageBytes;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

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
        body: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade100,
                    backgroundImage: _webImageBytes != null
                        ? MemoryImage(_webImageBytes!)
                        : NetworkImage(widget.profileImage!),
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
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
          ],
        ),
      ),
    );
  }
}
