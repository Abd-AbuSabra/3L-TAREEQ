import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ProviderReviewsPage extends StatefulWidget {
  ProviderReviewsPage({super.key});

  @override
  State<ProviderReviewsPage> createState() => _ProviderReviewsPageState();
}

class _ProviderReviewsPageState extends State<ProviderReviewsPage> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> reviews = [
    {
      "initials": "AJ",
      "color": Colors.teal,
      "text": "Finding an honest mechanic can be tough, and he exceeded my expectations.",
      "rating": 5,
    },
    {
      "initials": "HH",
      "color": Colors.deepPurple,
      "text": "I had an excellent experience. My car was making strange noises, and they quickly diagnosed and fixed the issue.",
      "rating": 4,
    },
    {
      "initials": "QK",
      "color": Colors.redAccent,
      "text": "I was worried about the cost of my car repairs, yet been given a clear estimate upfront and stuck to it.",
      "rating": 5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                  style: const TextStyle(color: Colors.white,fontSize: 23,fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 30),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    Row(
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          Icons.star,
                                          color: i < review["rating"]
                                              ? Colors.amber
                                              : Colors.grey[300],
                                          size: 20,
                                        ),
                                      ),
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
    );
  }
}
