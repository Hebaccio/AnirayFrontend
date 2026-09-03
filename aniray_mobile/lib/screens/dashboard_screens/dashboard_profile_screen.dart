import 'package:flutter/material.dart';

import '../../helpers/app_colors.dart';
import '../../providers/entity_providers/user_favorites.dart';
import '../../providers/entity_providers/user_provider.dart';
import '../../requests_and_models/auth_r&m/auth_result.dart';
import '../../requests_and_models/entity_r&m/user/user_models.dart';
import '../../widgets/profile/profile_favorites_widget.dart';
import '../../widgets/profile/profile_information_widget.dart';
import '../../widgets/profile/profile_orders_widget.dart';

// =============================================================================
// PROFILE SECTIONS
// =============================================================================

enum ProfileSection { info, orders, favorites }

// =============================================================================
// DASHBOARD PROFILE SCREEN
// =============================================================================

class DashboardProfileScreen extends StatefulWidget {
  const DashboardProfileScreen({super.key, this.title, this.onProfileSettings});

  final String? title;
  final VoidCallback? onProfileSettings;

  @override
  State<DashboardProfileScreen> createState() => _DashboardProfileScreenState();
}

class _DashboardProfileScreenState extends State<DashboardProfileScreen> {
  // ---------------------------------------------------------------------------
  // PROVIDERS
  // ---------------------------------------------------------------------------

  final UserProvider _userProvider = UserProvider();

  // ---------------------------------------------------------------------------
  // CHILD WIDGET KEYS
  // ---------------------------------------------------------------------------

  final GlobalKey<ProfileOrdersWidgetState> _ordersKey =
      GlobalKey<ProfileOrdersWidgetState>();

  final GlobalKey<ProfileFavoritesWidgetState> _favoritesKey =
      GlobalKey<ProfileFavoritesWidgetState>();

  // ---------------------------------------------------------------------------
  // SCROLL CONTROLLER
  // ---------------------------------------------------------------------------

  final ScrollController _profileScrollController = ScrollController();

  // ---------------------------------------------------------------------------
  // PROFILE DATA
  // ---------------------------------------------------------------------------

  UserMU? _user;

  // ---------------------------------------------------------------------------
  // LOADING / ERROR STATE
  // ---------------------------------------------------------------------------

  bool _isLoading = true;
  String? _errorMessage;

  // ---------------------------------------------------------------------------
  // SELECTED PROFILE SECTION
  // ---------------------------------------------------------------------------

  ProfileSection _selectedSection = ProfileSection.info;

  // ---------------------------------------------------------------------------
  // INIT STATE
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _profileScrollController.addListener(_onProfileScroll);

    _loadProfile();
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _profileScrollController.removeListener(_onProfileScroll);
    _profileScrollController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // LOAD PROFILE
  // ---------------------------------------------------------------------------

  Future<void> _loadProfile() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final token = AuthResult.accessToken;

    if (token == null) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to identify the current user.';
      });

      return;
    }

    try {
      final result = await _userProvider.entityGetByIdForUsers(null);

      if (!mounted) {
        return;
      }

      if (result.data != null) {
        setState(() {
          _user = result.data;
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result.message ?? 'Unable to load your profile.';
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load your profile.';
      });
    }
  }

  // ---------------------------------------------------------------------------
  // REFRESH ALL PROFILE DATA
  // ---------------------------------------------------------------------------

  Future<void> _refreshProfile() async {
    await Future.wait([
      _loadProfile(),
      _favoritesKey.currentState?.refresh() ?? Future.value(),
      _ordersKey.currentState?.refresh() ?? Future.value(),
    ]);
  }

  // ---------------------------------------------------------------------------
  // PROFILE SCROLL
  // ---------------------------------------------------------------------------

  void _onProfileScroll() {
    if (!_profileScrollController.hasClients) {
      return;
    }

    final position = _profileScrollController.position;

    // Start loading the next page before the user actually reaches
    // the bottom of the profile.
    if (position.pixels >= position.maxScrollExtent - 500) {
      switch (_selectedSection) {
        case ProfileSection.info:
          break;

        case ProfileSection.orders:
          if (_ordersKey.currentState?.hasMore ?? false) {
            _ordersKey.currentState?.loadMore();
          }
          break;

        case ProfileSection.favorites:
          if (_favoritesKey.currentState?.hasMore ?? false) {
            _favoritesKey.currentState?.loadMore();
          }
          break;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // NAVIGATION
  // ---------------------------------------------------------------------------

  void _openProfileSettings() {
    widget.onProfileSettings?.call();
  }

  // ---------------------------------------------------------------------------
  // CHANGE PROFILE SECTION
  // ---------------------------------------------------------------------------

  void _selectSection(ProfileSection section) {
    if (_selectedSection == section) {
      return;
    }

    setState(() {
      _selectedSection = section;
    });

    // Return to the top whenever the user changes profile sections.
    if (_profileScrollController.hasClients) {
      _profileScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(child: _buildBody()),
    );
  }

  // ---------------------------------------------------------------------------
  // BODY
  // ---------------------------------------------------------------------------

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_user == null) {
      return _buildErrorState(message: 'No profile information was found.');
    }

    return RefreshIndicator(
      onRefresh: _refreshProfile,
      child: SingleChildScrollView(
        controller: _profileScrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),

            const SizedBox(height: 24),

            _buildProfileSectionNavigation(),

            const SizedBox(height: 20),

            _buildProfileContent(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    final user = _user!;

    return Stack(
      children: [
        Center(
          child: Column(
            children: [
              const SizedBox(height: 10),

              _buildProfilePicture(user),

              const SizedBox(height: 16),

              Text(
                '${user.name} ${user.lastName}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                '@${user.username}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary.withOpacity(0.65),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),

        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            onPressed: _openProfileSettings,
            tooltip: 'Profile Settings',
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textPrimary,
              size: 24,
            ),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PROFILE PICTURE
  // ---------------------------------------------------------------------------

  Widget _buildProfilePicture(UserMU user) {
    final hasImage = user.pfp.trim().isNotEmpty;

    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.backgroundSecondary,
        border: Border.all(color: AppColors.backgroundTertiary, width: 3),
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(
                user.pfp,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar(user);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
              )
            : _buildDefaultAvatar(user),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DEFAULT AVATAR
  // ---------------------------------------------------------------------------

  Widget _buildDefaultAvatar(UserMU user) {
    final firstLetter = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    return Center(
      child: Text(
        firstLetter,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 42,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION NAVIGATION
  // ---------------------------------------------------------------------------

  Widget _buildProfileSectionNavigation() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
      child: Row(
        children: [
          _buildSectionButton(
            label: 'Info',
            section: ProfileSection.info,
            icon: Icons.person_outline,
          ),
          _buildSectionButton(
            label: 'Orders',
            section: ProfileSection.orders,
            icon: Icons.shopping_bag_outlined,
          ),
          _buildSectionButton(
            label: 'Favorites',
            section: ProfileSection.favorites,
            icon: Icons.favorite_border,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION BUTTON
  // ---------------------------------------------------------------------------

  Widget _buildSectionButton({
    required String label,
    required ProfileSection section,
    required IconData icon,
  }) {
    final isSelected = _selectedSection == section;

    return Expanded(
      child: GestureDetector(
        onTap: () => _selectSection(section),
        child: AnimatedContainer(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.backgroundTertiary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: AppColors.textPrimary.withOpacity(
                  isSelected ? 1.0 : 0.6,
                ),
              ),

              const SizedBox(width: 6),

              Text(
                label,
                style: TextStyle(
                  color: AppColors.textPrimary.withOpacity(
                    isSelected ? 1.0 : 0.6,
                  ),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PROFILE CONTENT
  // ---------------------------------------------------------------------------

  Widget _buildProfileContent() {
    switch (_selectedSection) {
      case ProfileSection.info:
        return ProfileInformationWidget(user: _user!);

      case ProfileSection.orders:
        return ProfileOrdersWidget(key: _ordersKey);

      case ProfileSection.favorites:
        return ProfileFavoritesWidget(key: _favoritesKey);
    }
  }

  // ---------------------------------------------------------------------------
  // ERROR STATE
  // ---------------------------------------------------------------------------

  Widget _buildErrorState({String? message}) {
    final error = message ?? _errorMessage ?? 'Something went wrong.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 54,
              color: AppColors.textPrimary.withOpacity(0.5),
            ),

            const SizedBox(height: 18),

            const Text(
              'Unable to load profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary.withOpacity(0.65),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 22),

            ElevatedButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundTertiary,
                foregroundColor: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
