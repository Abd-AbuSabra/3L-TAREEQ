import 'package:flutter/material.dart';

class logo  extends StatelessWidget {
  const logo ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

     
           body: Center(
              child: Image.asset('lib/images/logo2.png'),
            )
          
              
    );
  }
}