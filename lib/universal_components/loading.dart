import 'package:flutter/material.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_application_33/user/select_service_provider.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      // Simulate backend call (replace this with your actual backend logic)
      await Future.delayed(Duration(seconds: 4)); 

      // Example: Replace the above with your real backend call
      // final result = await YourBackendService.getData();

      // When backend is done, navigate to the next page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ServiceProviderPage()),
        );
      }
    } catch (e) {
     
      print('Error during backend operation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 50),
          SizedBox(height: 60, width: 60, child: logo()),
          const SizedBox(height: 150),
          Center(
            child: LottieBuilder.network(
              'https://lottie.host/b91cb2f2-1934-4dcd-aca4-30b2f675ccfd/PeSIiXLeX2.json',
              width: 350,
              height: 350,
            ),
          ),
          /*const Text(
            "Connecting you...",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 192, 228, 194),
            ),
          ),*/
        ],
      ),
    );
  }
}
