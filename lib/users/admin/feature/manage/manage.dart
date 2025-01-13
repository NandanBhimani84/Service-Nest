import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:major_project_1/users/admin/feature/manage/manage_service.dart';
import 'package:major_project_1/users/admin/feature/manage/manage_technician.dart';
import 'package:major_project_1/users/admin/feature/manage/manage_user.dart';


class Manage extends StatefulWidget {
  const Manage({super.key});

  @override
  State<Manage> createState() => _ManageState();
}

class _ManageState extends State<Manage> with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          forceMaterialTransparency: true,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal:  8.0),
            child: Text(
              'Manage',
              style: GoogleFonts.raleway(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          titleSpacing: 0.0, // Fix the spacing
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: const Color(0xFFBAE5F4),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black54,
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Customer'),
                    Tab(text: 'Technician'),
                    Tab(text: 'Service'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            manageUser(),        // Tab 1 content
            manageTechnician(),  // Tab 2 content
            manageService(),     // Tab 3 content
          ],
        ),
      ),
    );
  }
}
