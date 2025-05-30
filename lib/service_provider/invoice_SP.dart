import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_33/circles/battery_circle.dart';
import 'package:flutter_application_33/circles/gas_circle_.dart';
import 'package:flutter_application_33/circles/tile_circle.dart';
import 'package:flutter_application_33/service_provider/SP_profile.dart';
import 'package:flutter_application_33/service_provider/dashboard_SP.dart';
import 'package:flutter_application_33/pop_ups/received_popup.dart';

import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_33/Gemini/gemini_page.dart';
import 'package:flutter_application_33/user/login.dart';

const Color customGreen = Color(0xFF00A86B);

class invoice_SP extends StatefulWidget {
  const invoice_SP({super.key});

  @override
  State<invoice_SP> createState() => _invoice_SPState();
}

class _invoice_SPState extends State<invoice_SP> {
  @override
  // Add these new variables
  Map<String, dynamic>? providerData;
  Map<String, double> servicesWithPrices = {};
  String providerName = "";
  String providerLocation = "";
  bool isLoading = true;
  double taxAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadInvoiceData();
  }

  // Add this method to fetch invoice data
  Future<void> _loadInvoiceData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Get the accepted provider data for current user
      final acceptedProviderQuery = await FirebaseFirestore.instance
          .collection('acceptedProviders')
          .where('providerId', isEqualTo: user.uid)
          .where('isAccepted', isEqualTo: false)
          .limit(1)
          .get();

      if (acceptedProviderQuery.docs.isNotEmpty) {
        final acceptedData = acceptedProviderQuery.docs.first.data();

        setState(() {
          providerName = acceptedData['username'] ?? 'Unknown Provider';
          providerLocation =
              acceptedData['providerLocation'] ?? 'Location not available';

          // Extract services with prices
          if (acceptedData['services'] != null) {
            final Map<String, dynamic> rawServices = acceptedData['services'];
            servicesWithPrices = rawServices
                .map((key, value) => MapEntry(key, (value as num).toDouble()));
          }

          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading invoice data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Add this method to calculate subtotal
  double getSubtotal() {
    final sub =
        servicesWithPrices.values.fold(0.0, (sum, price) => sum + price);

    return sub;
  }

  double getTax() {
    final sub =
        servicesWithPrices.values.fold(0.0, (sum, price) => sum + price);
    taxAmount = sub * 0.16;
    return taxAmount;
  }

  // Add this method to calculate total
  double getTotal() {
    return getSubtotal() + taxAmount;
  }

  List<Widget> buildServiceItems() {
    List<Widget> serviceWidgets = [];

    // Add each service with its price
    servicesWithPrices.forEach((serviceName, price) {
      serviceWidgets.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Text(
                    serviceName,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 50),
                child: Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });

    // Add tax row
    serviceWidgets.add(
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 50),
                child: Text(
                  'Tax',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 50),
              child: Text(
                '\$${(getTax()).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Add total row with different styling
    serviceWidgets.add(
      Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white, width: 2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 50),
                child: Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 50),
              child: Text(
                '\$${getTotal().toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return serviceWidgets;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  const SizedBox(
                    height: 60,
                    width: 60,
                    child: logo(),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Invoice details",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 192, 228, 194),
                          ),
                        )
                      ],
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
                          Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: battery_circle(),
                                ),
                                SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: gas_circle(),
                                ),
                                SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: tile_circle(),
                                ),
                              ],
                            ),
                          ),
                          ...buildServiceItems(),
                          const SizedBox(height: 400),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 192, 228, 194),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 150, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Received',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ],
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
                    MaterialPageRoute(
                        builder: (context) => const Dashboard_SP()),
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
