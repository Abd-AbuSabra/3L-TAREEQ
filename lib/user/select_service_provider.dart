import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_33/user/provider_reviews.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_application_33/user/service_prodiver_details.dart';
import 'package:flutter_application_33/universal_components/loading.dart';

class ServiceProviderPage extends StatelessWidget {
  final List<String> selectedServices;

  const ServiceProviderPage({super.key, required this.selectedServices});

  Future<List<Map<String, dynamic>>> fetchMatchingProviders() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('providers').get();

    final allDocs = querySnapshot.docs;

    List<Map<String, dynamic>> matchingProviders = [];

    for (final doc in allDocs) {
      final data = doc.data();

      if (data.containsKey('services') && data['services'] is Map) {
        final providerServices = Map<String, dynamic>.from(data['services']);

        final matchesAllSelectedServices = selectedServices.every(
          (service) => providerServices.containsKey(service),
        );

        if (matchesAllSelectedServices) {
          matchingProviders.add(data);
        }
      }
    }

    return matchingProviders;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchMatchingProviders(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Loading(); // Show your custom loading page
        }

        final providers = snapshot.data!;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(height: 60, width: 60, child: logo()),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 40),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Service providers near you",
                      style: TextStyle(
                        color: Color.fromARGB(255, 192, 228, 194),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: providers.length,
                    itemBuilder: (context, index) {
                      final provider = providers[index];
                      final name = provider['username'] ?? 'No name';
                      final rating = provider['rating'] ?? 1;
                      final mobile = provider['mobile'] ?? '';
                      final services = Map<String, dynamic>.from(
                        provider['services'] ?? {},
                      );

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServiceProviderDetailsPage(
                                name: name,
                                rating: rating,
                                mobile: mobile,
                                services: services,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 55,
                                backgroundImage:
                                    AssetImage('assets/profile.jpg'),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10),
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 7, 65, 115),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    Row(
                                      children: List.generate(
                                        rating,
                                        (index) => const Icon(Icons.star,
                                            color: Colors.amber, size: 18),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProviderReviewsPage(),
                                                ),
                                              );
                                            },
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "Reviews",
                                                  style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 7, 65, 115),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Icon(
                                                    Icons.keyboard_arrow_right),
                                              ],
                                            ),
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
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
