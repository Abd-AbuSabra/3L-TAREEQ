import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_33/service_provider/invoice_SP.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_33/service_provider/live_tracking_sp.dart';

class Dashboard_SP extends StatefulWidget {
  const Dashboard_SP({super.key});

  @override
  State<Dashboard_SP> createState() => _Dashboard_SPState();
}

class _Dashboard_SPState extends State<Dashboard_SP> {
  String providerName = 'Provider';
  double providerRating = 0;
  String joinedDateString = '';
  String? profileImageUrl;
  final TextEditingController reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProviderData();
  }

  Future<void> loadProviderData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final providerDoc = await FirebaseFirestore.instance
          .collection('providers')
          .doc(user.uid)
          .get();

      if (providerDoc.exists) {
        final data = providerDoc.data()!;
        setState(() {
          providerName = data['username'] ?? 'Unnamed Provider';
          providerRating = (data['rating'] ?? 0).toDouble();
          profileImageUrl = data['profileImageUrl'];

          final Timestamp? joinedAt = data['joinedAt'];
          if (joinedAt != null) {
            final DateTime joinedDate = joinedAt.toDate();
            joinedDateString =
                'Joined: ${DateFormat.yMMMMd().format(joinedDate)}';
          } else {
            joinedDateString = 'Joined: Unknown';
          }
        });
      } else {
        print("Provider document not found for uid: ${user.uid}");
      }
    } catch (e) {
      print("Failed to load provider data: $e");
    }
  }

  Stream<QuerySnapshot> getProviderRequests() {
    final currentProviderId = FirebaseAuth.instance.currentUser?.uid ?? "yoyo";
    print("ypypyyp");
    print(currentProviderId);
    return FirebaseFirestore.instance
        .collection('serviceRequests')
        .where('status', isEqualTo: 'pending')
        .where('targetProviderId', isEqualTo: currentProviderId)
        // .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> acceptServiceRequest(
      String docId, Map<String, dynamic> data) async {
    try {
      final userId = data['userId']; // user who requested
      final providerId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final providerEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      final userEmail = data['userEmail'] ?? '';
      final userSelectedServices =
          data['services'] ?? []; // Services user actually selected
      final times = data['times'] ?? [];
      // Get provider's service pricing
      final providerDoc = await FirebaseFirestore.instance
          .collection('providers')
          .doc(providerId)
          .get();

      final providerData = providerDoc.data() ?? {};
      final providerServices =
          providerData['services'] as Map<String, dynamic>? ?? {};

      // Create filtered services map with only user-selected services and their prices
      Map<String, dynamic> filteredServices = {};
      for (String service in userSelectedServices) {
        if (providerServices.containsKey(service)) {
          filteredServices[service] = providerServices[service];
        }
      }
      if (providerServices.containsKey('Service')) {
        filteredServices['Service'] = providerServices['Service'];
      }
      // 1. Update the serviceRequest doc status to accepted, and assign providerId
      await FirebaseFirestore.instance
          .collection('serviceRequests')
          .doc(docId)
          .update({
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
        'providerId': providerId,
        'providerEmail': providerEmail
      });

      // 2. Mark other pending requests for this user as expired
      final otherRequestsQuery = await FirebaseFirestore.instance
          .collection('serviceRequests')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in otherRequestsQuery.docs) {
        if (doc.id != docId) {
          // Don't update the accepted one
          batch.update(doc.reference, {
            'status': 'expired',
            'expiredAt': FieldValue.serverTimestamp(),
          });
        }
      }
      await batch.commit();

      // 3. Create or update acceptedProviders document
      await FirebaseFirestore.instance
          .collection('acceptedProviders')
          .doc(userId)
          .set({
        'userId': userId,
        'userEmail': userEmail,
        'userMobile': '',
        'providerId': providerId,
        'username': providerName,
        'providerEmail': providerEmail,
        'services':
            filteredServices, // Only user-selected services with their prices
        'times': times,
        'rating': providerRating,
        'providerMobile': providerData['mobile'] ?? '',
        'isAccepted': true,
        'timestamp': FieldValue.serverTimestamp(),
      });

      showDialog(
        context: context,
        builder: (context) => live_track_SP(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request Accepted')),
      );
    } catch (e) {
      print("Error accepting service request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error accepting request')),
      );
    }
  }

  Future<void> declineServiceRequest(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('serviceRequests')
          .doc(docId)
          .update({
        'status': 'declined',
        'declinedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request Declined')),
      );
    } catch (e) {
      print("Error declining service request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error declining request')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),
              SizedBox(height: 60, width: 60, child: logo()),
              const SizedBox(height: 20),
              const Text("Profile",
                  style: TextStyle(
                      fontSize: 25,
                      color: Color.fromARGB(255, 192, 228, 194),
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              buildProfileCard(),
              const SizedBox(height: 30),
              buildInfoCards(),
              const SizedBox(height: 30),
              buildRequestsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        height: 180,
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
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl!)
                    : const AssetImage('assets/profile.jpg') as ImageProvider,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      providerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 7, 65, 115),
                      ),
                    ),
                    const SizedBox(height: 6),
                    RatingBarIndicator(
                      rating: providerRating,
                      itemBuilder: (context, index) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 20.0,
                      direction: Axis.horizontal,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      joinedDateString,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 7, 65, 115),
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

  Widget buildInfoCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _infoCard(
              title: 'Money made',
              value: '0\$',
              color: const Color.fromARGB(255, 192, 228, 194)),
          const SizedBox(height: 10),
          _infoCard(
              title: 'No. services today',
              value: '0',
              color: const Color(0xFF083B6F)),
        ],
      ),
    );
  }

  Widget buildRequestsSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(50),
        topRight: Radius.circular(50),
      ),
      child: Container(
        width: double.infinity,
        color: const Color.fromRGBO(22, 121, 171, 1.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 30),
              child: Text(
                "Requests",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: getProviderRequests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("No requests at the moment.",
                        style: TextStyle(color: Colors.white)),
                  );
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final services =
                        (data['services'] as List?)?.join(", ") ?? '';
                    final times = (data['times'] as List?)?.join(", ") ?? '';

                    return Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(services,
                              style: const TextStyle(
                                  color: Color(0xFF083B6F),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                          const SizedBox(height: 8),
                          Text("ETA: $times",
                              style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.red[100],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () async {
                                  await declineServiceRequest(doc.id);
                                },
                                child: Text('Decline',
                                    style: TextStyle(color: Colors.red[800])),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFF083B6F),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  acceptServiceRequest(doc.id, data);
                                },
                                child: const Text('Accept',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 400),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(
      {required String title, required String value, required Color color}) {
    return Container(
      height: 128,
      width: 180,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
