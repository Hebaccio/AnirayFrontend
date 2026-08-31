import 'dart:async';
import 'package:flutter/material.dart';
import '../../helpers/app_colors.dart';
import '../../providers/auth_provider/auth_provider.dart';
import '../../providers/entity_providers/gender_provider.dart';
import '../../providers/entity_providers/user_provider.dart';
import '../../requests_and_models/auth_r&m/auth_result.dart';
import '../../requests_and_models/entity_r&m/user/user_models.dart';
import '../../requests_and_models/helper_r&m/basic_entities/basic_entities.dart';
import '../auth_screens/login_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({
    super.key,
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  // ---------------------------------------------------------------------------
  // PROVIDERS
  // ---------------------------------------------------------------------------

  final UserProvider _userProvider = UserProvider();

  final GenderProvider _genderProvider = GenderProvider();

  // ---------------------------------------------------------------------------
  // CONTROLLERS
  // ---------------------------------------------------------------------------

  final TextEditingController _profilePictureController =
      TextEditingController();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _birthdayController = TextEditingController();

  final TextEditingController _currentPasswordController =
      TextEditingController();

  final TextEditingController _newPasswordController = TextEditingController();

  final TextEditingController _repeatNewPasswordController =
      TextEditingController();

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  UserMU? _user;

  bool _isLoadingProfile = true;

  bool _isLoadingGenders = true;

  String? _errorMessage;

  bool _isTwoFAEnabled = false;

  bool _isChangingTwoFA = false;

  bool _isSavingPersonalInformation = false;

  bool _isChangingPassword = false;

  bool _isDeletingAccount = false;

  bool _isLoggingOut = false;

  bool _obscureCurrentPassword = true;

  bool _obscureNewPassword = true;

  bool _obscureRepeatNewPassword = true;

  String? _selectedGender;

  // ---------------------------------------------------------------------------
  // GENDERS
  // ---------------------------------------------------------------------------

  List<BaseClassMU> _genders = [];

  // ---------------------------------------------------------------------------
  // PROFILE PICTURE PREVIEW
  // ---------------------------------------------------------------------------

  String _profilePicturePreviewUrl = '';

  Timer? _profilePictureDebounce;

  // ---------------------------------------------------------------------------
  // INIT
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _profilePictureController.addListener(_onProfilePictureChanged);

    _loadProfile();
    _loadGenders();
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _profilePictureDebounce?.cancel();

    _profilePictureController.removeListener(_onProfilePictureChanged);

    _profilePictureController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _repeatNewPasswordController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // LOAD PROFILE
  // ---------------------------------------------------------------------------

  Future<void> _loadProfile() async {
    if (mounted) {
      setState(() {
        _isLoadingProfile = true;
        _errorMessage = null;
      });
    }

    final userToken = AuthResult.accessToken;

    if (userToken == null || userToken.isEmpty) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingProfile = false;
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
        _user = result.data;

        _populateFields(result.data!);

        setState(() {
          _isLoadingProfile = false;
        });
      } else {
        setState(() {
          _isLoadingProfile = false;
          _errorMessage = result.message ?? 'Unable to load your profile.';
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingProfile = false;
        _errorMessage = 'Unable to load your profile.';
      });
    }
  }

  // ---------------------------------------------------------------------------
  // LOAD GENDERS
  // ---------------------------------------------------------------------------

  Future<void> _loadGenders() async {
    if (mounted) {
      setState(() {
        _isLoadingGenders = true;
      });
    }

    try {
      final result = await _genderProvider.getPagedEntityForUsers(
        BaseClassSOU(page: 0, pageSize: 100),
      );

      if (!mounted) {
        return;
      }

      if (result.data != null) {
        setState(() {
          _genders = result.data!.resultList;
          _isLoadingGenders = false;
        });

        _syncSelectedGenderWithBackend();
      } else {
        setState(() {
          _genders = [];
          _isLoadingGenders = false;
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _genders = [];
        _isLoadingGenders = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // POPULATE FORM
  // ---------------------------------------------------------------------------

  void _populateFields(UserMU user) {
    _profilePictureController.text = user.pfp;

    _profilePicturePreviewUrl = user.pfp;

    _nameController.text = user.name;

    _lastNameController.text = user.lastName;

    _usernameController.text = user.username;

    _emailController.text = user.email;

    _birthdayController.text = _formatDate(user.birthday);

    _selectedGender = user.gender.name;

    _isTwoFAEnabled = user.twoFA;
  }

  // ---------------------------------------------------------------------------
  // SYNC SELECTED GENDER
  // ---------------------------------------------------------------------------

  void _syncSelectedGenderWithBackend() {
    if (_user == null || _genders.isEmpty) {
      return;
    }

    final currentGenderName = _user!.gender.name;

    final matchingGender = _genders.where(
      (gender) => gender.name.toLowerCase() == currentGenderName.toLowerCase(),
    );

    if (matchingGender.isNotEmpty) {
      if (mounted) {
        setState(() {
          _selectedGender = matchingGender.first.name;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // GET GENDER ID FROM NAME
  // ---------------------------------------------------------------------------

  int? _getGenderIdFromName(String? genderName) {
    if (genderName == null || genderName.trim().isEmpty) {
      return null;
    }

    for (final gender in _genders) {
      if (gender.name.toLowerCase() == genderName.toLowerCase()) {
        return gender.id;
      }
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // PROFILE PICTURE URL CHANGED
  // ---------------------------------------------------------------------------

  void _onProfilePictureChanged() {
    _profilePictureDebounce?.cancel();

    _profilePictureDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _profilePicturePreviewUrl = _profilePictureController.text.trim();
      });
    });
  }

  // ---------------------------------------------------------------------------
  // DATE FORMAT
  // ---------------------------------------------------------------------------

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  // ---------------------------------------------------------------------------
  // DATE PICKER
  // ---------------------------------------------------------------------------

  Future<void> _selectBirthday() async {
    DateTime initialDate = DateTime(2000, 1, 1);

    final existingDate = _parseDate(_birthdayController.text);

    if (existingDate != null) {
      initialDate = existingDate;
    }

    final now = DateTime.now();

    if (initialDate.isAfter(now)) {
      initialDate = now;
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select your birthday',
      cancelText: 'Cancel',
      confirmText: 'Select',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.backgroundTertiary,
              surface: AppColors.backgroundSecondary,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.backgroundSecondary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    setState(() {
      _birthdayController.text = _formatDate(pickedDate);
    });
  }

  // ---------------------------------------------------------------------------
  // DATE PARSE
  // ---------------------------------------------------------------------------

  DateTime? _parseDate(String value) {
    final parts = value.trim().split('.');

    if (parts.length != 3) {
      return null;
    }

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return null;
    }

    try {
      final date = DateTime(year, month, day);

      if (date.year != year || date.month != month || date.day != day) {
        return null;
      }

      return date;
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: _isLoadingProfile
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? _buildErrorState()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildPersonalInformationSection(),

                          const SizedBox(height: 16),

                          _buildAccountInformationSection(),

                          const SizedBox(height: 16),

                          _buildSecuritySection(),

                          const SizedBox(height: 16),

                          _buildDangerZone(),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 20),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),

          const SizedBox(width: 4),

          const Expanded(
            child: Text(
              'Profile Settings',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PERSONAL INFORMATION
  // ---------------------------------------------------------------------------

  Widget _buildPersonalInformationSection() {
    return _buildSectionCard(
      title: 'Personal Information',
      icon: Icons.person_outline,
      children: [
        _buildProfilePicturePreview(),

        const SizedBox(height: 16),

        _buildTextField(
          controller: _profilePictureController,
          label: 'Profile Picture URL',
          hint: 'https://...',
          icon: Icons.image_outlined,
          keyboardType: TextInputType.url,
        ),

        const SizedBox(height: 14),

        _buildTextField(
          controller: _nameController,
          label: 'First Name',
          hint: 'Enter your first name',
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.name,
        ),

        const SizedBox(height: 14),

        _buildTextField(
          controller: _lastNameController,
          label: 'Last Name',
          hint: 'Enter your last name',
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.name,
        ),

        const SizedBox(height: 14),

        _buildTextField(
          controller: _usernameController,
          label: 'Username',
          hint: 'Enter your username',
          icon: Icons.alternate_email,
          keyboardType: TextInputType.text,
        ),

        const SizedBox(height: 14),

        _buildTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'Enter your email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 14),

        _buildBirthdayField(),

        const SizedBox(height: 14),

        _buildGenderDropdown(),

        const SizedBox(height: 20),

        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSavingPersonalInformation
                  ? null
                  : _savePersonalInformation,
              icon: _isSavingPersonalInformation
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textPrimary,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                _isSavingPersonalInformation
                    ? 'Saving...'
                    : 'Save Personal Information',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundTertiary,
                foregroundColor: AppColors.textPrimary,
                disabledBackgroundColor: AppColors.backgroundTertiary
                    .withOpacity(0.5),
                disabledForegroundColor: AppColors.textPrimary.withOpacity(0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PROFILE PICTURE PREVIEW
  // ---------------------------------------------------------------------------

  Widget _buildProfilePicturePreview() {
    final imageUrl = _profilePicturePreviewUrl.trim();

    return Center(
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          color: AppColors.backgroundPrimary,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.backgroundTertiary, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: imageUrl.isEmpty
            ? const Icon(Icons.person, color: AppColors.textSecondary, size: 60)
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person,
                    color: AppColors.textSecondary,
                    size: 60,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
              ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BIRTHDAY FIELD
  // ---------------------------------------------------------------------------

  Widget _buildBirthdayField() {
    return TextField(
      controller: _birthdayController,
      readOnly: true,
      onTap: _selectBirthday,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration:
          _inputDecoration(
            label: 'Birthday',
            hint: 'Select your birthday',
            icon: Icons.cake_outlined,
          ).copyWith(
            suffixIcon: const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.textSecondary,
            ),
          ),
    );
  }

  // ---------------------------------------------------------------------------
  // GENDER DROPDOWN
  // ---------------------------------------------------------------------------

  Widget _buildGenderDropdown() {
    if (_isLoadingGenders) {
      return InputDecorator(
        decoration: _inputDecoration(
          label: 'Gender',
          hint: 'Loading genders...',
          icon: Icons.wc_outlined,
        ),
        child: const SizedBox(
          height: 20,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }

    if (_genders.isEmpty) {
      return InputDecorator(
        decoration: _inputDecoration(
          label: 'Gender',
          hint: 'Unable to load genders',
          icon: Icons.wc_outlined,
        ),
        child: const Text(
          'No genders available',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
      );
    }

    final validSelectedGender =
        _genders.any(
          (gender) =>
              gender.name.toLowerCase() ==
              (_selectedGender ?? '').toLowerCase(),
        )
        ? _genders
              .firstWhere(
                (gender) =>
                    gender.name.toLowerCase() ==
                    (_selectedGender ?? '').toLowerCase(),
              )
              .name
        : null;

    return DropdownButtonFormField<String>(
      value: validSelectedGender,
      dropdownColor: AppColors.backgroundSecondary,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: _inputDecoration(
        label: 'Gender',
        hint: 'Select your gender',
        icon: Icons.wc_outlined,
      ),
      items: _genders.map((gender) {
        return DropdownMenuItem<String>(
          value: gender.name,
          child: Text(gender.name),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          _selectedGender = value;
        });
      },
    );
  }

  // ---------------------------------------------------------------------------
  // ACCOUNT INFORMATION
  // ---------------------------------------------------------------------------

  Widget _buildAccountInformationSection() {
    return _buildSectionCard(
      title: 'Account Security',
      icon: Icons.manage_accounts_outlined,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.backgroundPrimary.withOpacity(0.35),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.backgroundTertiary.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.security_outlined,
                  color: AppColors.textPrimary,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Two-Factor Authentication',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Add an additional layer of security to your account.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              if (_isChangingTwoFA)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Switch(value: _isTwoFAEnabled, onChanged: _onTwoFAChanged),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TWO FACTOR
  // ---------------------------------------------------------------------------

  Future<void> _onTwoFAChanged(bool value) async {
    if (_user == null || _isChangingTwoFA) {
      return;
    }

    final previousValue = _isTwoFAEnabled;

    setState(() {
      _isTwoFAEnabled = value;
      _isChangingTwoFA = true;
    });

    try {
      final request = UserURU(
        pfp: null,
        username: null,
        name: null,
        lastName: null,
        email: null,
        birthday: null,
        password: null,
        password2: null,
        twoFA: value,
        genderId: null,
      );

      final result = await _userProvider.updateEntityForUsers(null, request);

      if (!mounted) {
        return;
      }

      if (result.data != null) {
        _user = result.data;

        setState(() {
          _isTwoFAEnabled = result.data!.twoFA;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.data!.twoFA
                  ? 'Two-factor authentication enabled.'
                  : 'Two-factor authentication disabled.',
            ),
          ),
        );
      } else {
        setState(() {
          _isTwoFAEnabled = previousValue;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message ?? 'Unable to change two-factor authentication.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isTwoFAEnabled = previousValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to change two-factor authentication: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isChangingTwoFA = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // SECURITY
  // ---------------------------------------------------------------------------

  Widget _buildSecuritySection() {
    return _buildSectionCard(
      title: 'Security',
      icon: Icons.lock_outline,
      children: [
        _buildPasswordField(
          controller: _currentPasswordController,
          label: 'Current Password',
          obscureText: _obscureCurrentPassword,
          onToggleVisibility: () {
            setState(() {
              _obscureCurrentPassword = !_obscureCurrentPassword;
            });
          },
        ),

        const SizedBox(height: 14),

        _buildPasswordField(
          controller: _newPasswordController,
          label: 'New Password',
          obscureText: _obscureNewPassword,
          onToggleVisibility: () {
            setState(() {
              _obscureNewPassword = !_obscureNewPassword;
            });
          },
        ),

        const SizedBox(height: 14),

        _buildPasswordField(
          controller: _repeatNewPasswordController,
          label: 'Repeat New Password',
          obscureText: _obscureRepeatNewPassword,
          onToggleVisibility: () {
            setState(() {
              _obscureRepeatNewPassword = !_obscureRepeatNewPassword;
            });
          },
        ),

        const SizedBox(height: 20),

        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isChangingPassword ? null : _changePassword,
              icon: _isChangingPassword
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textPrimary,
                      ),
                    )
                  : const Icon(Icons.lock_reset_outlined),
              label: Text(
                _isChangingPassword ? 'Changing...' : 'Change Password',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundTertiary,
                foregroundColor: AppColors.textPrimary,
                disabledBackgroundColor: AppColors.backgroundTertiary
                    .withOpacity(0.5),
                disabledForegroundColor: AppColors.textPrimary.withOpacity(0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _forgotPassword,
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PASSWORD FIELD
  // ---------------------------------------------------------------------------

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration:
          _inputDecoration(
            label: label,
            hint: 'Enter $label',
            icon: Icons.lock_outline,
          ).copyWith(
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textSecondary,
              ),
            ),
          ),
    );
  }

  // ---------------------------------------------------------------------------
  // DANGER ZONE
  // ---------------------------------------------------------------------------

  Widget _buildDangerZone() {
    return _buildSectionCard(
      title: 'Account Actions',
      icon: Icons.warning_amber_outlined,
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _isDeletingAccount
                ? null
                : _showDeleteAccountConfirmation,
            icon: _isDeletingAccount
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.delete_outline, color: Colors.white),
            label: Text(
              _isDeletingAccount ? 'Deleting Account...' : 'Delete Account',
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.redAccent.withOpacity(0.7)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _isLoggingOut ? null : _showLogoutConfirmation,
            icon: _isLoggingOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textPrimary,
                    ),
                  )
                : const Icon(Icons.logout),
            label: Text(_isLoggingOut ? 'Logging Out...' : 'Log Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(color: AppColors.backgroundTertiary),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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

          const SizedBox(height: 16),

          ...children,
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TEXT FIELD
  // ---------------------------------------------------------------------------

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: _inputDecoration(label: label, hint: hint, icon: icon),
    );
  }

  // ---------------------------------------------------------------------------
  // INPUT DECORATION
  // ---------------------------------------------------------------------------

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: AppColors.textPrimary.withOpacity(0.65)),
      hintStyle: TextStyle(color: AppColors.textPrimary.withOpacity(0.35)),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      filled: true,
      fillColor: AppColors.backgroundPrimary.withOpacity(0.35),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.backgroundTertiary.withOpacity(0.25),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.backgroundTertiary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    );
  }

  // ---------------------------------------------------------------------------
  // SAVE PERSONAL INFORMATION
  // ---------------------------------------------------------------------------

  Future<void> _savePersonalInformation() async {
    final birthday = _parseDate(_birthdayController.text);

    if (birthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid birthday.')),
      );

      return;
    }

    if (_selectedGender == null || _selectedGender!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a gender.')));

      return;
    }

    final genderId = _getGenderIdFromName(_selectedGender);

    if (genderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to determine the selected gender.'),
        ),
      );

      return;
    }

    setState(() {
      _isSavingPersonalInformation = true;
    });

    try {
      final request = UserURU(
        pfp: _profilePictureController.text.trim(),
        username: _usernameController.text.trim(),
        name: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        birthday: birthday,
        genderId: genderId,
        password: null,
        password2: null,
        twoFA: _isTwoFAEnabled,
      );

      final result = await _userProvider.updateEntityForUsers(null, request);

      if (!mounted) {
        return;
      }

      if (result.data != null) {
        _user = result.data;

        _populateFields(result.data!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personal information saved successfully.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message ?? 'Unable to update your personal information.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update your personal information: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingPersonalInformation = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // CHANGE PASSWORD
  // ---------------------------------------------------------------------------

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _repeatNewPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match.')),
      );

      return;
    }

    setState(() {
      _isChangingPassword = true;
    });

    try {
      // TODO:
      // Add your change-password API call here.

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully.')),
      );

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _repeatNewPasswordController.clear();
    } finally {
      if (mounted) {
        setState(() {
          _isChangingPassword = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // FORGOT PASSWORD
  // ---------------------------------------------------------------------------

  void _forgotPassword() {
    // TODO:
    // Connect this to your forgot-password flow.
  }

  // ---------------------------------------------------------------------------
  // DELETE ACCOUNT CONFIRMATION
  // ---------------------------------------------------------------------------

  Future<void> _showDeleteAccountConfirmation() async {
    if (_isDeletingAccount) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundSecondary,
          title: const Text(
            'Delete Account?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete your account? '
            'This action cannot be undone.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Delete Account',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteAccount();
    }
  }

  // ---------------------------------------------------------------------------
  // DELETE ACCOUNT
  // ---------------------------------------------------------------------------

  Future<void> _deleteAccount() async {
    if (_isDeletingAccount) {
      return;
    }

    setState(() {
      _isDeletingAccount = true;
    });

    try {
      final result = await _userProvider.softDelete(null);

      if (!mounted) {
        return;
      }

      // -----------------------------------------------------------------------
      // DELETE SUCCESSFUL
      // -----------------------------------------------------------------------

      if (result.statusCode == 200) {
        _logoutAfterAccountDeletion();
        return;
      }

      // -----------------------------------------------------------------------
      // DELETE FAILED
      // -----------------------------------------------------------------------

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Unable to delete your account.'),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete your account: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeletingAccount = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // LOGOUT AFTER ACCOUNT DELETION
  // ---------------------------------------------------------------------------

  Future<void> _logoutAfterAccountDeletion() async {
    try {
      final AuthProvider authProvider = AuthProvider();

      await authProvider.logout();
    } catch (_) {
      // Even if backend logout fails, local authentication
      // state must still be cleared.
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
  // LOGOUT CONFIRMATION
  // ---------------------------------------------------------------------------

  Future<void> _showLogoutConfirmation() async {
    if (_isLoggingOut) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundSecondary,
          title: const Text(
            'Log Out?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out of your account?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Log Out',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _logout();
    }
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

  // ---------------------------------------------------------------------------
  // ERROR STATE
  // ---------------------------------------------------------------------------

  Widget _buildErrorState() {
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
              _errorMessage ?? 'Something went wrong.',
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
