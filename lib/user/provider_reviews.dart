import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import 'package:flutter_application_33/universal_components/Menu.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProviderReviewsPage extends StatefulWidget {
  final String providerId;
  const ProviderReviewsPage({super.key, required this.providerId});
  @override
  State<ProviderReviewsPage> createState() => _ProviderReviewsPageState();
}

class _ProviderReviewsPageState extends State<ProviderReviewsPage>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> reviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('providers')
          .doc(widget.providerId)
          .collection('reviews')
          .get();

      final fetchedReviews = snapshot.docs.asMap().entries.map((entry) {
        final index = entry.key;
        final doc = entry.value;
        final data = doc.data();

        final username = data['username'] ?? '??';

        return {
          'initials': username.length >= 2
              ? username.substring(0, 2).toUpperCase()
              : username.toUpperCase(),
          'color': Colors.primaries[index % Colors.primaries.length],
          'text': data['text'] ?? '',
          'rating': (data['rating'] ?? 0).toDouble(),
        };
      }).toList();

      setState(() {
        reviews = fetchedReviews;
        isLoading = false;
      });

      print('Fetched ${fetchedReviews.length} reviews');
    } catch (e) {
      print('Error fetching reviews: $e');
      setState(() {
        reviews = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Menu(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(0, 120, 119, 119),
          elevation: 0,
          leading: BackButton(
            color: Color.fromARGB(255, 192, 228, 194),
          ),
          centerTitle: true,
        ),
        body: AnimatedBackground(
          vsync: this,
          behaviour: RandomParticleBehaviour(
            options: ParticleOptions(
              spawnMaxRadius: 200,
              spawnMinRadius: 10,
              spawnMinSpeed: 10,
              spawnMaxSpeed: 15,
              particleCount: 0,
              spawnOpacity: 0.1,
              maxOpacity: 0.1,
              baseColor: const Color.fromARGB(255, 192, 228, 194),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Center(
                  child: Image.asset(
                    'lib/images/logo2.png',
                    width: 120,
                    height: 120,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Reviews",
                        style: TextStyle(
                          color: Color.fromARGB(255, 192, 228, 194),
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimationLimiter(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 1600),
                        childAnimationBuilder: (widget) => SlideAnimation(
                          horizontalOffset: 120.0,
                          child: FadeInAnimation(child: widget),
                        ),
                        children: reviews.map((review) {
                          return Container(
                            height: 160,
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                )
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 45,
                                  backgroundColor: review["color"],
                                  child: Text(
                                    review["initials"],
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 30),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review["text"],
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      RatingBarIndicator(
                                        rating: review["rating"].toDouble(),
                                        itemBuilder: (context, index) => Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        itemCount: 5,
                                        itemSize: 20.0,
                                        direction: Axis.horizontal,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
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
