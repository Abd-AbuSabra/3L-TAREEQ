import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class SP_details extends StatefulWidget {
  final Map<String, dynamic>? providerData;

  const SP_details({super.key, this.providerData});

  @override
  State<SP_details> createState() => _SP_detailsState();
}

class _SP_detailsState extends State<SP_details> {
  final Color customGreen = Color.fromARGB(255, 7, 65, 115);
  double rating = 0.0;
  Map<String, dynamic> services = {};
  String providerName = '"Name"';
  String providerEmail = '';
  String carBrand = '';
  String providerId = '';
  String memberSince = '';
  Map<String, dynamic>? providerData;
  String? profileImageUrl;
  Uint8List? _webImageBytes; // For storing picked image
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _carBrandController = TextEditingController();
  final TextEditingController ServiceController = TextEditingController();

  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    if (widget.providerData != null) {
      providerData = widget.providerData;
      _updateProviderData();
    } else {
      fetchProviderData();
    }
  }

  String getInitials(String name) {
    List<String> names = name.trim().split(" ");
    String initials = names.isNotEmpty ? names[0][0] : '';
    if (names.length > 1) initials += names[1][0];
    return initials.toUpperCase();
  }

  final Color avatarColor = Colors.teal;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _carBrandController.dispose();
    super.dispose();
  }

  void _updateProviderData() {
    if (providerData != null) {
      setState(() {
        providerName = providerData!['username'] ?? '"Name"';
        providerEmail = providerData!['email'] ?? '';
        carBrand = providerData!['carBrandAndType'] ?? '';
        providerId = providerData!['uid'] ?? '';
        rating = (providerData!['rating'] ?? 0).toDouble();
        services = Map<String, dynamic>.from(providerData!['services'] ?? {});
        _usernameController.text = providerName == '"Name"' ? '' : providerName;
        _emailController.text = providerEmail;
        _carBrandController.text = carBrand;
        profileImageUrl = providerData!['profileImageUrl'];
        if (providerData!['createdAt'] != null) {
          DateTime dateTime = providerData!['createdAt'].toDate();
          memberSince = DateFormat('MMMM yyyy').format(dateTime);
        }
      });
    }
  }

  Future<void> fetchProviderData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot providerDoc = await FirebaseFirestore.instance
            .collection('providers')
            .doc(currentUser.uid)
            .get();

        if (providerDoc.exists) {
          providerData = providerDoc.data() as Map<String, dynamic>;
          _updateProviderData();
        }
      }
    } catch (e) {
      print("Error fetching provider data: $e");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _webImageBytes = bytes;
      });

      // Automatically upload the image when picked
      await _uploadProfileImage();
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_webImageBytes == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Create a reference to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('provider_images')
            .child('${currentUser.uid}.jpg');

        // Upload the image
        await storageRef.putData(_webImageBytes!);

        // Get the download URL
        final downloadUrl = await storageRef.getDownloadURL();

        // Update Firestore with the new image URL
        await FirebaseFirestore.instance
            .collection('providers')
            .doc(currentUser.uid)
            .update({'profileImageUrl': downloadUrl});

        setState(() {
          profileImageUrl = downloadUrl;
          _webImageBytes = null; // Clear the temporary image
        });

        // Update the provider data
        if (providerData != null) {
          providerData!['profileImageUrl'] = downloadUrl;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Profile image updated successfully!"),
            backgroundColor: customGreen,
          ),
        );
      }
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update profile image. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _webImageBytes = null; // Clear the temporary image on error
      });
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Widget _buildProfileImage() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey.shade100,
          backgroundImage: _webImageBytes != null
              ? MemoryImage(_webImageBytes!)
              : (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                  ? NetworkImage(profileImageUrl!)
                  : null,
          child: (profileImageUrl == null || profileImageUrl!.isEmpty) &&
                  _webImageBytes == null
              ? Text(
                  getInitials(providerName),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
        if (_isUploadingImage)
          Positioned(
            bottom: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else
          Positioned(
            bottom: -4,
            right: -4,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(Icons.edit, color: Colors.black, size: 16),
              ),
            ),
          ),
      ],
    );
  }

  void _editFieldDialog(String fieldTitle, TextEditingController controller,
      String currentValue) {
    final tempController = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $fieldTitle",
              style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          content: TextField(
            controller: tempController,
            keyboardType: fieldTitle == "Email"
                ? TextInputType.emailAddress
                : TextInputType.text,
            decoration: InputDecoration(
              hintText: "Enter your $fieldTitle",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                          borderRadius: BorderRadius.circular(15))),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: customGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  onPressed: () {
                    final value = tempController.text.trim();
                    if (value.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Please enter a valid $fieldTitle")));
                      return;
                    }
                    if (fieldTitle == "Email" &&
                        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Please enter a valid email address")));
                      return;
                    }

                    setState(() {
                      controller.text = value;
                      if (fieldTitle == "Username") providerName = value;
                      if (fieldTitle == "Email") providerEmail = value;
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
            .collection('providers')
            .doc(currentUser.uid)
            .update(updatedData);

        providerData!.addAll(updatedData);
        _updateProviderData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text("Profile updated successfully!"),
              backgroundColor: customGreen),
        );
      }
    } catch (e) {
      print("Error updating provider data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to update profile. Please try again."),
            backgroundColor: Colors.red),
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
                  Text(label,
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 5),
                  Text(value.isEmpty ? "Not set" : value,
                      style: TextStyle(
                          color: customGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.edit, color: customGreen, size: 28),
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
              Text(label,
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 5),
              Text(value.isEmpty ? "Not available" : value,
                  style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
          trailing: Icon(Icons.lock, color: Colors.grey[400], size: 20),
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
                    leading: BackButton(color: customGreen),
                  ),
                  SizedBox(height: 60, width: 60, child: logo()),
                  const SizedBox(height: 20),
                  const Text("Provider's Profile",
                      style: TextStyle(
                          fontSize: 25,
                          color: Color.fromARGB(255, 192, 228, 194),
                          fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      height: 180,
                      width: 400,
                      decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            _buildProfileImage(), // Use the new profile image widget
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 40),
                                Column(
                                  children: [
                                    const SizedBox(width: 30),
                                    Text(providerName,
                                        style: const TextStyle(
                                            color:
                                                Color.fromARGB(255, 7, 65, 115),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20)),
                                  ],
                                ),
                                const SizedBox(height: 13),
                                RatingBarIndicator(
                                  rating: rating,
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  itemCount: 5,
                                  itemSize: 18,
                                  direction: Axis.horizontal,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildEditableDetailCard(
                      "Username", providerName, _usernameController),
                  _buildEditableDetailCard(
                      "Email", providerEmail, _emailController),
                  _buildEditableDetailCard(
                      "Car Brand", carBrand, _carBrandController),
                  _buildNonEditableDetailCard("Member Since", memberSince),
                  const SizedBox(height: 20),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: customGreen,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12)),
                      child: const Text("Save Changes",
                          style: TextStyle(color: Colors.white)),
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
