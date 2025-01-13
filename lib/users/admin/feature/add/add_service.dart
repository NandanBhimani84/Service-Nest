import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';

class addService extends StatefulWidget {
  const addService({super.key});

  @override
  State<addService> createState() => _addServiceState();
}

class _addServiceState extends State<addService>
    with SingleTickerProviderStateMixin {
  // Sub-service controllers
  final subServiceNameController = TextEditingController();
  final priceController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Service controllers
  final serviceNameController = TextEditingController();
  final serviceCategoryController = TextEditingController();
  final routeController = TextEditingController(); // Route field controller
  List<String> _categories = [];
  String? _selectedCategory;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Fetch categories from Firebase
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('services').get();
      setState(() {
        _categories = querySnapshot.docs
            .map((doc) => doc['category'].toString())
            .toList();
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<String> _uploadImageToFirebase(File image, String folder) async {
    try {
      String fileName = path.basename(image.path);
      final storageRef =
      FirebaseStorage.instance.ref().child('$folder/$fileName');
      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      _showSnackBar('Error uploading image');
      return '';
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  bool _subValidateFields() {
    if (subServiceNameController.text.isEmpty) {
      _showSnackBar('Please enter a Sub-Service Name');
      return false;
    }
    if (priceController.text.isEmpty) {
      _showSnackBar('Please enter a valid price');
      return false;
    }
    if (_selectedCategory == null) {
      _showSnackBar('Please select a category');
      return false;
    }
    return true;
  }

  Future<void> _submitSubForm() async {
    if (_subValidateFields()) {
      try {
        String? imageUrl;
        if (_imageFile != null) {
          imageUrl = await _uploadImageToFirebase(_imageFile!, 'sub-services');
        }

        await FirebaseFirestore.instance.collection('sub-services').add({
          'sub-serviceName': subServiceNameController.text,
          'price': priceController.text,
          'category': _selectedCategory,
          'imageUrl': imageUrl,
          'createdAt': Timestamp.now(),
        });

        _showSnackBar('Sub-Service added successfully!');

        // Fetch categories again to refresh the dropdown options
        await _fetchCategories(); // Reload categories

        // Clear the fields
        subServiceNameController.clear();
        priceController.clear();
        setState(() {
          _imageFile = null;
          _selectedCategory = null;
        });
      } catch (e) {
        _showSnackBar('Failed to add sub-service: $e');
      }
    }
  }

  bool _validateFields() {
    if (serviceNameController.text.isEmpty) {
      _showSnackBar('Please enter a Service Name');
      return false;
    }
    if (serviceCategoryController.text.isEmpty) {
      _showSnackBar('Please enter a Service Category');
      return false;
    }
    if (routeController.text.isEmpty) {
      _showSnackBar('Please enter a route');
      return false;
    }
    return true;
  }

  Future<void> _submitForm() async {
    if (_validateFields()) {
      try {
        String? imageUrl;
        if (_imageFile != null) {
          imageUrl = await _uploadImageToFirebase(_imageFile!, 'services');
        }

        // Adding the route field to the Firestore document
        await FirebaseFirestore.instance.collection('services').add({
          'serviceName': serviceNameController.text,
          'category': serviceCategoryController.text,
          'route': routeController.text, // Added route field
          'imageUrl': imageUrl,
          'createdAt': Timestamp.now(),
        });

        _showSnackBar('Service added successfully!');

        // Clear the fields
        serviceNameController.clear();
        serviceCategoryController.clear();
        routeController.clear(); // Clear the route field as well
        setState(() {
          _imageFile = null;
        });

        // Fetch categories again to refresh the sub-service tab view
        await _fetchCategories();

        // Switch to the sub-service tab and refresh the UI
        _tabController.animateTo(1); // Switch to sub-service tab
      } catch (e) {
        _showSnackBar('Failed to add service: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Colors.black.withOpacity(0.9),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: const Color(0xFFBAE5F4),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white,
                tabs: const [
                  Tab(text: 'Add Service'),
                  Tab(text: 'Add Sub-Service'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _serviceTabView(),
          _subServiceTabView(),
        ],
      ),
    );
  }

  Widget _subServiceTabView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 300,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  image: _imageFile != null
                      ? DecorationImage(
                    image: FileImage(_imageFile!),
                  )
                      : null,
                ),
                child: _imageFile == null
                    ? Icon(Icons.camera_alt, size: 40, color: Colors.grey[800])
                    : null,
              ),
            ),
          ),
          const Text("Upload Image", style: TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              labelText: 'Sub-Service Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            controller: subServiceNameController,
          ),
          const SizedBox(height: 10),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Price',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            controller: priceController,
          ),
          const SizedBox(height: 10),
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
          ElevatedButton(
            onPressed: () async {
              await _submitSubForm();
            },
            child: const Text('Submit'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceTabView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 300,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  image: _imageFile != null
                      ? DecorationImage(
                    image: FileImage(_imageFile!),
                  )
                      : null,
                ),
                child: _imageFile == null
                    ? Icon(Icons.camera_alt, size: 40, color: Colors.grey[800])
                    : null,
              ),
            ),
          ),
          const Text("Upload Image", style: TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              labelText: 'Service Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            controller: serviceNameController,
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              labelText: 'Service Category',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            controller: serviceCategoryController,
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              labelText: 'Route', // Route input field
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            controller: routeController,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              await _submitForm();
            },
            child: const Text('Submit'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
