import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'BookServicePage.dart';

class Categorypage extends StatefulWidget {
  const Categorypage({super.key});

  @override
  State<Categorypage> createState() => _CategorypageState();
}

class _CategorypageState extends State<Categorypage> with TickerProviderStateMixin {
  bool isGridView = true;

  // Fetch categories from Firestore including the route and sub-services
  Stream<List<Category>> fetchCategories() {
    return FirebaseFirestore.instance.collection('services').snapshots().asyncMap(
          (QuerySnapshot snapshot) async {
        List<Category> categories = [];

        for (var doc in snapshot.docs) {
          final subServicesSnapshot = await FirebaseFirestore.instance
              .collection('sub-services')
              .where('category', isEqualTo: doc['category'])
              .get();

          List<SubService> subServices = subServicesSnapshot.docs.map((subDoc) {
            String name = subDoc['sub-serviceName'] ?? 'Unknown Service';
            double price =
                double.tryParse(subDoc['price']?.toString() ?? '0.0') ?? 0.0;
            String imageUrl = subDoc['imageUrl'] ??
                'https://example.com/default-image.png';

            return SubService(
              name: name,
              price: price,
              imageUrl: imageUrl,
            );
          }).toList();

          categories.add(Category(
            name: doc['category'] ?? 'Unknown Category',
            imagePath: doc['imageUrl'] ??
                'https://example.com/default-category-image.png',
            route: doc['route'] ?? '',
            subServices: subServices,
          ));
        }

        categories.sort((a, b) => a.name.compareTo(b.name));

        return categories;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Categories',
          style: GoogleFonts.raleway(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Category>>(
        stream: fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}',style: GoogleFonts.raleway()));
          }
          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            // Display message if there are no categories
            return Center(
              child: Text(
                'No categories available at the moment.',
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: isGridView
                ? _buildGridView(categories)
                : _buildListView(categories),
          );
        },
      ),
    );
  }

  Widget _buildGridView(List<Category> categories) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          final AnimationController animationController = AnimationController(
            duration: const Duration(milliseconds: 1000),
            vsync: this,
          )..forward();

          return AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(index.isEven ? -1 : 1, 0),
                  end: Offset(0, 0),
                ).animate(
                  CurvedAnimation(
                    parent: animationController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: child,
              );
            },
            child: GestureDetector(
              child: Card(
                margin: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(category.imagePath, width: 50, height: 50),
                    SizedBox(height: 8.0),
                    Text(category.name,
                        style: GoogleFonts.raleway(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubCategoryPage(
                      categoryName: category.name,
                      subServices: category.subServices,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildListView(List<Category> categories) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          final AnimationController animationController = AnimationController(
            duration: Duration(
                milliseconds: 500 + index * 100),
            vsync: this,
          )..forward();

          return AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(1, 0),
                  end: Offset(0, 0),
                ).animate(
                  CurvedAnimation(
                    parent: animationController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: child,
              );
            },
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: Image.network(category.imagePath, width: 50, height: 50),
                title: Text(category.name,
                    style: GoogleFonts.raleway(
                        fontSize: 12, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubCategoryPage(
                        categoryName: category.name,
                        subServices: category.subServices,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class SubCategoryPage extends StatelessWidget {
  final String categoryName;
  final List<SubService> subServices;

  const SubCategoryPage({
    Key? key,
    required this.categoryName,
    required this.subServices,
  }) : super(key: key);

  // Stream to listen for real-time updates of sub-services for the selected category
  Stream<List<SubService>> fetchSubServices() {
    return FirebaseFirestore.instance
        .collection('sub-services')
        .where('category', isEqualTo: categoryName)
        .snapshots()
        .map((QuerySnapshot snapshot) {
      return snapshot.docs.map((subDoc) {
        String name = subDoc['sub-serviceName'] ?? 'Unknown Service';
        double price = double.tryParse(subDoc['price']?.toString() ?? '0.0') ?? 0.0;
        String imageUrl = subDoc['imageUrl'] ?? 'https://example.com/default-image.png';
        return SubService(
          name: name,
          price: price,
          imageUrl: imageUrl,
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: StreamBuilder<List<SubService>>(
        stream: fetchSubServices(), // Listen for real-time updates
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final subServices = snapshot.data ?? [];

          if (subServices.isEmpty) {
            // Display message if there are no sub-services
            return Center(
              child: Text(
                'No sub-services available for this category',
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          // Build the sub-services list if available
          return ListView.builder(
            itemCount: subServices.length,
            itemBuilder: (context, index) {
              final subService = subServices[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(15),
                    color: const Color(0xFFBAE5F4).withOpacity(0.4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        child: Image.network(
                          subService.imageUrl,
                          width: double.infinity,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.image_not_supported, color: Colors.blue, size: 50),
                            );
                          },
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                subService.name,
                                style: GoogleFonts.raleway(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '₹${subService.price.toStringAsFixed(2)}',
                                style: GoogleFonts.raleway(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookServicePage(
                                        selectedCategory: categoryName,
                                        selectedSubCategory: subService.name,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                child: Text(
                                  'Book',
                                  style: GoogleFonts.raleway(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Category {
  final String name;
  final String imagePath;
  final String route;
  final List<SubService> subServices;

  Category({
    required this.name,
    required this.imagePath,
    required this.route,
    required this.subServices,
  });
}

class SubService {
  final String name;
  final double price;
  final String imageUrl;

  SubService({
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}
