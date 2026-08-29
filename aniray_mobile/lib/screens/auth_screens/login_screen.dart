import 'package:flutter/material.dart';
import '../../helpers/app_colors.dart';
import '../../providers/auth_provider/auth_provider.dart';
import '../../requests_and_models/auth_r&m/auth_result.dart';
import '../../requests_and_models/auth_r&m/login_dto.dart';
import '../../widgets/main_navbar_widget.dart';
import '2fa_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.title,
    this.sessionExpired = false,
  });

  final String title;

  /// True when the user was sent back to the login screen because
  /// their access token and refresh token could no longer be used.
  final bool sessionExpired;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _showValidationErrors = false;
  String? _emailError;
  String? _passwordError;

  final RegExp _emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

  final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$/%^&*(),.?":{}|<>]).{6,}$',
  );

  @override
  void initState() {
    super.initState();

    if (widget.sessionExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.backgroundTertiary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.lock_clock_outlined, color: AppColors.textPrimary),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Session expired",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: const Text(
              "Your session has expired. Please log in again.",
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "OK",
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        );
      });
    }
  }

  bool _validate() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    String? emailError;
    String? passwordError;

    if (!_emailRegex.hasMatch(email)) {
      emailError = "Enter a valid email address";
    }

    if (!_passwordRegex.hasMatch(password)) {
      passwordError =
          "Password must contain 1 uppercase letter, 1 number and 1 special character";
    }

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _showValidationErrors = true;
    });

    return emailError == null && passwordError == null;
  }

  Future<void> _login() async {
    if (!_validate()) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    try {
      final provider = AuthProvider();

      LoginDto.email = _emailController.text.trim();
      LoginDto.password = _passwordController.text;

      await provider.loginForUsers();

      if (!mounted) return;

      if (AuthResult.twoFactorRequired == true) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const TwoFAScreen(title: "")),
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavbarWidget()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.backgroundTertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Login Error",
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            e.toString().replaceFirst("Exception: ", ""),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "OK",
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textPrimary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.backgroundTertiary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.textPrimary, width: 1),
      ),
    );
  }

  Widget _buildValidationError(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 12, right: 12),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          message,
          textAlign: TextAlign.left,
          style: const TextStyle(color: AppColors.textError, fontSize: 12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallPhone = screenWidth < 380;

    final horizontalPadding = isSmallPhone ? 18.0 : 24.0;
    final cardPadding = isSmallPhone ? 22.0 : 28.0;
    final titleSize = isSmallPhone ? 26.0 : 30.0;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Card(
                      color: AppColors.backgroundSecondary,
                      elevation: 12,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(cardPadding),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Log-In",
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 30),

                            // EMAIL
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              enableSuggestions: false,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                              decoration: _inputDecoration(label: "Email"),
                            ),

                            if (_showValidationErrors && _emailError != null)
                              _buildValidationError(_emailError!),

                            const SizedBox(height: 18),

                            // PASSWORD
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) {
                                if (!_isLoading) {
                                  _login();
                                }
                              },
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                              decoration: _inputDecoration(
                                label: "Password",
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),

                            if (_showValidationErrors && _passwordError != null)
                              _buildValidationError(_passwordError!),

                            const SizedBox(height: 10),

                            // FORGOT PASSWORD
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 8,
                                  ),
                                  minimumSize: const Size(0, 40),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // LOGIN BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.backgroundTertiary,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: AppColors
                                      .backgroundTertiary
                                      .withOpacity(0.6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.textPrimary,
                                              ),
                                        ),
                                      )
                                    : const Text(
                                        "LOGIN",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
