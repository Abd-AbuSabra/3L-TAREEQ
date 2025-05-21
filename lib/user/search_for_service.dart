import 'package:flutter/material.dart';
import 'package:flutter_application_33/universal_components/Menu.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:animated_background/animated_background.dart';
import 'package:flutter_application_33/components/auth_service.dart';
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

  void confirmSelection() async {
    final selectedServiceTexts = selectedServices
        .map((service) => serviceControllers[service]?.text ?? service)
        .toList();

    final selectedTimeTexts = selectedTimes
        .map((time) => timeControllers[time]?.text ?? time)
        .toList();

    try {
      final authService = AuthService();
      await authService.addServiceRequest(
        selectedServices: selectedServiceTexts,
        selectedTimes: selectedTimeTexts,
      );
      print(selectedServiceTexts);
      print(selectedTimeTexts);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceProviderPage(
            selectedServices: selectedServiceTexts,
          ),
        ),
      );
    } catch (e) {
      print("Error sending request: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Menu(
      child: Scaffold(
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
