import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_application_33/user/provider_reviews.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_application_33/user/service_prodiver_details.dart';
import 'package:flutter_application_33/universal_components/Menu.dart';

class ServiceProviderPage extends StatelessWidget {
  final Map<String, dynamic> providerData;

  const ServiceProviderPage({super.key, required this.providerData});

  @override
  Widget build(BuildContext context) {
    final name = providerData['username'] ?? 'No name';
    final mobile = providerData['mobile'] ?? '';
    final services = Map<String, dynamic>.from(
      providerData['services'] ?? {},
    );
    final providerId = providerData['uid'] ?? '';

    final rawRating = providerData['rating'];
    double avgRating;

    if (rawRating == null) {
      avgRating = 1.0;
    } else if (rawRating is int) {
      avgRating = rawRating.toDouble();
    } else if (rawRating is double) {
      avgRating = rawRating;
    } else {
      avgRating = 1.0;
    }

    return Menu(
      child: Scaffold(
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
                    "Service provider found!",
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
                child: ListView(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceProviderDetailsPage(
                              name: name,
                              rating: avgRating,
                              mobile: mobile,
                              services: services,
                              providerId: providerId,
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
                              backgroundImage: AssetImage('assets/profile.jpg'),
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
                                  const SizedBox(height: 20),
                                  RatingBarIndicator(
                                    rating: avgRating,
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 18,
                                    direction: Axis.horizontal,
                                  ),
                                  const SizedBox(height: 10),
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
                                                    ProviderReviewsPage(
                                                  providerId: providerId,
                                                ),
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
