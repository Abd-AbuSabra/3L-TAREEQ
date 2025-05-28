import 'package:flutter/material.dart';
import 'package:flutter_application_33/universal_components/Menu.dart';
import 'package:flutter_application_33/user/loading.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:animated_background/animated_background.dart';
import 'package:flutter_application_33/components/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_33/user/select_service_provider.dart';

class SearchForService extends StatefulWidget {
  const SearchForService({super.key});

  @override
  State<SearchForService> createState() => _SearchForServiceState();
}

class _SearchForServiceState extends State<SearchForService>
    with SingleTickerProviderStateMixin {
  Set<String> selectedServices = {};
  Set<String> selectedTimes = {};

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

  final Map<String, TextEditingController> timeControllers = {
    "0-10 min": TextEditingController(text: "0-10 min"),
    "10-20 min": TextEditingController(text: "10-20 min"),
  };

  @override
  void dispose() {
    for (var controller in serviceControllers.values) {
      controller.dispose();
    }
    for (var controller in timeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchMatchingProviders(
      List<String> selectedServices) async {
    if (selectedServices.isEmpty) return [];

    final querySnapshot =
        await FirebaseFirestore.instance.collection('providers').get();

    List<Map<String, dynamic>> matchingProviders = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final providerServices = data['services'] as Map<String, dynamic>?;

      if (providerServices != null) {
        // Check if provider has all selected services
        bool hasAllServices = selectedServices
            .every((service) => providerServices.containsKey(service));

        if (hasAllServices) {
          data['uid'] = doc.id;
          matchingProviders.add(data);
        }
      }
    }

    return matchingProviders;
  }

  void confirmSelection() async {
    final selectedServiceTexts = selectedServices
        .map((service) => serviceControllers[service]?.text ?? service)
        .toList();

    final selectedTimeTexts = selectedTimes
        .map((time) => timeControllers[time]?.text ?? time)
        .toList();

    try {
      final authService = AuthService();
      final user = authService.currentUser;
      if (user == null) return;

      // Fetch providers matching selected services
      final providers = await fetchMatchingProviders(selectedServiceTexts);
      print('Found ${providers.length} matching providers');

      if (providers.isEmpty) {
        // Handle no providers found case
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'No providers found for selected services please select at least one service')),
        );
        return;
      }

      // Create individual service requests for each matching provider
      final batch = FirebaseFirestore.instance.batch();

      for (var provider in providers) {
        final requestRef =
            FirebaseFirestore.instance.collection('serviceRequests').doc();

        batch.set(requestRef, {
          'userId': user.uid,
          'targetProviderId':
              provider['uid'], // specific provider this request is for
          'services': selectedServiceTexts,
          'times': selectedTimeTexts,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'pending',
          'providerId': '', // will be filled when accepted
        });
      }

      // Save user selection
      final selectionRef =
          FirebaseFirestore.instance.collection('userSelections').doc(user.uid);

      batch.set(selectionRef, {
        'services': selectedServiceTexts,
        'times': selectedTimeTexts,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // Go to loading screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Loading()),
      );

      // Listen for acceptance by providers
      FirebaseFirestore.instance
          .collection('acceptedProviders')
          .where('userId', isEqualTo: user.uid)
          .where('isAccepted', isEqualTo: true)
          .limit(1)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final accepted = snapshot.docs.first.data();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ServiceProviderPage(
                providerData: {
                  'uid': accepted['providerId'],
                  'username': accepted['providerName'],
                  'mobile': accepted['mobile'] ?? '',
                  'services': accepted['services'] ?? {},
                  'rating': accepted['rating'],
                },
              ),
            ),
          );
        }
      });
    } catch (e) {
      print("Error confirming selection: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Menu(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(
            color: const Color.fromARGB(255, 144, 223, 170),
          ),
        ),
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
              baseColor: const Color.fromARGB(255, 192, 228, 194),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  SizedBox(height: 80, width: 80, child: logo()),
                  const SizedBox(height: 50),
                  buildServiceSelection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildServiceSelection() {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Services",
              style: TextStyle(
                fontSize: 25,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...serviceControllers.entries.map((entry) {
            return CheckboxListTile(
              title: Text(entry.value.text,
                  style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold)),
              value: selectedServices.contains(entry.key),
              onChanged: (isChecked) {
                setState(() {
                  if (isChecked!) {
                    selectedServices.add(entry.key);
                  } else {
                    selectedServices.remove(entry.key);
                  }
                });
              },
            );
          }).toList(),
          const SizedBox(height: 30),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Near by me:",
              style: TextStyle(
                fontSize: 25,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...timeControllers.entries.map((entry) {
            return CheckboxListTile(
              title: Text(entry.value.text,
                  style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold)),
              value: selectedTimes.contains(entry.key),
              onChanged: (isChecked) {
                setState(() {
                  if (isChecked!) {
                    selectedTimes.add(entry.key);
                  } else {
                    selectedTimes.remove(entry.key);
                  }
                });
              },
            );
          }).toList(),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: confirmSelection,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 192, 228, 194),
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Confirm Service',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
