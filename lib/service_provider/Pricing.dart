import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'dart:io';
import 'dart:typed_data';

class Pricing extends StatefulWidget {
  final List<String> selectedServices;
  final File? selectedImageFile;
  final Uint8List? selectedImageBytes;

  const Pricing({
    Key? key,
    required this.selectedServices,
    this.selectedImageFile,
    this.selectedImageBytes,
  }) : super(key: key);

  @override
  State<Pricing> createState() => _PricingState();
}

class _PricingState extends State<Pricing> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Map<String, TextEditingController> _priceControllers = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (var service in widget.selectedServices) {
      _priceControllers[service] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<String?> _uploadImage() async {
    if (widget.selectedImageFile == null && widget.selectedImageBytes == null) {
      print("${widget.selectedImageFile} bytes=${widget.selectedImageBytes} ");

      return null;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      // Create a reference to the image in Firebase Storage
      final storageRef = _storage
          .ref()
          .child('provider_images')
          .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      UploadTask uploadTask;

      if (widget.selectedImageBytes != null) {
        // For web platform
        uploadTask = storageRef.putData(widget.selectedImageBytes!);
      } else {
        // For mobile platform
        uploadTask = storageRef.putFile(widget.selectedImageFile!);
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _submitPricing() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not signed in.");

      final servicesWithPrices = <String, dynamic>{};

      bool allFieldsFilled = true;
      for (var service in widget.selectedServices) {
        final priceText = _priceControllers[service]?.text ?? '';
        if (priceText.isEmpty) {
          allFieldsFilled = false;
          break;
        }

        try {
          final cleanedPrice = priceText.replaceAll(' \JD', '').trim();

          if (cleanedPrice.isEmpty) {
            allFieldsFilled = false;
            break;
          }

          final price = double.tryParse(cleanedPrice);
          if (price == null || price < 0) {
            throw Exception("Please enter a valid positive price.");
          }

          servicesWithPrices[service] = price;
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Please enter valid prices for all services")),
          );
          setState(() {
            isLoading = false;
          });
          return;
        }
      }

      if (!allFieldsFilled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter prices for all services")),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Upload image first
      String? imageUrl;
      if (widget.selectedImageFile != null ||
          widget.selectedImageBytes != null) {
        imageUrl = await _uploadImage();
        if (imageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Failed to upload image. Please try again.")),
          );
          setState(() {
            isLoading = false;
          });
          return;
        }
      }

      // Get the user document for basic information
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw Exception("User not found in users collection.");
      }

      // Create service provider data
      final providerData = {
        ...userDoc.data()!, // Copy all user data
        'services': servicesWithPrices,
        'isServiceProvider': true,
        'joinedAt': FieldValue.serverTimestamp(),
        'rating': 0,
        if (imageUrl != null)
          'profileImageUrl': imageUrl, // Add image URL if available
      };

      // Reference to the provider document in 'providers' collection
      final providerRef = _firestore.collection('providers').doc(user.uid);

      await providerRef.collection('reviews').add({});

      await providerRef.set(providerData);

      final reviewsRef = providerRef.collection('reviews');

      await _firestore.collection('users').doc(user.uid).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You are now a service provider!")),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving pricing: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _editPriceDialog(String serviceTitle) {
    final controller = _priceControllers[serviceTitle]!;
    final rawText = controller.text.replaceAll(' \JD', '');
    final tempController = TextEditingController(
      text: rawText == "0" ? "" : rawText,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Edit Price for $serviceTitle",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          content: TextField(
            controller: tempController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              hintText: "Enter price in JD",
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 192, 228, 194),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  final value = tempController.text.trim();
                  if (value.isEmpty || double.tryParse(value) == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter a valid number")),
                    );
                    return;
                  }
                  if (double.tryParse(value)! < 3 ||
                      double.tryParse(value)! > 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              "Please enter a number between 3 JD and 200 JD")),
                    );
                    return;
                  }

                  setState(() {
                    controller.text = "$value \JD";
                  });
                  Navigator.pop(context);
                },
                child: Text("Save", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildServiceCard(
      String title, TextEditingController controller, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      child: Card(
        color: Color.fromRGBO(22, 121, 171, 1.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$index. $title",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              Text(controller.text,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.edit, color: Colors.white, size: 30),
            onPressed: () => _editPriceDialog(title),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(
            color: const Color.fromARGB(255, 144, 223, 170),
          ),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 15),
                    Container(height: 60, width: 60, child: logo()),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "We are happy to inform \n that you're a part of our community",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(22, 121, 171, 1.0),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
              child: Container(
                width: double.infinity,
                color: Color.fromRGBO(22, 121, 171, 1.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        "Please price your \nservices below:",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 40),
                    Column(
                      children: widget.selectedServices
                          .asMap()
                          .map((index, service) {
                            return MapEntry(
                              index,
                              _buildServiceCard(
                                  service,
                                  _priceControllers[service]!,
                                  index + 1), // 1-based index
                            );
                          })
                          .values
                          .toList(),
                    ),
                    SizedBox(height: 200),
                    Center(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submitPricing,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 7, 40, 89),
                          padding: EdgeInsets.symmetric(
                              horizontal: 150, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Done',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                      ),
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
