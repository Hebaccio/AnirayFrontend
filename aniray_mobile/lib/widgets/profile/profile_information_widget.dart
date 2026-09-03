import 'package:flutter/material.dart';
import '../../helpers/app_colors.dart';
import '../../requests_and_models/entity_r&m/user/user_models.dart';

class ProfileInformationWidget extends StatelessWidget {
  const ProfileInformationWidget({super.key, required this.user});

  final UserMU user;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPersonalInformationCard(),
        const SizedBox(height: 16),
        _buildAccountInformationCard(),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PERSONAL INFORMATION
  // ---------------------------------------------------------------------------

  Widget _buildPersonalInformationCard() {
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

  // ---------------------------------------------------------------------------
  // DIVIDER
  // ---------------------------------------------------------------------------

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.backgroundTertiary.withOpacity(0.35),
    );
  }
}
