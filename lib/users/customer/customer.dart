import 'dart:developer';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:major_project_1/users/customer/Pages/BookingPage.dart';
import 'package:major_project_1/users/customer/Pages/CategoryPage.dart';
import 'package:major_project_1/users/customer/Pages/HomePage.dart';
import 'package:major_project_1/users/customer/Pages/MessagePage.dart';
import 'package:major_project_1/users/customer/Pages/Profile.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  /// Controller to handle PageView and also handles initial page
  final _pageController = PageController(initialPage: 0);

  /// Controller to handle bottom nav bar and also handles initial page
  final NotchBottomBarController _controller =
      NotchBottomBarController(index: 0);

  int maxCount = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Widget list
    final List<Widget> bottomBarPages = [
      Homepage(),
      Categorypage(),
      BookingsPage(),
      SupportPage(),
      ProfilePage_User(),
    ];
    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                  bottomBarPages.length, (index) => bottomBarPages[index]),
            ),
          ),
          Container(
            alignment: Alignment.center, // Centering the bottom navigation
            padding: const EdgeInsets.only(bottom: 20), // Adjust as needed
            child: (bottomBarPages.length <= maxCount)
                ? AnimatedNotchBottomBar(
                    // Provide NotchBottomBarController
                    notchBottomBarController: _controller,
                    color: Color(0xFFBAE5F4),
                    showLabel: true,
                    textOverflow: TextOverflow.visible,
                    maxLine: 1,
                    shadowElevation: 5,
                    kBottomRadius: 28.0,

                    notchColor: Colors.black.withOpacity(0.8),

                    // restart app if you change removeMargins
                    removeMargins: false,
                    bottomBarWidth: 500,
                    showShadow: false,
                    durationInMilliSeconds: 300,

                    itemLabelStyle: GoogleFonts.raleway(
                        fontSize: 8, fontWeight: FontWeight.bold),

                    elevation: 1,
                    bottomBarItems: [
                      BottomBarItem(
                        inActiveItem: Image.asset(
                          'assets/home.png',
                          width: 24,
                          height: 24,
                        ),
                        activeItem: Image.asset(
                          'assets/home_active.png',
                          width: 24,
                          height: 24,
                        ),
                        itemLabel: 'Home',
                      ),
                      BottomBarItem(
                        inActiveItem: Image.asset(
                          'assets/categories.png',
                          width: 24,
                          height: 24,
                        ),
                        activeItem: Image.asset(
                          'assets/categories_active.png',
                          width: 24,
                          height: 24,
                        ),
                        itemLabel: 'Category',
                      ),
                      BottomBarItem(
                        inActiveItem: Image.asset(
                          'assets/appointment.png',
                          width: 24,
                          height: 24,
                        ),
                        activeItem: Image.asset(
                          'assets/appointment_active.png',
                          width: 24,
                          height: 24,
                        ),
                        itemLabel: 'Booking',
                      ),
                      BottomBarItem(
                        inActiveItem: Image.asset(
                          'assets/email.png',
                          width: 24,
                          height: 24,
                        ),
                        activeItem: Image.asset(
                          'assets/email_active.png',
                          width: 24,
                          height: 24,
                        ),
                        itemLabel: 'Message',
                      ),
                      BottomBarItem(
                        inActiveItem: Image.asset(
                          'assets/user.png',
                          width: 24,
                          height: 24,
                        ),
                        activeItem: Image.asset(
                          'assets/user_active.png',
                          width: 24,
                          height: 24,
                        ),
                        itemLabel: 'Profile',
                      ),
                    ],
                    onTap: (index) {
                      log('current selected index $index');
                      _pageController.jumpToPage(index);
                    },
                    kIconSize: 24.0,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

/*

{
showDialog(
context: context,
builder: (context) => CupertinoAlertDialog(
title: Text('Do You Want to Sign Out'),
actions: [
TextButton(
onPressed: () => Navigator.of(context).pop(),
child: Text('No'),
),
TextButton(
onPressed: () {
// Close the dialog before navigating
Navigator.of(context).pop();

// Replace the current screen with Login screen
Navigator.pushReplacement(
context,
MaterialPageRoute(builder: (context) => Login()),
);
},
child: Text('Yes'),
),
],
),
);
},*/
