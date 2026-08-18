import 'package:aniray_desktop/models/movie/movie_models.dart';
import 'package:aniray_desktop/screens/dashboard_screens/dashboard_inventory.dart';
import 'package:aniray_desktop/screens/dashboard_screens/dashboard_orders.dart';
import 'package:aniray_desktop/screens/dashboard_screens/dashboard_profile.dart';
import 'package:aniray_desktop/screens/dashboard_screens/dashboard_requests.dart';
import 'package:aniray_desktop/screens/dashboard_screens/dashboard_users.dart';
import 'package:aniray_desktop/screens/other_screens/movie_details_screen.dart';
import 'package:aniray_desktop/screens/other_screens/request_details_screen.dart';
import 'package:aniray_desktop/theme/app_colors.dart';
import 'package:flutter/material.dart';

class MainSidebarWidget extends StatefulWidget {
  const MainSidebarWidget({super.key});

  @override
  State<MainSidebarWidget> createState() => _MainSidebarWidgetState();
}

class _MainSidebarWidgetState extends State<MainSidebarWidget> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
    const DashboardOrdersScreen(title: "Orders"),

    DashboardInventoryScreen(
      title: "Inventory",
      onMovieSelected: openMovieDetails,
    ),

    DashboardRequestsScreen(
      title: "Requests",
      onRequestSelected: openRequestDetails,
    ),

    const DashboardUsersScreen(title: "Users"),

    const DashboardProfileScreen(title: "Profile"),
  ];

  // ---------------------------------------------------------------------------
  // CURRENT CONTENT
  // ---------------------------------------------------------------------------

  Widget? _detailsPage;

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08111F),
      body: Row(
        children: [
          _buildSidebar(),

          Expanded(child: _detailsPage ?? _pages[_selectedIndex]),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // OPEN DETAILS
  // ---------------------------------------------------------------------------

  void openMovieDetails(MovieME movie) {
    setState(() {
      _detailsPage = MovieDetailsScreen(
        movie: movie,
        onBack: _closeDetailsPage,
      );
    });
  }

  void openRequestDetails(int requestId) {
    setState(() {
      _detailsPage = RequestDetailsScreen(
        requestId: requestId,
        onBack: _closeDetailsPage,
      );
    });
  }

  void _closeDetailsPage() {
    setState(() {
      _detailsPage = null;
    });
  }
  // ---------------------------------------------------------------------------
  // SIDEBAR
  // ---------------------------------------------------------------------------

  Widget _buildSidebar() {
    return Container(
      width: 80,
      color: AppColors.backgroundFourth,
      child: Column(
        children: [
          const SizedBox(height: 20),

          Image.asset(
            'assets/images/AniRay_Logo.png',
            width: 35,
            height: 35,
            fit: BoxFit.contain,
          ),

          const SizedBox(height: 30),

          _menuButton(
            icon: Icons.shopping_basket_outlined,
            text: "Orders",
            index: 0,
          ),

          _menuButton(
            icon: Icons.inventory_2_outlined,
            text: "Inventory",
            index: 1,
          ),

          _menuButton(
            icon: Icons.description_outlined,
            text: "Requests",
            index: 2,
          ),

          _menuButton(icon: Icons.people_alt_outlined, text: "Users", index: 3),

          const Spacer(),

          _menuButton(icon: Icons.person_3_rounded, text: "Profile", index: 4),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MENU BUTTON
  // ---------------------------------------------------------------------------

  Widget _menuButton({
    required IconData icon,
    required String text,
    required int index,
  }) {
    final bool isSelected = _detailsPage == null && _selectedIndex == index;

    return InkWell(
      onTap: () {
        if (index < _pages.length) {
          setState(() {
            _selectedIndex = index;
            _detailsPage = null;
          });
        }
      },
      child: Container(
        width: double.infinity,
        height: 70,
        color: isSelected
            ? Color.lerp(AppColors.backgroundPrimary, Colors.blue, 0.2)
            : Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),

            const SizedBox(height: 4),

            Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
