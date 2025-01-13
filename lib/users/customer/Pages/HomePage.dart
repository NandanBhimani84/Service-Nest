import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'CategoryPage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final List<Category> categories = [
    Category(name: 'Appliance', imagePath: 'assets/electric-appliance.png'),
    Category(name: 'Beauty', imagePath: 'assets/hairstyle.png'),
    Category(name: 'Painting', imagePath: 'assets/paint-roll.png'),
    Category(name: 'Cleaning', imagePath: 'assets/products.png'),
    Category(name: 'Plumbing', imagePath: 'assets/plumber.png'),
    Category(name: 'Electronics', imagePath: 'assets/electric-appliance.png'),
  ];

  final List<Service> services = [
    Service(
      title: 'Carpet Cleaning',
      price: '\$150',
      oldPrice: '\$180',
      provider: 'Mark Willions',
      rating: 4.5,
      imageUrl: 'assets/item/carpet_cleaning.jpeg',
    ),
    Service(
      title: 'Living Room Cleaning',
      price: '\$200',
      oldPrice: '225',
      provider: 'Ronald Mark',
      rating: 4.8,
      imageUrl: 'assets/item/house_cleaning.jpeg',
    ),
    Service(
      title: 'Hair Cut',
      price: '\$80',
      oldPrice: '\$100',
      provider: 'Ronald Mark',
      rating: 4.0,
      imageUrl: 'assets/item/haircut.jpeg',
    ),
    Service(
      title: 'AC Service',
      price: '\$50',
      oldPrice: '75',
      provider: 'Ronald Mark',
      rating: 3.5,
      imageUrl: 'assets/item/ac_service.jpeg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [Image.asset('assets/logo.png', height: 35,),
              Text(
                "ervice Nest",
                style: GoogleFonts.raleway(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),],),
            // User's name aligned to the right
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                    "Loading...",
                    style: GoogleFonts.raleway(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    !snapshot.data!.exists) {
                  return Text(
                    "User",
                    style: GoogleFonts.raleway(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>?;
                final userName = userData?['name'] ?? 'User';

                return Text(
                  "Hello, $userName!",
                  style: GoogleFonts.raleway(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              _buildCategories(),
              _buildBestServices(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userName() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading...",
                style: GoogleFonts.raleway(
                    fontSize: 18, fontWeight: FontWeight.bold));
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return Text("User",
                style: GoogleFonts.raleway(
                    fontSize: 18, fontWeight: FontWeight.bold));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          final userName = userData?['name'] ?? 'User';

          return Text(
            "Hello, $userName!",
            style: GoogleFonts.raleway(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('All Categories',
                  style: GoogleFonts.raleway(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Categorypage()));
                },
                child: Text('See All',
                    style: GoogleFonts.raleway(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFBAE5F4))),
              ),
            ],
          ),
          SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemBuilder: (context, index) {
              final category = categories[index];
              return Column(
                children: [
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Color(0xFFBAE5F4).withOpacity(0.6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(category.imagePath),
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(category.name,
                      style: GoogleFonts.raleway(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBestServices() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Best Services',
              style: GoogleFonts.raleway(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Container(
            height: 200, // Adjust height as needed
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return _buildServiceItem(service);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(Service service) {
    return Container(
      width: 250,
      height: 300,
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Color(0xFFBAE5F4).withOpacity(0.6),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.asset(
              service.imageUrl,
              width: double.infinity,
              height: 100, // Adjust for better aspect ratio
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.title,
                    style: GoogleFonts.raleway(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                Text(service.price,
                    style: GoogleFonts.raleway(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      minimumSize: Size(35, 35),
                    ),
                    child: Text('Add',
                        style: GoogleFonts.raleway(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Category {
  final String name;
  final String imagePath;

  Category({required this.name, required this.imagePath});
}

class Service {
  final String title;
  final String price;
  final String oldPrice;
  final String provider;
  final double rating;
  final String imageUrl;

  Service({
    required this.title,
    required this.price,
    required this.oldPrice,
    required this.provider,
    required this.rating,
    required this.imageUrl,
  });
}
