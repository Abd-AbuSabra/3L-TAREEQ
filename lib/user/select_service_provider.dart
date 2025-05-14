import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_33/user/provider_reviews.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_application_33/user/service_prodiver_details.dart';

class ServiceProviderPage extends StatelessWidget {
  const ServiceProviderPage({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('acceptedProviders')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No providers have accepted requests yet.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final providerName = data['providerName'] ?? 'No name';
                      final services = (data['services'] as List?)?.join(', ') ?? 'No services';
                      final rating = data['rating'] ?? 0;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServiceProviderDetailsPage(),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
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
                                backgroundImage: AssetImage('assets/profile.jpg'),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10),
                                    Text(
                                      providerName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    Text(
                                      "Services: $services",
                                      style: const TextStyle(color: Colors.black87),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: List.generate(
                                        rating,
                                        (index) => const Icon(Icons.star, color: Colors.amber, size: 18),
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
