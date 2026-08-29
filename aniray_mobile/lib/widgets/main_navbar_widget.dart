import 'package:flutter/material.dart';
import '../helpers/app_colors.dart';
import '../providers/auth_provider/auth_provider.dart';
import '../requests_and_models/auth_r&m/auth_result.dart';
import '../screens/auth_screens/login_screen.dart';
import '../screens/dashboard_screens/dashboard_cart_screen.dart';
import '../screens/dashboard_screens/dashboard_home_screen.dart';
import '../screens/dashboard_screens/dashboard_profile_screen.dart';
import '../screens/dashboard_screens/dashboard_requests_screen.dart';
import '../screens/dashboard_screens/dashboard_search_screen.dart';

class MainNavbarWidget extends StatefulWidget {
  const MainNavbarWidget({super.key});

  @override
  State<MainNavbarWidget> createState() => _MainNavbarWidgetState();
}

class _MainNavbarWidgetState extends State<MainNavbarWidget> {
  int _selectedIndex = 0;

  bool _isLoggingOut = false;

  // ---------------------------------------------------------------------------
  // PAGES
  // ---------------------------------------------------------------------------

  List<Widget> get _pages => [
    const DashboardHomeScreen(title: "Home"),

    const DashboardSearchScreen(title: "Search"),

    const DashboardCartScreen(title: "Cart"),

    const DashboardRequestsScreen(title: "Requests"),

    const DashboardProfileScreen(title: "Profile"),
  ];

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08111F),

      body: IndexedStack(index: _selectedIndex, children: _pages),

      bottomNavigationBar: _buildNavbar(),
    );
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
  // NAV BUTTON
  // ---------------------------------------------------------------------------

  Widget _navButton({
    required IconData icon,
    required IconData selectedIcon,
    required String text,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (_selectedIndex == index) {
            return;
          }

          setState(() {
            _selectedIndex = index;
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
      // Even if backend logout fails, local authentication
      // state is still cleared.
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
}
