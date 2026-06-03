import 'package:aniray_desktop/providers/login_provider.dart';
import 'package:aniray_desktop/requests/auth_requests/auth_result.dart';
import 'package:aniray_desktop/requests/auth_requests/login_dto.dart';
import 'package:aniray_desktop/screens/2fa_screen.dart';
import 'package:aniray_desktop/screens/my_home_page.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.title});

  final String title;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  bool _showValidationErrors = false;
  String? _emailError;
  String? _passwordError;

  final RegExp _emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
  final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$/%^&*(),.?":{}|<>]).{6,}$',
  );

  static const Color primaryColor = Color(0xFF0B1622);
  static const Color secondaryColor = Color(0xFF24344D);
  static const Color tertiaryColor = Color(0xFF395580);

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
      LoginProvider provider = LoginProvider();
      LoginDto.email = _emailController.text;
      LoginDto.password = _passwordController.text;

      await provider.post();

      if (AuthResult.twoFactorRequired == true) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => TwoFAScreen()));
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => MyHomePage(title: "testttt")),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Login Error",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            e.toString().replaceFirst("Exception: ", ""),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
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
      backgroundColor: primaryColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              color: secondaryColor,
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
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const SizedBox(height: 32),

                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        filled: true,
                        fillColor: primaryColor.withValues(alpha: 0.5),
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
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white70,
                          ),

                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: primaryColor.withValues(alpha: 0.5),
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
                              color: Colors.redAccent,
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
                            style: TextStyle(color: Colors.white70),
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
                          backgroundColor: tertiaryColor,
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
                                      Colors.white,
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
