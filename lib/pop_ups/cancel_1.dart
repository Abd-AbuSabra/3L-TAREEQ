import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Cancel_1 extends StatelessWidget {
  const Cancel_1({super.key});

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
                  
                  'https://lottie.host/53d899d1-d18a-48a2-95cd-087548cc1be0/StQLTjJOAR.json',width: 200,height: 200,repeat: false,),
            
                  ],
                 ),
            
                 
                     SizedBox(height: 10,),
                     Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                     Text("Canceled ",style: TextStyle(fontSize: 45,fontWeight: FontWeight.bold,color:const Color.fromARGB(255, 7, 40, 89)),),
                      ],
                     ),
                      SizedBox(height: 10,),
                     Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                    
                    children: [  
                     
                    
                   Text("we've canceled your request",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color:const Color.fromARGB(255, 7, 40, 89)),),
                     
                      ],  ),
                  
              ],   
                    ),
            ),
          ),
        );
  }
}