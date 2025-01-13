import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class viewProfile extends StatefulWidget {
  const viewProfile({super.key});

  @override
  State<viewProfile> createState() => _viewProfileState();
}

class _viewProfileState extends State<viewProfile> {
  final List<Map<String, dynamic>> profileOptions = [
    {
      'icon': 'assets/padlock.png',
      'title': 'Change Password',
      'route': null,
    },
    {
      'icon': 'assets/logout.png',
      'title': 'Logout',
      'route': ''
    },
  ];

  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchProfileImage();
  }

  // Function to fetch profile image from Firestore and Firebase Storage
  Future<void> _fetchProfileImage() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      // Fetch the profile image file name from the user_images collection
      DocumentSnapshot userImageSnapshot = await FirebaseFirestore.instance
          .collection('user_images')
          .doc(uid)
          .get();

      if (userImageSnapshot.exists) {
        String? profileImageName = userImageSnapshot['profileImage'];

        if (profileImageName != null && profileImageName.isNotEmpty) {
          // Get the download URL for the image from Firebase Storage
          String downloadUrl = await FirebaseStorage.instance
              .ref('profile_images/$profileImageName')
              .getDownloadURL();

          setState(() {
            _profileImageUrl =
                downloadUrl; // Set the URL to be used for the image
          });
        }
      }
    } catch (e) {
      print('Error fetching profile image: $e');
    }
  }

  // Function to sign out the user
  Future<void> _signOut() async {
    bool? confirmSignOut = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Confirm Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (confirmSignOut == true) {
      try {
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        print('Error signing out: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out. Please try again.')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        title: Text(
          'My Profile',
          style: GoogleFonts.raleway(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          // Fetching the logged-in user's document from Firestore
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth
                  .instance.currentUser?.uid) // Get the current user's UID
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching user data'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('User data not available'));
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>?;
            final userName = userData?['name'] ?? 'Admin';

            return ListView.builder(
              itemCount: profileOptions.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: _profileImageUrl != null
                                  ? NetworkImage(_profileImageUrl!)
                                  : const NetworkImage(
                                      'https://via.placeholder.com/150'),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              userName, // Display the logged-in user's name
                              style: GoogleFonts.raleway(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }

                final option = profileOptions[index - 1];

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: GestureDetector(
                    onTap: () {
                      if (option['title'] == 'Logout') {
                        _signOut();
                      } else {
                        // Handle other options here (e.g., navigation)
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      height: 75,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: const Color(0xFFBAE5F4).withOpacity(0.4),
                      ),
                      child: Center(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white.withOpacity(0.8),
                              child: Image.asset(option['icon'], height: 30),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              option['title'],
                              style: GoogleFonts.raleway(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
