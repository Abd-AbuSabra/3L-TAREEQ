import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';

class Manage_Services extends StatefulWidget {
  final List<String> selectedServices;

  const Manage_Services({Key? key, required this.selectedServices})
      : super(key: key);

  @override
  State<Manage_Services> createState() => _Manage_ServicesState();
}

class _Manage_ServicesState extends State<Manage_Services> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, TextEditingController> _priceControllers = {};
  bool isLoading = false;
  List<String> currentServices = [];

  // Available roadside assistance services that can be added
  final List<String> availableServices = [
    'Flat Tire Change',
    'Towing Service',
    'Fuel Delivery',
    'Battery Jump-Start',
    'Lockout Assistance',
    'Oil Change Service',
    'Brake Inspection & Repair',
    'Spark Plug Replacement',
  ];

  @override
  void initState() {
    super.initState();
    currentServices = List.from(widget.selectedServices);
    _initializeControllers();
    _loadCurrentServices();
  }

  void _initializeControllers() {
    for (var service in currentServices) {
      _priceControllers[service] = TextEditingController();
    }
  }

  Future<void> _loadCurrentServices() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await _firestore.collection('providers').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final services = data['services'] as Map<String, dynamic>?;

        if (services != null) {
          setState(() {
            currentServices = services.keys.toList();
            for (var service in currentServices) {
              _priceControllers[service] =
                  TextEditingController(text: "${services[service]} \JD");
            }
          });
        }
      }
    } catch (e) {
      print("Error loading services: $e");
    }
  }

  @override
  void dispose() {
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitPricing() async {
    try {
      setState(() {
        isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not signed in.");

      final servicesWithPrices = <String, dynamic>{};

      bool allFieldsFilled = true;
      for (var service in currentServices) {
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
          return;
        }
      }

      if (!allFieldsFilled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter prices for all services")),
        );
        return;
      }

      // Update services in Firestore
      await _firestore.collection('providers').doc(user.uid).update({
        'services': servicesWithPrices,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Services updated successfully!")),
      );

      Navigator.of(context).pop();
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

  void _addServiceDialog() {
    // Filter out services that are already in currentServices
    final remainingServices = availableServices
        .where((service) => !currentServices.contains(service))
        .toList();

    if (remainingServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All available services are already added")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Add New Service",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(22, 121, 171, 1.0),
            ),
          ),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: remainingServices.length,
              itemBuilder: (context, index) {
                final service = remainingServices[index];
                return Card(
                  color: Color.fromRGBO(22, 121, 171, 1.0),
                  child: ListTile(
                    title: Text(
                      service,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _addService(service);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _addService(String service) {
    setState(() {
      currentServices.add(service);
      _priceControllers[service] = TextEditingController(text: "0 \JD");
    });

    // Immediately open price dialog for the new service
    _editPriceDialog(service);
  }

  void _deleteService(String service) {
    if (service.toLowerCase() == 'service') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Cannot delete the 'Service' - it's always available")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 300,
            height: 180,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Are you sure you want to\ndelete '$service' ?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromARGB(255, 73, 73, 73),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('No',
                          style: TextStyle(
                              color: Color.fromARGB(255, 73, 73, 73))),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          currentServices.remove(service);
                          _priceControllers[service]?.dispose();
                          _priceControllers.remove(service);
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("$service deleted successfully")),
                        );
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(22, 121, 171, 1.0),
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
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 192, 228, 194),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
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
          ],
        );
      },
    );
  }

  Widget _buildServiceCard(
      String title, TextEditingController controller, int index) {
    final canDelete = title.toLowerCase() != 'service';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      child: Card(
        color: Color.fromRGBO(22, 121, 171, 1.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "$index. $title",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
              Text(controller.text,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.white, size: 24),
                onPressed: () => _editPriceDialog(title),
              ),
              if (canDelete)
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red, size: 24),
                  onPressed: () => _deleteService(title),
                ),
            ],
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
          backgroundColor: Colors.white,
          leading: BackButton(
            color: const Color.fromARGB(255, 144, 223, 170),
          ),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            SizedBox(height: 15),
            Container(height: 60, width: 60, child: logo()),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Manage your services and pricing",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(22, 121, 171, 1.0),
                      ),
                    ),
                  ),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Color.fromRGBO(22, 121, 171, 1.0),
                    onPressed: _addServiceDialog,
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
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
                          "Your services:",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              if (currentServices.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    "No services available. Add some services to get started!",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              Column(
                                children: currentServices
                                    .asMap()
                                    .map((index, service) {
                                      return MapEntry(
                                        index,
                                        _buildServiceCard(
                                            service,
                                            _priceControllers[service]!,
                                            index + 1),
                                      );
                                    })
                                    .values
                                    .toList(),
                              ),
                              SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _submitPricing,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 7, 40, 89),
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: isLoading
                                  ? CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text(
                                      'Save Changes',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
