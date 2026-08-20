import 'package:aniray_desktop/models/movie/movie_models.dart';
import 'package:aniray_desktop/providers/auth_provider.dart';
import 'package:aniray_desktop/requests/auth_requests/auth_result.dart';
import 'package:aniray_desktop/screens/auth_screens/login_screen.dart';
import 'package:aniray_desktop/screens/dashboard_screens/dashboard_inventory.dart';
import 'package:aniray_desktop/screens/dashboard_screens/dashboard_orders.dart';
import 'package:aniray_desktop/screens/dashboard_screens/dashboard_requests.dart';
import 'package:aniray_desktop/screens/dashboard_screens/dashboard_users.dart';
import 'package:aniray_desktop/screens/other_screens/movie_details_screen.dart';
import 'package:aniray_desktop/screens/other_screens/movie_edit_screen.dart';
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

  bool _isLoggingOut = false;

  // ---------------------------------------------------------------------------
  // PAGES
  // ---------------------------------------------------------------------------

  List<Widget> get _pages => [
    const DashboardOrdersScreen(title: "Orders"),

    DashboardInventoryScreen(
      title: "Inventory",
      onMovieSelected: openMovieDetails,
      onAddMovie: openAddMovie,
    ),

    DashboardRequestsScreen(
      title: "Requests",
      onRequestSelected: openRequestDetails,
    ),

    const DashboardUsersScreen(title: "Users"),
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
  // OPEN MOVIE DETAILS
  // ---------------------------------------------------------------------------

  void openMovieDetails(MovieME movie) {
    setState(() {
      _detailsPage = MovieDetailsScreen(
        movie: movie,
        onBack: _closeDetailsPage,
        onEditMovie: () => openEditMovie(movie.id),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // OPEN ADD MOVIE
  // ---------------------------------------------------------------------------

  void openAddMovie() {
    setState(() {
      _detailsPage = MovieEditScreen(movieId: null, onBack: _closeDetailsPage);
    });
  }

  // ---------------------------------------------------------------------------
  // OPEN REQUEST DETAILS
  // ---------------------------------------------------------------------------

  void openRequestDetails(int requestId) {
    setState(() {
      _detailsPage = RequestDetailsScreen(
        requestId: requestId,
        onBack: _closeDetailsPage,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // CLOSE DETAILS / EDIT PAGE
  // ---------------------------------------------------------------------------

  void _closeDetailsPage() {
    setState(() {
      _detailsPage = null;
    });
  }

  // ---------------------------------------------------------------------------
  // OPEN EDIT MOVIE
  // ---------------------------------------------------------------------------

  void openEditMovie(int movieId) {
    setState(() {
      _detailsPage = MovieEditScreen(
        movieId: movieId,
        onBack: _closeDetailsPage,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------

  Future<void> _logout() async {
    if (_isLoggingOut) {
      return;
    }

    setState(() {
      _isLoggingOut = true;
    });

    try {
      final AuthProvider authProvider = AuthProvider();

      await authProvider.logout();
    } catch (_) {
      // Even if the backend logout fails, we still clear the local
      // authentication state and return the user to the login screen.
    } finally {
      AuthResult.clear();
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(title: "Login"),
      ),
      (route) => false,
    );
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

          _logoutButton(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LOGOUT BUTTON
  // ---------------------------------------------------------------------------

  Widget _logoutButton() {
    return InkWell(
      onTap: _isLoggingOut ? null : _logout,
      child: Container(
        width: double.infinity,
        height: 70,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isLoggingOut
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.logout, color: Colors.white),

            const SizedBox(height: 4),

            const Text(
              "Logout",
              style: TextStyle(color: AppColors.textPrimary, fontSize: 11),
            ),
          ],
        ),
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
