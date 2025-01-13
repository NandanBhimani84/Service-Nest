import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class manageUser extends StatefulWidget {
  @override
  _manageUserState createState() => _manageUserState();
}

class _manageUserState extends State<manageUser> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();

  // Colors for design
  Color lightEggshellColor = const Color(0xFFF5F0E3);
  Color darkEggshellColor = const Color(0xFFD3CDBB);
  Color moreDarkEggshellColor = const Color(0xFFA89F8F);
  Color evenMoreDarkEggshellColor = const Color(0xFF8D7F5C);

  final LinearGradient containerGradient = const LinearGradient(
    colors: [Color(0xFFF5F0E3), Color(0xFFD3CDBB)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'customer')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching users'));
            }
            final users = snapshot.data?.docs ?? [];
            return users.isEmpty
                ? Center(
              child: Text(
                'No User available',
                style: GoogleFonts.raleway(
                    fontSize: 18, color: Colors.black),
              ),
            )
                : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final userData = user.data() as Map<String, dynamic>;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
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
                                  Image.network(
                                    userData['image_url'],
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.broken_image,
                                        size: 100,
                                        color: Colors.grey,
                                      );
                                    },
                                  )
                                else
                                  const Icon(
                                    Icons.person,
                                    size: 100,
                                    color: Colors.grey,
                                  ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                              'assets/Icon/profile-avatar_c.png',
                                              height: 20),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              userData['name'] != null
                                                  ? ' ${userData['name']}'
                                                  : 'N/A',
                                              style: GoogleFonts.raleway(
                                                  fontSize: 14,
                                                  color: Colors.black),
                                              overflow:
                                              TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Image.asset(
                                              'assets/Icon/phone-book_c.png',
                                              height: 20),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              userData['mobile'] != null
                                                  ? '${userData['mobile']}'
                                                  : 'N/A',
                                              style: GoogleFonts.raleway(
                                                  fontSize: 14,
                                                  color: Colors.black),
                                              overflow:
                                              TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Image.asset(
                                              'assets/Icon/address-location_c.png',
                                              height: 20),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              userData['addresses'] !=
                                                  null
                                                  ? ' ${userData['addresses']}'
                                                  : 'N/A',
                                              style: GoogleFonts.raleway(
                                                  fontSize: 14,
                                                  color: Colors.black),
                                              overflow:
                                              TextOverflow.ellipsis,
                                            ),
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
                                          Expanded(
                                            child: Text(
                                              userData['email'] != null
                                                  ? ' ${userData['email']}'
                                                  : 'N/A',
                                              style: GoogleFonts.raleway(
                                                  fontSize: 14,
                                                  color: Colors.black),
                                              overflow:
                                              TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    _showEditDialog(user);
                                  },
                                  icon: Image.asset(
                                      'assets/Icon/edit-info_c.png',
                                      height: 20),
                                  label: Text('Edit',
                                      style: GoogleFonts.raleway(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      )),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    _deleteUser(user);
                                  },
                                  icon: Image.asset(
                                      'assets/Icon/delete-document_c.png',
                                      height: 20),
                                  label: Text('Delete',
                                      style: GoogleFonts.raleway(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      )),
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

  void _showEditDialog(DocumentSnapshot user) {
    _nameController.text = user['name'];
    _mobileController.text = user['mobile'];
    _emailController.text = user['email'];

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFBAE5F4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit User',
                      style: GoogleFonts.raleway(
                          fontSize: 14, color: Colors.black)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
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
                    controller: _mobileController,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
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
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel',
                            style: GoogleFonts.raleway(
                                fontSize: 14, color: Colors.black)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_nameController.text.isEmpty ||
                              _mobileController.text.isEmpty ||
                              _emailController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                    Text('All fields are required.')));
                          } else {
                            _updateUser(user.id);
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text('Save',
                            style: GoogleFonts.raleway(
                                fontSize: 14, color: Colors.white)),
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
  }

  void _updateUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'name': _nameController.text,
        'mobile': _mobileController.text,
        'email': _emailController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update user')),
      );
    }
  }

  void _deleteUser(DocumentSnapshot user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete user')),
      );
    }
  }
}
