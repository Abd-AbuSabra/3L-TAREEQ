import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Rating_popup extends StatefulWidget {
  final String providerId;
  final String username;

  const Rating_popup({
    super.key,
    required this.providerId,
    required this.username,
  });

  @override
  State<Rating_popup> createState() => _Rating_popupState();
}

class _Rating_popupState extends State<Rating_popup> {
  final TextEditingController _controller = TextEditingController();
  double _rating = 3;

  Future<void> _handleSubmit() async {
    String inputText = _controller.text.trim();
    if (inputText.isEmpty) return;

    try {
      final providerRef = FirebaseFirestore.instance
          .collection('providers')
          .doc(widget.providerId);

      // Add review to subcollection
      await providerRef.collection('reviews').add({
        'username': widget.username,
        'rating': _rating,
        'text': inputText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Recalculate average rating
      final reviewsSnapshot = await providerRef.collection('reviews').get();
      double totalRating = 0;
      int count = reviewsSnapshot.docs.length;

      for (var doc in reviewsSnapshot.docs) {
        totalRating += (doc.data()['rating'] ?? 0);
      }

      double avgRating = count > 0 ? totalRating / count : 0;

      // Update provider with new average rating
      await providerRef.update({'averageRating': avgRating});

      // Clear input and close popup
      _controller.clear();
      Navigator.of(context).pop();
    } catch (e) {
      print('Error submitting review: $e');
      // Optionally, show an error message here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.close, color: Colors.grey.shade200),
                    iconSize: 30,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Leave a review :)",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 7, 40, 89),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  RatingBar.builder(
                    initialRating: 3,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _rating = rating;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Color.fromARGB(255, 7, 40, 89), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _controller,
                  maxLines: 4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 7, 40, 89),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
