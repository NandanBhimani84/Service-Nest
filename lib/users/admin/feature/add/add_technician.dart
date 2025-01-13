import 'dart:math';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';

class addTechnician extends StatefulWidget {
  const addTechnician({Key? key}) : super(key: key);

  @override
  State<addTechnician> createState() => _addTechnicianState();
}

class _addTechnicianState extends State<addTechnician> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final employeeController = TextEditingController();
  File? _imageFile; // Holds the picked image file
  final ImagePicker _picker = ImagePicker();

  List<String> _categories = [];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Fetch categories when the widget is initialized
  }

  // Fetch categories from Firestore
  Future<void> _fetchCategories() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('services').get();
      setState(() {
        _categories = querySnapshot.docs.map((doc) => doc['category'].toString()).toList();
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  void _generatePassword() {
    const length = 6; // Length of the password
    const charset = 'abcd1234';
    final random = Random.secure();
    final password = List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();

    setState(() {
      passwordController.text = password;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _validateFields() {
    if (nameController.text.isEmpty) {
      _showSnackBar('Please enter a name');
      return false;
    }
    if (mobileController.text.length != 10) {
      _showSnackBar('Please enter a valid 10-digit mobile number');
      return false;
    }
    if (employeeController.text.length != 6) {
      _showSnackBar('Please enter a valid 6-digit employee number');
      return false;
    }
    if (emailController.text.isEmpty) {
      _showSnackBar('Please enter an email');
      return false;
    }
    if (passwordController.text.isEmpty) {
      _showSnackBar('Please generate a password');
      return false;
    }
    return true;
  }

  Future<void> _submitForm() async {
    if (_validateFields()) {
      try {
        FirebaseAuth auth = FirebaseAuth.instance;
        await auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        ).then((value) async {
          // Upload the image and get the download URL
          String? imageUrl;
          if (_imageFile != null) {
            imageUrl = await _uploadImageToFirebase(_imageFile!);
          }

          // Save user information to Firestore
          await FirebaseFirestore.instance.collection('users').doc(auth.currentUser?.uid).set({
            'name': nameController.text,
            'mobile': mobileController.text,
            'employee_number': employeeController.text,
            'email': emailController.text,
            'password': passwordController.text,
            'role': 'technician',
            'image_url': imageUrl, // Pass the actual URL or null if no image
            'category': _selectedCategory, // Save selected category
          });

          // Reset the form fields
          _resetForm();
        });
      } catch (e) {
        _showSnackBar('Error: $e');
      }
    }
  }

  void _resetForm() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    mobileController.clear();
    employeeController.clear();
    setState(() {
      _imageFile = null; // Clear the image file
      _selectedCategory = null; // Clear the selected category
    });
  }

  Future<String> _uploadImageToFirebase(File image) async {
    try {
      // Extract the file name
      String fileName = path.basename(image.path);

      // Create a reference to the Firebase Storage location
      final storageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');

      // Upload the image file to Firebase Storage
      await storageRef.putFile(image);

      // Retrieve the download URL of the uploaded image
      return await storageRef.getDownloadURL();
    } catch (e) {
      _showSnackBar('Error uploading image');
      return '';
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Save the picked file locally
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                      child: _imageFile == null
                          ? Icon(Icons.camera_alt, size: 40, color: Colors.grey[800])
                          : null,
                    ),
                  ),
                  Text(
                    "Upload Image",
                    style: GoogleFonts.raleway(fontSize: 20),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: GoogleFonts.raleway(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              controller: nameController,
            ),
            SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                labelStyle: GoogleFonts.raleway(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              controller: mobileController,
            ),
            SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(6),
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                labelText: 'Employee Number',
                labelStyle: GoogleFonts.raleway(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              controller: employeeController,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: GoogleFonts.raleway(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              controller: emailController,
            ),
            SizedBox(height: 16),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: GoogleFonts.raleway(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              controller: passwordController,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: const Text("Select Category"),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(height: 32),
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: _generatePassword,
                    child: Text('Generate Password'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      textStyle: GoogleFonts.raleway(fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
