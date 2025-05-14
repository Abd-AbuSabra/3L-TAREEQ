import 'package:flutter/material.dart';


class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
  mainAxisAlignment: MainAxisAlignment.center,
      children: [
     
        InkWell(
          onTap: (){
          //  showDialog(context: context, builder: (context) => ());
          },
          child: Row( 
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
              
              height:50 ,
              width:100 ,
              color: Colors.white,
              
              child: Text("Contact",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color:Colors.grey),),
                      ),
            ],
          ), 
        ),
       SizedBox(height: 0,),
      
        InkWell(
            onTap: (){
            
            //   showDialog(context: context, builder: (context) => const Delete());

            },
          child: Container(
          height:50 ,
          width:100 ,
           color: Colors.white,
          
          child: Text("Cancel",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.red)),

          
        ), 
        ),
        
      ],
    );
  }
}