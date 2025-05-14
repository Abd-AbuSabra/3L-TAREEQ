import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class nav extends StatefulWidget {
  const nav({super.key});

  @override
  State<nav> createState() => _navState();
}

class _navState extends State<nav> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: const Color.fromARGB(255, 192, 228, 194),
        color: const Color.fromARGB(255, 21, 95, 155),
        animationDuration: Duration(milliseconds: 300),
        items: [
        Icon(Icons.list_rounded,size: 35,color:Colors.white),

        Icon(Icons.home_rounded,size: 35,color:Colors.white),
        
        Icon(Icons.person_2_rounded,size: 35,color:Colors.white),
        
        
        
        ])
    );
  }
}