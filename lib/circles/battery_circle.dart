import 'package:flutter/material.dart';

class battery_circle extends StatelessWidget {
  const battery_circle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 192, 228, 194), 
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Image.asset(
            'lib/images/battery.png', 
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
