import 'package:flutter/material.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';

class SP_details extends StatefulWidget {
  const SP_details({super.key});

  @override
  State<SP_details> createState() => _SP_detailsState();
}

class _SP_detailsState extends State<SP_details> {
  String? selectedPayment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color:Color.fromRGBO(22, 121, 171, 1.0),
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
                "Service provider's personal Details",
                style: TextStyle(
                  fontSize: 22,
                  color: const Color.fromARGB(255, 192, 228, 194),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  height: 180,
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
                          radius: 60,
                          backgroundImage: AssetImage('assets/profile.jpg'),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 40,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 30,
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
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                child: Container(
                  width: double.infinity,
                  color:Color.fromRGBO(22, 121, 171, 1.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                "Details",
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 500,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
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
