import 'package:flutter/material.dart';
import 'package:flutter_application_33/circles/battery_circle.dart';
import 'package:flutter_application_33/circles/gas_circle_.dart';
import 'package:flutter_application_33/circles/tile_circle.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';

class invoice_SP extends StatefulWidget {
  const invoice_SP({super.key});

  @override
  State<invoice_SP> createState() => _invoice_SPState();
}

class _invoice_SPState extends State<invoice_SP> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: 
    Scaffold(
    backgroundColor: Colors.white,
    body: SingleChildScrollView(
  child: Column(
    children: [
      SizedBox(height: 15),
                Container(
                  height: 60,
                  width: 60,
                  child: logo(),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Invioce details",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 192, 228, 194),
                        ),
                      )
                    ],
                  ),
                ),

                 SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: Color.fromRGBO(22, 121, 171, 1.0),
                    child: Column(
                      children: [
                      
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            
                               Container(
                                height: 100,
                                width: 100,
                                child:battery_circle(),
                               ),
                               Container(
                                 height: 100,
                                width: 100,
                                child: gas_circle(),
                               ),
                               Container(
                                 height: 100,
                                width: 100,
                                child: tile_circle(),)
                              
                            ],
                          
                          ),
                          
                        ),
                        

                        SizedBox(height: 400,),

                         ElevatedButton(
                    onPressed: () {
                      
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 192, 228, 194),
                      padding: EdgeInsets.symmetric(horizontal: 150, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Received',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 80,),
                      ],
                    ),
                  ),
                    ),
    ],
  ),

    ),

    ));
  }
}