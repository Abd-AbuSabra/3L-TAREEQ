import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Received_popup extends StatelessWidget {
  const Received_popup({super.key});

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
                     Text("Received ",style: TextStyle(fontSize: 50,fontWeight: FontWeight.bold,color:const Color.fromARGB(255, 7, 40, 89)),),
                      ],
                     ),
                      SizedBox(height: 10,),
                     Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                    
                    children: [  
                     
                    
                   Text("Thank you for your service",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color:const Color.fromARGB(255, 7, 40, 89)),),
                     
                      ],  ),
                      
                    SizedBox(height: 20,),

                       Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                    
                    children: [  
                     
                    ElevatedButton(
      onPressed: (){

        Navigator.of(context).pop();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:  Color.fromARGB(255, 7, 40, 89),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: const Text(
        'Done',
        style: TextStyle(color: Colors.white,fontSize: 18),
      ),
    ),
                    
                     
                      ],  ),
                  
              ],   
                    ),
            ),
          ),
        );
  }
}