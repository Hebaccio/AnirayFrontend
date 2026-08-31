import 'package:flutter/material.dart';
import '../../helpers/app_colors.dart';
import '../../providers/entity_providers/user_provider.dart';
import '../../requests_and_models/auth_r&m/auth_result.dart';
import '../../requests_and_models/entity_r&m/user/user_models.dart';

class DashboardProfileScreen extends StatefulWidget {
  const DashboardProfileScreen({super.key, this.title, this.onProfileSettings});

  final String? title;
  final VoidCallback? onProfileSettings;

  @override
  State<DashboardProfileScreen> createState() => _DashboardProfileScreenState();
}

class _DashboardProfileScreenState extends State<DashboardProfileScreen> {
  final UserProvider _userProvider = UserProvider();

  UserMU? _user;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
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
  // NAVIGATION
  // ---------------------------------------------------------------------------

  void _openProfileSettings() {
    widget.onProfileSettings?.call();
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
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
            const SizedBox(height: 28),
            _buildPersonalInformationCard(),
            const SizedBox(height: 16),
            _buildAccountInformationCard(),
            const SizedBox(height: 24),
            _buildSettingsButton(),
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

    return Column(
      children: [
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
    );
  }

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
  // PERSONAL INFORMATION
  // ---------------------------------------------------------------------------

  Widget _buildPersonalInformationCard() {
    final user = _user!;

    return _buildSectionCard(
      title: 'Personal Information',
      icon: Icons.person_outline,
      children: [
        _buildInfoRow(
          icon: Icons.badge_outlined,
          label: 'Full Name',
          value: '${user.name} ${user.lastName}',
        ),
        _buildDivider(),
        _buildInfoRow(
          icon: Icons.alternate_email,
          label: 'Username',
          value: user.username,
        ),
        _buildDivider(),
        _buildInfoRow(
          icon: Icons.email_outlined,
          label: 'Email',
          value: user.email,
        ),
        _buildDivider(),
        _buildInfoRow(
          icon: Icons.cake_outlined,
          label: 'Birthday',
          value: _formatDate(user.birthday),
        ),
        _buildDivider(),
        _buildInfoRow(
          icon: Icons.wc_outlined,
          label: 'Gender',
          value: user.gender.name,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // ACCOUNT INFORMATION
  // ---------------------------------------------------------------------------

  Widget _buildAccountInformationCard() {
    final user = _user!;

    return _buildSectionCard(
      title: 'Account Information',
      icon: Icons.manage_accounts_outlined,
      children: [
        _buildInfoRow(
          icon: Icons.admin_panel_settings_outlined,
          label: 'Role',
          value: user.userRole.name,
        ),
        _buildDivider(),
        _buildInfoRow(
          icon: Icons.verified_user_outlined,
          label: 'Status',
          value: user.userStatus.name,
        ),
        _buildDivider(),
        _buildInfoRow(
          icon: Icons.calendar_today_outlined,
          label: 'Member Since',
          value: _formatDateTime(user.createdAt),
        ),
        _buildDivider(),
        _buildInfoRow(
          icon: Icons.security_outlined,
          label: 'Two-Factor Authentication',
          value: user.twoFA ? 'Enabled' : 'Disabled',
          valueWidget: _buildTwoFAStatus(user.twoFA),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SETTINGS BUTTON
  // ---------------------------------------------------------------------------

  Widget _buildSettingsButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _openProfileSettings,
        icon: const Icon(Icons.settings_outlined, size: 21),
        label: const Text(
          'Profile Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.backgroundTertiary,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION CARD
  // ---------------------------------------------------------------------------

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 21),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INFORMATION ROW
  // ---------------------------------------------------------------------------

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? valueWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.textPrimary.withOpacity(0.55), size: 20),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textPrimary.withOpacity(0.55),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                valueWidget ??
                    Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TWO FACTOR STATUS
  // ---------------------------------------------------------------------------

  Widget _buildTwoFAStatus(bool enabled) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: enabled
                ? Colors.green.withOpacity(0.15)
                : Colors.red.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            enabled ? 'Enabled' : 'Disabled',
            style: TextStyle(
              color: enabled ? Colors.greenAccent : Colors.redAccent,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.backgroundTertiary.withOpacity(0.35),
    );
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

// =============================================================================
// TEMPORARY IMPORT TARGET
// =============================================================================
//
// Keep this import/implementation exactly as your project requires.
//
// If ProfileSettingsScreen already exists in your project, replace the
// import below with its actual path.
//
// =============================================================================
