import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';

class Pricing extends StatefulWidget {
  final List<String> selectedServices;

  const Pricing({Key? key, required this.selectedServices}) : super(key: key);

  @override
  State<Pricing> createState() => _PricingState();
}

class _PricingState extends State<Pricing> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
    // Dispose all controllers
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitPricing() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not signed in.");

      // Create a map of services and their prices
      final servicesWithPrices = <String, dynamic>{};

      // Check that all fields are filled and valid
      bool allFieldsFilled = true;
      for (var service in widget.selectedServices) {
        final priceText = _priceControllers[service]?.text ?? '';
        if (priceText.isEmpty) {
          allFieldsFilled = false;
          break;
        }

        try {
          // Remove non-numeric characters like ' \JD'
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
          return;
        }
      }

      if (!allFieldsFilled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter prices for all services")),
        );
        return;
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
        'rating': 1,
      };

      // Reference to the provider document in 'providers' collection
      final providerRef = _firestore.collection('providers').doc(user.uid);

      // Save provider data to Firestore
      await providerRef.set(providerData);

      // Optional: reference to the reviews subcollection (empty for now)
      final reviewsRef = providerRef.collection('reviews');
      // Note: No need to write anything now. Subcollection will be created when adding a review.

      // Delete user document from 'users' collection
      await _firestore.collection('users').doc(user.uid).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You are now a service provider!")),
      );

      // Navigate back to home or dashboard
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving pricing: $e")),
      );
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
                    fontSize: 18),
              ),
              Text(controller.text,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.edit,
                color: Color.fromARGB(255, 7, 40, 89), size: 30),
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
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
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
                        color: Color.fromARGB(255, 192, 228, 194),
                      ),
                    )
                  ],
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
                          onPressed: _submitPricing,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 7, 40, 89),
                            padding: EdgeInsets.symmetric(
                                horizontal: 150, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
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
      ),
    );
  }
}
