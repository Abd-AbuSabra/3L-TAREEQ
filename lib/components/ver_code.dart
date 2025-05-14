import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class phone_code extends StatefulWidget {
  const phone_code({super.key});

  @override
  State<phone_code> createState() => _phone_codeState();
}

class _phone_codeState extends State<phone_code> {

   
   GlobalKey<FormState>formKey=GlobalKey<FormState>();
  String validpin="1234";

  @override
  void initState() {
   
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor: Colors.white,
      body: Center(
        child: Form(
          key: formKey,
          child: 
        
        Column(
          children: [
            Pinput(
              
              validator: (value){
        
                return value == validpin ? null:"Pin is incorrect";
              },
              onCompleted: (pin){
        
                print('Success:$pin');
              },
            ),
            SizedBox(height: 20,),
            TextButton(onPressed: (){
        
              formKey.currentState!.validate();
            }, child: Text("validate"))
          ],
        )),
      ),
    );
  }


 
}