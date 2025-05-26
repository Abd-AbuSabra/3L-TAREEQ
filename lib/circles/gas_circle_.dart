import 'package:flutter/material.dart';

class gas_circle extends StatelessWidget {
  const gas_circle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color:  const Color.fromARGB(255, 7, 40, 89), 
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Image.asset(
            'lib/images/gas.png', 
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
