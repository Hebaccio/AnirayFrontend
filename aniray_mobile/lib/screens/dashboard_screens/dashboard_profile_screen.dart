import 'package:flutter/material.dart';

import '../../helpers/app_colors.dart';
import '../../providers/entity_providers/user_favorites.dart';
import '../../providers/entity_providers/user_provider.dart';
import '../../requests_and_models/auth_r&m/auth_result.dart';
import '../../requests_and_models/entity_r&m/user/user_models.dart';
import '../../requests_and_models/entity_r&m/user_favorites/userfavorites_models.dart';
import '../../requests_and_models/helper_r&m/paged_result/paged_result.dart';
import '../../widgets/profile/profile_favorites_widget.dart';
import '../../widgets/profile/profile_information_widget.dart';

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
  final UserFavoriteProvider _userFavoriteProvider = UserFavoriteProvider();

  // ---------------------------------------------------------------------------
  // PROFILE DATA
  // ---------------------------------------------------------------------------

  UserMU? _user;

  // ---------------------------------------------------------------------------
  // FAVORITES DATA
  // ---------------------------------------------------------------------------

  PagedResult<UserFavoritesMU>? _favorites;

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

    _loadProfile();
    _loadFavorites();
  }

  // ---------------------------------------------------------------------------
  // LOAD PROFILE
  // ---------------------------------------------------------------------------

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final token = AuthResult.accessToken;

    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to identify the current user.';
      });

      return;
    }

    final result = await _userProvider.entityGetByIdForUsers(null);

    if (!mounted) {
      return;
    }

    if (result.data != null) {
      setState(() {
        _user = result.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result.message ?? 'Unable to load your profile.';
      });
    }
  }

  // ---------------------------------------------------------------------------
  // LOAD FAVORITES
  // ---------------------------------------------------------------------------

  Future<void> _loadFavorites() async {
    final token = AuthResult.accessToken;

    if (token == null) {
      return;
    }

    final result = await _userFavoriteProvider.getPagedEntityForUsers(
      const UserFavoritesSOU(page: 0, pageSize: 20),
    );

    if (!mounted) {
      return;
    }

    if (result.data != null) {
      setState(() {
        _favorites = result.data;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // NAVIGATION
  // ---------------------------------------------------------------------------

  void _openProfileSettings() {
    widget.onProfileSettings?.call();
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
      onRefresh: _loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),

            const SizedBox(height: 24),

            _buildProfileSectionNavigation(),

            const SizedBox(height: 20),

            // -----------------------------------------------------------------
            // PROFILE CONTENT
            // -----------------------------------------------------------------
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
        // -----------------------------------------------------------------------
        // PROFILE CONTENT
        // -----------------------------------------------------------------------
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

        // -----------------------------------------------------------------------
        // SETTINGS BUTTON
        // -----------------------------------------------------------------------
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
  // PROFILE SECTION NAVIGATION
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
  // PROFILE SECTION BUTTON
  // ---------------------------------------------------------------------------

  Widget _buildSectionButton({
    required String label,
    required ProfileSection section,
    required IconData icon,
  }) {
    final isSelected = _selectedSection == section;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedSection = section;
          });
        },
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

  Widget _buildProfileContent() {
    switch (_selectedSection) {
      case ProfileSection.info:
        return ProfileInformationWidget(user: _user!);
      case ProfileSection.orders:
        return const Center(
          child: Text(
            'Orders',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
          ),
        );
      case ProfileSection.favorites:
        return ProfileFavoritesWidget(favorites: _favorites);
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
