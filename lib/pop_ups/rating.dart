import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Rating_popup extends StatefulWidget {
  const Rating_popup({super.key});

  @override
  State<Rating_popup> createState() => _Rating_popupState();
}

class _Rating_popupState extends State<Rating_popup> {

  final TextEditingController _controller = TextEditingController();

  void _handleSubmit() {
    String inputText = _controller.text;
    print('Submitted: $inputText');
   
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return  Dialog(
      
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Container(
              
               
                decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),),
              child:  Column(
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
            print(rating);
          },
        ),
      ],
    ),
    SizedBox(height: 20),
    
   
    Container(
      decoration: BoxDecoration(
        border: Border.all(color:  Color.fromARGB(255, 7, 40, 89), width: 2),
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
        backgroundColor:  Color.fromARGB(255, 7, 40, 89),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: const Text(
        'Submit',
        style: TextStyle(color: Colors.white,fontSize: 18),
      ),
    ),
  ],
),

            ),
          ),
        );
  }
}