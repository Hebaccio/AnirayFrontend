import 'package:flutter/material.dart';

import '../helpers/app_colors.dart';
import '../requests_and_models/entity_r&m/bluray/bluray_models.dart';
import '../requests_and_models/entity_r&m/movie/movie_models.dart';
import '../screens/dashboard_screens/dashboard_cart_screen.dart';
import '../screens/dashboard_screens/dashboard_home_screen.dart';
import '../screens/dashboard_screens/dashboard_profile_screen.dart';
import '../screens/dashboard_screens/dashboard_requests_screen.dart';
import '../screens/dashboard_screens/dashboard_search_screen.dart';
import '../screens/other_screens/bluray_screen.dart';
import '../screens/other_screens/movie_screen.dart';
import '../screens/other_screens/profile_settings_screen.dart';

class MainNavbarWidget extends StatefulWidget {
  const MainNavbarWidget({super.key});

  @override
  State<MainNavbarWidget> createState() => _MainNavbarWidgetState();
}

class _MainNavbarWidgetState extends State<MainNavbarWidget> {
  // ---------------------------------------------------------------------------
  // NAVIGATION
  // ---------------------------------------------------------------------------

  int _selectedIndex = 0;

  final List<Widget> _detailsPages = [];

  // ---------------------------------------------------------------------------
  // MAIN PAGES
  // ---------------------------------------------------------------------------

  List<Widget> get _pages => [
    const DashboardHomeScreen(title: "Home"),

    DashboardSearchScreen(title: "Search", onMovieSelected: openMovie),

    const DashboardCartScreen(title: "Cart"),

    const DashboardRequestsScreen(title: "Requests"),

    DashboardProfileScreen(
      title: "Profile",
      onProfileSettings: openProfileSettings,
    ),
  ];

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08111F),
      body: _detailsPages.isNotEmpty
          ? _detailsPages.last
          : _pages[_selectedIndex],
      bottomNavigationBar: _buildNavbar(),
    );
  }

  // ---------------------------------------------------------------------------
  // OPEN PROFILE SETTINGS
  // ---------------------------------------------------------------------------

  void openProfileSettings() {
    setState(() {
      _detailsPages.add(
        ProfileSettingsScreen(
          title: "ProfileSettings",
          onBack: _closeDetailsPage,
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // OPEN MOVIE
  // ---------------------------------------------------------------------------

  void openMovie(MovieMU movie) {
    setState(() {
      _detailsPages.add(
        MovieScreen(
          title: movie.title,
          movieId: movie.id,
          onBack: _closeDetailsPage,
          onBluRaySelected: openBluRay,
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // OPEN BLU-RAY
  // ---------------------------------------------------------------------------

  void openBluRay(BluRayMU bluRay) {
    setState(() {
      _detailsPages.add(
        BluRayScreen(
          title: bluRay.title,
          blurayId: bluRay.id,
          onBack: _closeDetailsPage,
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // CLOSE CURRENT DETAIL PAGE
  // ---------------------------------------------------------------------------
  //
  // Removes ONLY the current detail page.
  //
  // Example:
  //
  // [MovieScreen, BluRayScreen]
  //
  // Back ->
  //
  // [MovieScreen]
  //
  // Therefore MovieScreen becomes visible again.
  // ---------------------------------------------------------------------------

  void _closeDetailsPage() {
    if (_detailsPages.isEmpty) {
      return;
    }

    setState(() {
      _detailsPages.removeLast();
    });
  }

  // ---------------------------------------------------------------------------
  // NAVBAR
  // ---------------------------------------------------------------------------

  Widget _buildNavbar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundFourth,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            children: [
              _navButton(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                text: "Home",
                index: 0,
              ),

              _navButton(
                icon: Icons.search_outlined,
                selectedIcon: Icons.search,
                text: "Search",
                index: 1,
              ),

              _navButton(
                icon: Icons.shopping_bag_outlined,
                selectedIcon: Icons.shopping_bag,
                text: "Cart",
                index: 2,
              ),

              _navButton(
                icon: Icons.description_outlined,
                selectedIcon: Icons.description,
                text: "Requests",
                index: 3,
              ),

              _navButton(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                text: "Profile",
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // NAVBAR BUTTON
  // ---------------------------------------------------------------------------

  Widget _navButton({
    required IconData icon,
    required IconData selectedIcon,
    required String text,
    required int index,
  }) {
    final bool isSelected = _detailsPages.isEmpty && _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;

            // When switching main navigation tabs, clear all detail pages.
            _detailsPages.clear();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                size: 25,
              ),

              const SizedBox(height: 4),

              Text(
                text,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
