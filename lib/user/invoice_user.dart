import 'package:flutter/material.dart';
import 'package:flutter_application_33/pop_ups/rating.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_application_33/user/Payment.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Invoice_user extends StatefulWidget {
  const Invoice_user({super.key});

  @override
  State<Invoice_user> createState() => _Invoice_userState();
}

class _Invoice_userState extends State<Invoice_user> {
  String? selectedPayment;
  Map<String, double> servicesWithPrices = {};
  String providerName = "";
  String providerId = "";
  String photo = "";
  String providerLocation = "";
  bool isLoading = true;
  String? errorMessage;
  double taxAmount = 0;
  String username = "";
  @override
  void initState() {
    super.initState();
    _loadInvoiceData();
  }

  Future<void> _loadInvoiceData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = "User not authenticated";
          isLoading = false;
        });
        return;
      }

      // Add timeout to prevent indefinite hanging
      final acceptedProviderQuery = await FirebaseFirestore.instance
          .collection('acceptedProviders')
          .where('userId', isEqualTo: user.uid)
          .where('isAccepted', isEqualTo: false)
          .limit(1)
          .get()
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out');
        },
      );

      if (acceptedProviderQuery.docs.isNotEmpty) {
        final acceptedData = acceptedProviderQuery.docs.first.data();

        // Ensure we're on the main thread for setState
        if (mounted) {
          setState(() {
            providerName = acceptedData['username'] ?? 'Unknown Provider';
            username = acceptedData['name'] ?? 'Unknown Provider';
            providerId = acceptedData['providerId'] ?? 'Unknown Provider';
            providerLocation =
                acceptedData['providerLocation'] ?? 'Location not available';
            photo = acceptedData['photoURL'];

            // Extract services with prices safely
            if (acceptedData['services'] != null) {
              final dynamic rawServices = acceptedData['services'];
              if (rawServices is Map<String, dynamic>) {
                servicesWithPrices.clear();
                rawServices.forEach((key, value) {
                  if (value != null) {
                    servicesWithPrices[key] = (value as num).toDouble();
                  }
                });
              }
            }

            isLoading = false;
            errorMessage = null;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = 'No invoice data found';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading invoice data: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load invoice data: ${e.toString()}';
          isLoading = false;
        });
      }
    }
  }

  double getSubtotal() {
    if (servicesWithPrices.isEmpty) return 0.0;
    return servicesWithPrices.values.fold(0.0, (sum, price) => sum + price);
  }

  double getTax() {
    final subtotal = getSubtotal();
    taxAmount = subtotal * 0.16;
    return taxAmount;
  }

  double getTotal() {
    return getSubtotal() + getTax();
  }

  List<Widget> buildServiceItems() {
    List<Widget> serviceWidgets = [];

    if (servicesWithPrices.isEmpty) {
      serviceWidgets.add(
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'No services found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
      return serviceWidgets;
    }

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
                  'Tax (16%)',
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
                '\$${getTax().toStringAsFixed(2)}',
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

  void handleConfirm() {
    if (selectedPayment == "Cash") {
      showDialog(
        context: context,
        builder: (_) => Rating_popup(
          username: username,
          providerId: providerId,
        ),
      );
    } else if (selectedPayment == "Credit/Debit card") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Payment()),
      );
    }
  }

  void handleRadioSelection(String value) {
    setState(() {
      selectedPayment = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color.fromARGB(255, 192, 228, 194),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading invoice...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 192, 228, 194),
                      ),
                    ),
                  ],
                ),
              )
            : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              errorMessage = null;
                            });
                            _loadInvoiceData();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        SizedBox(height: 60, width: 60, child: logo()),
                        const SizedBox(height: 20),
                        const Text(
                          "Invoice Details",
                          style: TextStyle(
                            fontSize: 25,
                            color: Color.fromARGB(255, 192, 228, 194),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            height: 180,
                            width: 400,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color.fromARGB(
                                        255, 219, 218, 218),
                                    radius: 45,
                                    backgroundImage: photo != null
                                        ? NetworkImage(photo)
                                        : const AssetImage('assets/profile.jpg')
                                            as ImageProvider,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          providerName.isNotEmpty
                                              ? providerName
                                              : 'Unknown Provider',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.location_on,
                                                color: Colors.red, size: 16),
                                            SizedBox(width: 5),
                                            Flexible(
                                              child: Text(
                                                'Amman, shafa badran,\nal-arab street',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 15,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
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
                              children: [
                                const SizedBox(height: 25),
                                const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(width: 30),
                                      Text(
                                        "Your Services",
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ...buildServiceItems(),
                                const SizedBox(height: 40),
                                const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(width: 30),
                                      Text(
                                        "Payment",
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Column(
                                  children: ["Cash", "Credit/Debit card"]
                                      .map((payment) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        unselectedWidgetColor: Colors.grey[300],
                                        radioTheme: RadioThemeData(
                                          fillColor: WidgetStateProperty
                                              .resolveWith<Color>(
                                            (states) => states.contains(
                                                    WidgetState.selected)
                                                ? const Color(0xFF072859)
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                      child: RadioListTile<String>(
                                        value: payment,
                                        groupValue: selectedPayment,
                                        onChanged: (value) {
                                          if (value != null) {
                                            handleRadioSelection(value);
                                          }
                                        },
                                        title: Text(
                                          payment,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: selectedPayment != null
                                      ? handleConfirm
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 7, 40, 89),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 120, vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Confirm',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 60),
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
