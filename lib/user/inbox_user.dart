import 'package:flutter/material.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';

class inbox_user extends StatefulWidget {
  const inbox_user({super.key});

  @override
  State<inbox_user> createState() => _inbox_userState();
}

class _inbox_userState extends State<inbox_user> {
  String? selectedPayment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color:const Color.fromARGB(255, 192, 228, 194),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
            
              SizedBox(
                height: 60,
                width: 60,
                child: logo(),
              ),
              const SizedBox(height: 20),
              Text(
                "Inbox",
                style: TextStyle(
                  fontSize: 30,
                  color: const Color.fromARGB(255, 192, 228, 194),
                  fontWeight: FontWeight.bold,
                ),
              ),
             SizedBox(height: 40,),
              
             ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                child: Container(
                  width: double.infinity,
                  color: const Color.fromARGB(255, 192, 228, 194),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              "",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          
                          ListTile(
                             trailing: Text("12:00 PM",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                 ),),
                            subtitle: Text("last text",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                 ),),
                             leading: CircleAvatar(radius: 40,backgroundColor: Colors.white,),
                            title: Text(
                              'user 1',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                      
                            onTap: () {
                             
                            },
                          ),
                          SizedBox(
                            height: 45,
                          ),
                          ListTile(
                            trailing: Text("12:00 PM",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                 ),),
                             subtitle: Text("last text",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                 ),),
                             leading: CircleAvatar(radius: 40,backgroundColor: Colors.white,),
                            title: Text('user 2',
                                style: TextStyle(
                                  color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                          
                            onTap: () {
                             
                            },
                          ),
                          SizedBox(
                            height: 45,
                          ),
                          ListTile(
                             trailing: Text("12:00 PM",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                 ),),
                             subtitle: Text("last text",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                 ),),
                            title: Text('user 3',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                                    leading: CircleAvatar(radius: 40,backgroundColor: Colors.white,),
                           
                            onTap: () {
                            
                              

                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 500,
                      ),
                     
                    ],
                  ),
                ),
              ),
            


            ],
          ),
        ),
      ),
    );
  }
}
