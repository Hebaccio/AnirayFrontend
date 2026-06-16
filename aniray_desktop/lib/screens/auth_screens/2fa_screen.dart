import 'package:aniray_desktop/providers/auth_provider.dart';
import 'package:aniray_desktop/requests/auth_requests/auth_result.dart';
import 'package:aniray_desktop/requests/auth_requests/verify_2fa_dto.dart';
import 'package:aniray_desktop/screens/auth_screens/login_screen.dart';
import 'package:aniray_desktop/widgets/main_sidebar_widget.dart';
import 'package:flutter/material.dart';
import 'package:aniray_desktop/theme/app_colors.dart';

class TwoFAScreen extends StatefulWidget {
  const TwoFAScreen({super.key});

  @override
  State<TwoFAScreen> createState() => _TwoFAScreenState();
}

class _TwoFAScreenState extends State<TwoFAScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  int counter = 0;

  Future<void> _verify2FA() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    try {
      AuthProvider provider = AuthProvider();
      Verify2FADto.userId = AuthResult.userId;
      Verify2FADto.code = _codeController.text;

      await provider.verify2FA();

      if (AuthResult.accessToken != null) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const MainSidebarWidget()),
        );
      } else {
        _handleWrongCode();
      }
    } catch (e) {
      _handleWrongCode(error: e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleWrongCode({Object? error}) {
    setState(() {
      counter++;
    });

    if (counter >= 3) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.backgroundTertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Too many attempts",
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            "You entered the wrong code 3 times. Please log in again.",
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(title: "Login"),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                "OK",
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.backgroundTertiary,
          content: Text(
            "Invalid code. Attempt $counter / 3",
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
    }
  }

  Future<void> _resend2FA() async {
    await Future.delayed(const Duration(seconds: 1));

    AuthProvider provider = AuthProvider();
    await provider.resend2FA();
    counter = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
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
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 52,
                      color: AppColors.textPrimary,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Two-Factor Authentication",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Enter the 6-digit code sent to your email",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 28),

                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        letterSpacing: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        hintStyle: const TextStyle(
                          color: AppColors.textSecondary,
                          letterSpacing: 6,
                        ),
                        filled: true,
                        fillColor: AppColors.backgroundTertiary,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: _resend2FA,
                        child: const Text(
                          "Resend code",
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _verify2FA,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.backgroundTertiary,
                          foregroundColor: Colors.white,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.textPrimary,
                                  ),
                                ),
                              )
                            : const Text(
                                "VERIFY",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
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
