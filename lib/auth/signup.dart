import 'dart:math';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:major_project_1/auth/signin.dart';
import 'package:path/path.dart' as path;

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  File? _imageFile; // Holds the picked image file
  final ImagePicker _picker = ImagePicker(); // Instance of ImagePicker

  void _generatePassword() {
    const length = 6;
    const charset = 'abcd1234';
    final random = Random.secure();
    final password =
    List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();

    setState(() {
      passwordController.text = password;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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

        // Create the user with email and password
        await auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        String? imageUrl;

        // If there's an image file, upload it and await the download URL
        if (_imageFile != null) {
          imageUrl = await _uploadImageToFirebase(_imageFile!);
        }

        // Save user data to Firestore, including the uploaded image URL if available
        await FirebaseFirestore.instance
            .collection('users')
            .doc(auth.currentUser?.uid)
            .set({
          'name': nameController.text,
          'mobile': mobileController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'role': 'customer',
          'image_url': imageUrl, // Use the awaited image URL
        });

        _showSnackBar('User registered successfully');

        // Clear controllers and image file
        _clearControllers();
      } catch (e) {
        _showSnackBar('Error: $e');
      }
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

  Future<String> _uploadImageToFirebase(File image) async {
    try {
      // Extract the file name
      String fileName = path.basename(image.path);

      // Create a reference to the Firebase Storage location
      final storageRef =
      FirebaseStorage.instance.ref().child('uploads/$fileName');

      // Upload the image file to Firebase Storage
      await storageRef.putFile(image);

      // Retrieve the download URL of the uploaded image
      return await storageRef.getDownloadURL();
    } catch (e) {
      _showSnackBar('Error uploading image');
      return '';
    }
  }

  void _clearControllers() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    mobileController.clear();
    setState(() {
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset('assets/logo.png', height: 250)),
            Center(
              child: Text(
                'Create New Account',
                style: GoogleFonts.raleway(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                  _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: Colors.grey[800],
                  )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Name',
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              controller: nameController,
            ),
            const SizedBox(height: 16),
            TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                labelText: 'Mobile Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              controller: mobileController,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              controller: emailController,
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              controller: passwordController,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _generatePassword,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                minimumSize: Size(double.infinity, 50),
              ),
              child: const Text('Generate Password'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                minimumSize: Size(double.infinity, 50),
              ),
              child: const Text('Submit'),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Signin(),
                    ),
                  );
                },
                child: Text(
                  "Do have an account? SignIn",
                  style: GoogleFonts.raleway(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
