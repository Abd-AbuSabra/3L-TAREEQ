import 'package:flutter/material.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_application_33/service_provider/apply.dart';
import 'package:flutter_application_33/user/Users_details.dart';
import 'package:flutter_application_33/user/service_history.dart';

class users_profile extends StatefulWidget {
  const users_profile({super.key});

  @override
  State<users_profile> createState() => _users_profileState();
}

class _users_profileState extends State<users_profile> {
  String? selectedPayment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),
              SizedBox(
                height: 60,
                width: 60,
                child: logo(),
              ),
              const SizedBox(height: 20),
              Text(
                "User's profile",
                style: TextStyle(
                  fontSize: 25,
                  color: const Color.fromARGB(255, 192, 228, 194),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  height: 120,
                  width: 400,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 45,
                          backgroundImage: AssetImage('assets/profile.jpg'),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                ),
                                const Text(
                                  '"Name"',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  height: 170,
                  width: 400,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(22, 121, 171, 1.0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          Icon(Icons.replay, size: 45, color: Colors.white),
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '"Last Service"',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '"Details"',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 7, 40, 89),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
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
                              'Settings',
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
                          SizedBox(
                            height: 15,
                          ),
                          ListTile(
                            title: Text(
                              'Profile',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios,
                                color: Colors.white),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => user_details()),
                              );
                            },
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          ListTile(
                            title: Text('Service history',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            trailing: Icon(Icons.arrow_forward_ios,
                                color: Colors.white),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Services()),
                              );
                            },
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          ListTile(
                            title: Text('Register as a service provider',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            trailing: Icon(Icons.arrow_forward_ios,
                                color: Colors.white),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Apply()),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.logout, color: Colors.white),
                            label: Text(
                              'Log Out',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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
