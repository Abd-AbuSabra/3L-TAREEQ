import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_application_33/pop_ups/rating.dart';
import 'package:flutter_application_33/user/provider_reviews.dart';

class ServiceProviderDetailsPage extends StatefulWidget {
  const ServiceProviderDetailsPage({super.key});

  @override
  State<ServiceProviderDetailsPage> createState() => _ServiceProviderDetailsPageState();
}

class _ServiceProviderDetailsPageState extends State<ServiceProviderDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, String> _servicePrices = {};
  List<String> _services = [];

  @override
  void initState() {
    super.initState();
    _fetchPricingData();
  }

  Future<void> _fetchPricingData() async {
    try {
      final snapshot = await _firestore
          .collection('service_pricing')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        setState(() {
          _services = List<String>.from(data['services'] ?? []);
          _servicePrices = Map<String, String>.from(data['prices'] ?? {});
        });
      }
    } catch (e) {
      print("Error fetching pricing data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),
              SizedBox(height: 60, width: 60, child: logo()),
              const SizedBox(height: 20),
              const Text(
                "Service providers near you",
                style: TextStyle(
                  fontSize: 25,
                  color: Color.fromARGB(255, 192, 228, 194),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage('assets/profile.jpg'),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              const Text(
                                "Service provider's name",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Row(
                                children: [
                                  SizedBox(width: 5),
                                  Icon(Icons.star, color: Colors.yellow),
                                  Icon(Icons.star, color: Colors.yellow),
                                  Icon(Icons.star, color: Colors.yellow),
                                  Icon(Icons.star, color: Colors.yellow),
                                  Icon(Icons.star, color: Colors.yellow),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProviderReviewsPage(),
                                      ),
                                    );
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Reviews",
                                        style: TextStyle(
                                          color: Color.fromARGB(255, 7, 65, 115),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Icon(Icons.keyboard_arrow_right),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                child: Container(
                  width: double.infinity,
                  color: const Color.fromARGB(255, 192, 228, 194),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 35),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50.0),
                        child: Text(
                          "Usual services costs",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      if (_servicePrices.isNotEmpty)
                        for (var service in _services)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50.0, vertical: 8),
                            child: Text(
                              "$service: ${_servicePrices[service] ?? 'Not set'}",
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      if (_servicePrices.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 50.0),
                          child: Text(
                            "No pricing data available.",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  SizedBox(height: 200,),
                        Row( mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                    onPressed: (){},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 7, 40, 89),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 120, vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'Contact',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                          ],
                        ),

                      const SizedBox(height: 300),
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
