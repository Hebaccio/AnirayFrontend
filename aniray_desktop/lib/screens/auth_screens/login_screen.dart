import 'package:aniray_desktop/providers/auth_provider.dart';
import 'package:aniray_desktop/requests/auth_requests/auth_result.dart';
import 'package:aniray_desktop/requests/auth_requests/login_dto.dart';
import 'package:aniray_desktop/screens/auth_screens/2fa_screen.dart';
import 'package:aniray_desktop/widgets/main_sidebar_widget.dart';
import 'package:flutter/material.dart';
import 'package:aniray_desktop/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.title});

  final String title;

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
      AuthProvider provider = AuthProvider();
      LoginDto.email = _emailController.text;
      LoginDto.password = _passwordController.text;

      await provider.loginForStaff();

      if (AuthResult.twoFactorRequired == true) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => TwoFAScreen()));
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const MainSidebarWidget()),
        );
      }
    } catch (e) {
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              color: AppColors.backgroundSecondary,
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Log-In",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const SizedBox(height: 32),

                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(color: AppColors.textPrimary),
                        filled: true,
                        fillColor: AppColors.backgroundTertiary,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    if (_showValidationErrors && _emailError != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 6,
                          left: 12,
                          right: 12,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            _emailError!,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              color: AppColors.textError,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(color: AppColors.textPrimary),
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
                        filled: true,
                        fillColor: AppColors.backgroundTertiary,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    if (_showValidationErrors && _passwordError != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 6,
                          left: 12,
                          right: 12,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            _passwordError!,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              color: AppColors.textError,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.backgroundTertiary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.textPrimary,
                                    ),
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
  }
}
