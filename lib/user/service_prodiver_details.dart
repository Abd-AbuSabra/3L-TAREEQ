import 'package:flutter/material.dart';
import 'package:flutter_application_33/service_provider/invoice_SP.dart';
import 'package:flutter_application_33/universal_components/Menu.dart';
import 'package:flutter_application_33/user/invoice_user.dart';
import 'package:flutter_application_33/user/live_tracking_user.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_application_33/pop_ups/rating.dart';
import 'package:flutter_application_33/user/provider_reviews.dart';

class ServiceProviderDetailsPage extends StatelessWidget {
  final String name;
  final double rating;
  final String mobile;
  final String providerId;
  final Map<String, dynamic> services;

  const ServiceProviderDetailsPage({
    Key? key,
    required this.name,
    required this.rating,
    required this.mobile,
    required this.services,
    required this.providerId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Menu(
      child: Scaffold(
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
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 7, 65, 115),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                RatingBarIndicator(
                                  rating: rating,
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  itemCount: 5,
                                  itemSize: 25,
                                  direction: Axis.horizontal,
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProviderReviewsPage(
                                                  providerId: providerId),
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
                                            color:
                                                Color.fromARGB(255, 7, 65, 115),
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
                        if (services.isNotEmpty)
                          ...services.entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50.0, vertical: 8),
                              child: Text(
                                "${entry.key}: ${entry.value}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        if (services.isEmpty)
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
                        const SizedBox(height: 200),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => live_track_user(),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 7, 40, 89),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 120, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Book',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
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
      ),
    );
  }
}
