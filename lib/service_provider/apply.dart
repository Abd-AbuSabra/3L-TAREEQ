import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_application_33/service_provider/Pricing.dart'; // Make sure you adjust this import path

class Apply extends StatefulWidget {
  const Apply({super.key});

  @override
  State<Apply> createState() => _ApplyState();
}

class _ApplyState extends State<Apply> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  Uint8List? _webImage;

  final Map<String, TextEditingController> serviceControllers = {
    "Flat Tire Change": TextEditingController(text: "Flat Tire Change"),
    "Towing Service": TextEditingController(text: "Towing Service"),
    "Fuel Delivery": TextEditingController(text: "Fuel Delivery"),
    "Battery Jump-Start": TextEditingController(text: "Battery Jump-Start"),
    "Lockout Assistance": TextEditingController(text: "Lockout Assistance"),
    "Oil Change Service": TextEditingController(text: "Oil Change Service"),
    "Brake Inspection & Repair":
        TextEditingController(text: "Brake Inspection & Repair"),
    "Spark Plug Replacement":
        TextEditingController(text: "Spark Plug Replacement"),
  };

  final Map<String, bool> serviceSelections = {
    "Flat Tire Change": false,
    "Towing Service": false,
    "Fuel Delivery": false,
    "Battery Jump-Start": false,
    "Lockout Assistance": false,
    "Oil Change Service": false,
    "Brake Inspection & Repair": false,
    "Spark Plug Replacement": false,
  };

  @override
  void dispose() {
    for (var controller in serviceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        if (kIsWeb) {
          // For web platform
          final bytes = await image.readAsBytes();
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
          });
        } else {
          // For mobile platforms
          setState(() {
            _selectedImage = File(image.path);
            _webImage = null;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: $e")),
      );
    }
  }

  Future<void> _submitApplication() async {
    final selectedServices = serviceSelections.entries
        .where((entry) => entry.value)
        .map((entry) => serviceControllers[entry.key]?.text ?? entry.key)
        .toList();

    if (selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select at least one service.")));
      return;
    }

    // Check if image is attached
    if (_selectedImage == null && _webImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please attach a photo to continue.")),
      );
      return;
    }

    selectedServices.add("Service");

    try {
      // Get current user ID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login to continue.")),
        );
        return;
      }

      // Navigate to Pricing with services and image data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Pricing(
            selectedServices: selectedServices,
            selectedImageFile: _selectedImage,
            selectedImageBytes: _webImage,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting application: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 15),
              SizedBox(height: 60, width: 60, child: logo()),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Center(
                  child: Text(
                    "join us and become a part of our community",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 192, 228, 194),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                child: Container(
                  width: double.infinity,
                  color: const Color.fromRGBO(22, 121, 171, 1.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.only(left: 40),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Services",
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 40),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "min 1, max 8",
                            style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 7, 40, 89),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...serviceSelections.entries
                          .map((entry) => _buildCheckboxTile(
                                controller: serviceControllers[entry.key]!,
                                isChecked: entry.value,
                                onChanged: (val) {
                                  setState(() => serviceSelections[entry.key] =
                                      val ?? false);
                                },
                              )),
                      const Padding(
                        padding: EdgeInsets.only(left: 40, top: 20, bottom: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Attach Photo:",
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 40, bottom: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Required*",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 255, 193, 7),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Container(
                          height: 130,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: (_selectedImage == null &&
                                    _webImage == null)
                                ? Border.all(
                                    color:
                                        const Color.fromARGB(255, 255, 193, 7),
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Center(
                            child: (_selectedImage != null || _webImage != null)
                                ? GestureDetector(
                                    onTap: _pickImage,
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: kIsWeb
                                              ? Image.memory(
                                                  _webImage!,
                                                  height: 130,
                                                  width: double.infinity,
                                                )
                                              : Image.file(
                                                  _selectedImage!,
                                                  height: 130,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : IconButton(
                                    onPressed: _pickImage,
                                    icon: const Icon(
                                      Icons.upload,
                                      color: Color.fromARGB(255, 192, 228, 194),
                                      size: 120,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _submitApplication,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 7, 40, 89),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 150, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxTile({
    required TextEditingController controller,
    required bool isChecked,
    required Function(bool?) onChanged,
  }) {
    return CheckboxListTile(
      activeColor: const Color.fromARGB(255, 192, 228, 194),
      title: Text(
        controller.text,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      value: isChecked,
      onChanged: onChanged,
    );
  }
}
