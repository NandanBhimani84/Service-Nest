import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:major_project_1/auth/signin.dart';
import 'package:major_project_1/firebase_options.dart';
import 'package:major_project_1/users/admin/admin.dart';
import 'package:major_project_1/users/admin/feature/add/add_service.dart';
import 'package:major_project_1/users/admin/feature/add/add_technician.dart';
import 'package:major_project_1/users/admin/feature/manage/manage_service.dart';
import 'package:major_project_1/users/admin/feature/manage/manage_technician.dart';
import 'package:major_project_1/users/admin/feature/manage/manage_user.dart';
import 'package:major_project_1/users/customer/Pages/Profile/AddressPage.dart';
import 'package:major_project_1/users/customer/Pages/Profile/ChangePasswordPage.dart';
import 'package:major_project_1/users/customer/Pages/Profile/Privacy_PolicyPage.dart';
import 'package:major_project_1/users/customer/Pages/Profile/Terms&ConditionsPage.dart';
import 'package:major_project_1/users/customer/customer.dart';
import 'package:major_project_1/users/technician/technician.dart';
import 'auth/OnBoarding/SplashPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthCheck(), // Check auth state and navigate accordingly
      routes: {
        '/manageTechnician': (context) => manageTechnician(),
        '/manageUser': (context) => manageUser(),
        '/addTechnician': (context) => addTechnician(),
        '/addService': (context) => addService(),
        '/manageService': (context) => manageService(),
        //'/appliancepage': (context) => Appliancepage(),
        '/login': (context) => Signin(),
        '/addressPage': (context) => Addresspage(),
        '/privacyPolicy': (context) => PrivacyPolicyPage(),
        '/terms': (context) => Terms_conditionsPage(),
        '/changePassword': (context) => Changepasswordpage(),
      },
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (userSnapshot.hasData) {
                var role = userSnapshot.data?['role'] ?? 'admin';
                if (role == 'admin') {
                  return BottomNavigation_Admin();
                } else if (role == 'customer') {
                  return BottomNavigation();
                } else if (role == 'technician') {
                  return BottomNavigation_Technician();
                }
              }
              return SplashScreen();
            },
          );
        } else {
          return SplashScreen();
        }
      },
    );
  }
}
