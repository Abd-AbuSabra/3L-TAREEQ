import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Confirm_2 extends StatelessWidget {
  const Confirm_2({super.key});

  @override
  Widget build(BuildContext context) {
    return  Dialog(
      
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Container(
             
                decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),),
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [ 
                     Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                     IconButton(onPressed: (){Navigator.of(context).pop();}, icon: Icon(Icons.close,color:Colors.grey.shade200),iconSize: 30,),],),
                     
                 
                Row
                (
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                 LottieBuilder.network(
                  
                  'https://lottie.host/6b2b4d50-1e55-45d3-b2db-c08d1ac6c6e4/lOoGDTyAl9.json',width: 200,height: 200,repeat: false,),
            
                  ],
                 ),
            
                 
                     SizedBox(height: 10,),
                     Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                     Text("Confirmed ",style: TextStyle(fontSize: 50,fontWeight: FontWeight.bold,color:const Color.fromARGB(255, 7, 40, 89)),),
                      ],
                     ),
                      SizedBox(height: 10,),
                     Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                    
                    children: [  
                     
                    
                   Text("We’ve sent your request ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color:const Color.fromARGB(255, 7, 40, 89)),),
                     
                      ],  ),
                       Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                    
                    children: [  
                     
                    
                   Text("check your Email for further notice",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color:const Color.fromARGB(255, 7, 40, 89)),),
                     
                      ],  ),
                  
              ],   
                    ),
            ),
          ),
        );
  }
}