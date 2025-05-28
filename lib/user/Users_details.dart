import 'package:flutter/material.dart';
import 'package:flutter_application_33/Gemini/gemini_page.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter_application_33/user/dashboard_user.dart';
import 'package:flutter_application_33/user/login.dart';
import 'package:flutter_application_33/user/Users_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class user_details extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const user_details({super.key, this.userData});

  @override
  State<user_details> createState() => _user_detailsState();
}

class _user_detailsState extends State<user_details> {
  String? selectedPayment;
  final Color customGreen = const Color.fromARGB(255, 192, 228, 194);

  String userName = '"Name"';
  String userEmail = '';
  String carBrand = '';
  String userId = '';
  String memberSince = '';
  Map<String, dynamic>? userData;

  // Controllers for editing
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _carBrandController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      userData = widget.userData;
      _updateUserData();
    } else {
      fetchUserData();
    }
  }

  String getInitials(String name) {
    List<String> names = name.trim().split(" ");
    String initials = names.isNotEmpty ? names[0][0] : '';
    if (names.length > 1) initials += names[1][0];
    return initials.toUpperCase();
  }

  final Color avatarColor = Colors.teal; // Or generate randomly
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _carBrandController.dispose();
    super.dispose();
  }

  void _updateUserData() {
    if (userData != null) {
      setState(() {
        userName = userData!['username'] ?? '"Name"';
        userEmail = userData!['email'] ?? '';
        carBrand = userData!['carBrandAndType'] ?? '';
        userId = userData!['uid'] ?? '';

        // Initialize controllers with current data
        _usernameController.text = userName == '"Name"' ? '' : userName;
        _emailController.text = userEmail;
        _carBrandController.text = carBrand;

        if (userData!['createdAt'] != null) {
          DateTime dateTime = userData!['createdAt'].toDate();
          memberSince = DateFormat('MMMM yyyy').format(dateTime);
        }
      });
    }
  }

  Future<void> fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          userData = userDoc.data() as Map<String, dynamic>;
          _updateUserData();
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void _editFieldDialog(String fieldTitle, TextEditingController controller,
      String currentValue) {
    final tempController = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Edit $fieldTitle",
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          content: TextField(
            controller: tempController,
            keyboardType: fieldTitle == "Email"
                ? TextInputType.emailAddress
                : TextInputType.text,
            decoration: InputDecoration(
              hintText: "Enter your $fieldTitle",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: customGreen, width: 2),
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    final value = tempController.text.trim();
                    if (value.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Please enter a valid $fieldTitle")),
                      );
                      return;
                    }

                    // Email validation
                    if (fieldTitle == "Email" &&
                        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("Please enter a valid email address")),
                      );
                      return;
                    }

                    setState(() {
                      controller.text = value;
                      if (fieldTitle == "Username") userName = value;
                      if (fieldTitle == "Email") userEmail = value;
                      if (fieldTitle == "Car Brand") carBrand = value;
                    });
                    Navigator.pop(context);
                  },
                  child:
                      const Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        Map<String, dynamic> updatedData = {
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'carBrandAndType': _carBrandController.text.trim(),
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update(updatedData);

        // Update local data
        userData!.addAll(updatedData);
        _updateUserData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Profile updated successfully!"),
            backgroundColor: customGreen,
          ),
        );
      }
    } catch (e) {
      print("Error updating user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update profile. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildEditableDetailCard(
      String label, String value, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8),
      child: Card(
        color: Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value.isEmpty ? "Not set" : value,
                    style: TextStyle(
                      color: customGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.edit,
              color: customGreen,
              size: 28,
            ),
            onPressed: () => _editFieldDialog(label, controller, value),
          ),
        ),
      ),
    );
  }

  Widget _buildNonEditableDetailCard(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8),
      child: Card(
        color: Colors.white.withOpacity(0.7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 1,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value.isEmpty ? "Not available" : value,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          trailing: Icon(
            Icons.lock,
            color: Colors.grey[400],
            size: 20,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: BackButton(
                      color: customGreen,
                    ),
                  ),
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: logo(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "User's Personal Details",
                    style: TextStyle(
                      fontSize: 25,
                      color: Color.fromARGB(255, 192, 228, 194),
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
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: avatarColor,
                              child: Text(
                                getInitials(userName),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 40),
                                Row(
                                  children: [
                                    const SizedBox(width: 30),
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 7, 65, 115),
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
                      color: customGreen,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
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
                          const SizedBox(height: 10),

                          // Editable fields
                          _buildEditableDetailCard(
                              "Username", userName, _usernameController),
                          _buildEditableDetailCard(
                              "Email", userEmail, _emailController),
                          _buildEditableDetailCard(
                              "Car Brand", carBrand, _carBrandController),

                          // Non-editable fields

                          _buildNonEditableDetailCard(
                              "Member Since", memberSince),

                          const SizedBox(height: 40),

                          // Save Changes Button
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _saveChanges,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 3,
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: customGreen,
                                        ),
                                      )
                                    : Text(
                                        "Save Changes",
                                        style: TextStyle(
                                          color: customGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 300),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          CircularMenu(
            alignment: Alignment.bottomRight,
            toggleButtonColor: customGreen,
            items: [
              CircularMenuItem(
                icon: Icons.home,
                color: customGreen,
                iconColor: Colors.white,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const user_dashboard()),
                  );
                },
              ),
              CircularMenuItem(
                icon: Icons.person,
                color: customGreen,
                iconColor: Colors.white,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const users_profile()),
                  );
                },
              ),
              CircularMenuItem(
                icon: Icons.chat,
                color: customGreen,
                iconColor: Colors.white,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GeminiPage()),
                  );
                },
              ),
              CircularMenuItem(
                icon: Icons.logout,
                color: Colors.red,
                iconColor: Colors.white,
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
