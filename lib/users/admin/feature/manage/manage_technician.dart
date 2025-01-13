import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class manageTechnician extends StatelessWidget {
  manageTechnician({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'technician')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching Servicemen'));
            }
            final users = snapshot.data?.docs ?? [];
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final userData = user.data() as Map<String, dynamic>;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                    SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color(0xFFBAE5F4).withOpacity(0.6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (userData['image_url'] != null &&
                                    userData['image_url'].isNotEmpty)
                                  Center(
                                    child: Image.network(
                                      userData['image_url'],
                                      height: 100, // Adjust height
                                      width: 100, // Adjust width
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.broken_image,
                                          size: 100,
                                          color: Colors.grey,
                                        );
                                      },
                                    ),
                                  )
                                else
                                  const Center(
                                    child: Icon(
                                      Icons.person,
                                      size: 100,
                                      color: Colors
                                          .grey, // Default icon if no photo is available
                                    ),
                                  ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                            'assets/Icon/profile-avatar_c.png',
                                            height: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          ' ${userData['name'] ?? 'N/A'}',
                                          style: GoogleFonts.raleway(
                                              fontSize: 14, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Image.asset('assets/Icon/phone-book_c.png',
                                            height: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          ' ${userData['mobile'] ?? 'N/A'}',
                                          style: GoogleFonts.raleway(
                                              fontSize: 14, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Image.asset(
                                            'assets/Icon/necktie.png',
                                            height: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          ' ${userData['employee_number'] ?? 'N/A'}',
                                          style: GoogleFonts.raleway(
                                              fontSize: 14, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Image.asset(
                                            'assets/Icon/email-helpline_c.png',
                                            height: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          ' ${userData['email'] ?? 'N/A'}',
                                          style: GoogleFonts.raleway(
                                              fontSize: 14, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    // Edit button functionality
                                    _editTechnician(context, user.id, userData);
                                  },
                                  icon: Image.asset(
                                      'assets/Icon/edit-info_c.png',height: 20,),
                                  label: Text(
                                    'Edit',
                                    style: GoogleFonts.raleway(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    // Delete button functionality
                                    _deleteTechnician(context, user.id);
                                  },
                                  icon: Image.asset(
                                      'assets/Icon/delete-document_c.png',height: 20,),
                                  label: Text(
                                    'Delete',
                                    style: GoogleFonts.raleway(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _updatePhoto(BuildContext context, String userId) async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('$userId.jpg');

    try {
      await storageRef.putFile(file);
      final downloadURL = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'image_url': downloadURL,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update photo: $e')),
      );
    }
  }

  void _editTechnician(
      BuildContext context, String userId, Map<String, dynamic> userData) {
    TextEditingController nameController =
        TextEditingController(text: userData['name']);
    TextEditingController mobileController =
        TextEditingController(text: userData['mobile']);
    TextEditingController employeeNumberController =
        TextEditingController(text: userData['employee_number']);
    TextEditingController emailController =
        TextEditingController(text: userData['email']);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFBAE5F4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Servicemen',
                        style: GoogleFonts.raleway(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: mobileController,
                        decoration: InputDecoration(
                          labelText: 'Mobile Number',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: employeeNumberController,
                        decoration: InputDecoration(
                          labelText: 'Employee Number',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _updatePhoto(context, userId),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Update Photo'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.purple, // Text color
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(); // Close the dialog without saving
                            },
                            child: Text('Cancel',
                                style:
                                    GoogleFonts.raleway(color: Colors.black87)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .update({
                                'name': nameController.text,
                                'mobile': mobileController.text,
                                'employee_number':
                                    employeeNumberController.text,
                                'email': emailController.text,
                              }).then((_) {
                                Navigator.of(context)
                                    .pop(); // Close the dialog after saving
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Servicemen details updated successfully')),
                                );
                              }).catchError((error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Failed to update Servicemen details: $error')),
                                );
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.purple,
                              backgroundColor: Colors.white, // Text color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteTechnician(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Delete'),
          content: const Text(
              'Are you sure you want to delete this Servicemen member?'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                // Show confirmation dialog before deletion
                showCupertinoDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                      title: const Text('Confirm Deletion'),
                      content: const Text(
                          'Are you sure you want to delete this technician?'),
                      actions: [
                        CupertinoDialogAction(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close alert dialog
                          },
                          child: const Text('Cancel'),
                        ),
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () {
                            // Proceed with deletion
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .delete()
                                .then((_) {
                              Navigator.of(context).pop(); // Close both dialogs
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Technician deleted successfully')),
                              );
                            }).catchError((error) {
                              Navigator.of(context).pop(); // Close both dialogs
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Failed to delete technician: $error')),
                              );
                            });
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
