import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';

class Pricing extends StatefulWidget {
  const Pricing({super.key});

  @override
  State<Pricing> createState() => _PricingState();
}

class _PricingState extends State<Pricing> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, TextEditingController> _priceControllers = {};
  List<String> _selectedServices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSelectedServices();
  }

  Future<void> _loadSelectedServices() async {
    try {
      final snapshot = await _firestore
          .collection('service_applications')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty &&
          snapshot.docs.first.data().containsKey('services')) {
        final List<dynamic> services = snapshot.docs.first['services'];
        setState(() {
          _selectedServices = List<String>.from(services);
          for (var service in _selectedServices) {
            _priceControllers[service] = TextEditingController(text: "0 \JD");
          }
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error loading services: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _submitPricing() async {
    try {
      final pricesMap = {
        for (var entry in _priceControllers.entries) entry.key: entry.value.text
      };

      final pricingData = {
        'services': _selectedServices,
        'prices': pricesMap,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('service_pricing').add(pricingData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Prices submitted successfully!")),
      );
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

  Widget _buildServiceCard(String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      child: Card(
        color: Color.fromRGBO(22, 121, 171, 1.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
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
  void dispose() {
    _priceControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                            " we are happy to inform \n that you're a part of our community",
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
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
                              children: _selectedServices
                                  .map((title) => _buildServiceCard(
                                      title, _priceControllers[title]!))
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
