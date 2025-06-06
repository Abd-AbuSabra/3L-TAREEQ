import 'package:flutter/material.dart';
import 'package:flutter_application_33/service_provider/invoice_SP.dart';
import 'package:flutter_application_33/universal_components/Menu.dart';
import 'package:flutter_application_33/user/invoice_user.dart';
import 'package:flutter_application_33/user/live_tracking_user.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_application_33/pop_ups/rating.dart';
import 'package:flutter_application_33/user/provider_reviews.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_33/user/live_tracking_user.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_application_33/user/provider_reviews.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_application_33/user/service_prodiver_details.dart';
import 'package:flutter_application_33/universal_components/Menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_33/service_provider/invoice_SP.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_application_33/service_provider/live_tracking_sp.dart';
import 'dart:async';

class ServiceProviderDetailsPage extends StatefulWidget {
  final String name;
  final double rating;
  final String mobile;
  final String providerId;
  final String image;
  final Map<String, dynamic> services;

  const ServiceProviderDetailsPage(
      {Key? key,
      required this.name,
      required this.rating,
      required this.mobile,
      required this.services,
      required this.providerId,
      required this.image})
      : super(key: key);

  @override
  State<ServiceProviderDetailsPage> createState() =>
      _ServiceProviderDetailsPageState();
}

class _ServiceProviderDetailsPageState
    extends State<ServiceProviderDetailsPage> {
  bool isBooking = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> updateBookedStatus() async {
    try {
      // Update the Booked field to true for the specific userId
      await _firestore
          .collection('acceptedProviders')
          .where('userId',
              isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '')
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.update({'Booked': true});
        });
      });

      // Navigate to live_track_user page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => live_track_user()),
      );
    } catch (e) {
      print('Error updating booked status: $e');
      // You can show a snackbar or dialog here to inform the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update booking status')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    startListeningForBookedStatus();
  }

  @override
  void dispose() {
    // Cancel the listener when widget is disposed
    _bookedStatusListener?.cancel();
    super.dispose();
  }

  StreamSubscription<QuerySnapshot>? _bookedStatusListener;
  void startListeningForBookedStatus() {
    _bookedStatusListener = _firestore
        .collection('acceptedProviders')
        .where('userId',
            isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = snapshot.docs.first;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Check if Booked field is true
        if (data['Booked'] == true) {
          // Automatically navigate to live_track_SP page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => live_track_user()),
          );

          // Optional: Cancel the listener after navigation to prevent multiple navigations
          _bookedStatusListener?.cancel();
        }
      }
    });
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
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade100,
                            radius: 45,
                            backgroundImage: widget.image != null
                                ? NetworkImage(widget.image!)
                                : const AssetImage('assets/profile.jpg')
                                    as ImageProvider,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                Text(
                                  widget.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 7, 65, 115),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                RatingBarIndicator(
                                  rating: widget.rating,
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
                                                  providerId:
                                                      widget.providerId),
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
                        if (widget.services.isNotEmpty)
                          ...widget.services.entries.map(
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
                        if (widget.services.isEmpty)
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
                                updateBookedStatus();
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
                              child: isBooking
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
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
