import 'package:flutter/material.dart';

import '../../helpers/app_colors.dart';
import '../../providers/auth_provider/auth_provider.dart';
import '../../requests_and_models/auth_r&m/auth_result.dart';
import '../../requests_and_models/auth_r&m/verify_2fa_dto.dart';
import '../../widgets/main_navbar_widget.dart';
import 'login_screen.dart';

class TwoFAScreen extends StatefulWidget {
  const TwoFAScreen({super.key, required this.title});

  final String title;

  @override
  State<TwoFAScreen> createState() => _TwoFAScreenState();
}

class _TwoFAScreenState extends State<TwoFAScreen> {
  final TextEditingController _codeController = TextEditingController();

  bool _isLoading = false;
  bool _isResending = false;

  int _attemptCounter = 0;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify2FA() async {
    if (_isLoading) {
      return;
    }

    final code = _codeController.text.trim();

    if (code.length != 6) {
      _showMessage('Please enter the 6-digit verification code.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    try {
      final provider = AuthProvider();

      Verify2FADto.userId = AuthResult.userId;
      Verify2FADto.code = code;

      await provider.verify2FA();

      if (!mounted) {
        return;
      }

      if (AuthResult.accessToken != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavbarWidget()),
          (route) => false,
        );
      } else {
        _handleWrongCode();
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      _handleWrongCode(error: e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleWrongCode({Object? error}) {
    _attemptCounter++;

    _codeController.clear();

    if (_attemptCounter >= 3) {
      _showTooManyAttemptsDialog();
      return;
    }

    _showMessage('Invalid code. Attempt $_attemptCounter / 3');
  }

  void _showTooManyAttemptsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundTertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.textPrimary),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Too many attempts',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'You entered the wrong code 3 times. Please log in again.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                AuthResult.clear();

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(
                      title: 'Login',
                      sessionExpired: false,
                    ),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                'OK',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resend2FA() async {
    if (_isResending) {
      return;
    }

    setState(() {
      _isResending = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    try {
      final provider = AuthProvider();

      await provider.resend2FA();

      if (!mounted) {
        return;
      }

      _attemptCounter = 0;
      _codeController.clear();

      _showMessage('A new verification code has been sent.');
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.backgroundTertiary,
          behavior: SnackBarBehavior.floating,
          content: Text(
            message,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      counterText: '',
      hintText: '000000',
      hintStyle: TextStyle(
        color: AppColors.textPrimary.withOpacity(0.35),
        letterSpacing: 7,
        fontSize: 20,
      ),
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallPhone = screenWidth < 380;

    final horizontalPadding = isSmallPhone ? 18.0 : 24.0;
    final cardPadding = isSmallPhone ? 22.0 : 28.0;
    final titleSize = isSmallPhone ? 20.0 : 22.0;

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
                    constraints: const BoxConstraints(maxWidth: 420),
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
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: AppColors.backgroundTertiary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_outline_rounded,
                                size: 32,
                                color: AppColors.textPrimary,
                              ),
                            ),

                            const SizedBox(height: 18),

                            Text(
                              'Two-Factor Authentication',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              'Enter the 6-digit code sent to your email',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 28),

                            TextField(
                              controller: _codeController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              maxLength: 6,
                              textAlign: TextAlign.center,
                              enabled: !_isLoading,
                              onSubmitted: (_) {
                                if (!_isLoading) {
                                  _verify2FA();
                                }
                              },
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 21,
                                letterSpacing: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: _inputDecoration(),
                            ),

                            const SizedBox(height: 8),

                            TextButton(
                              onPressed: _isResending || _isLoading
                                  ? null
                                  : _resend2FA,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                minimumSize: const Size(0, 40),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: _isResending
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.textPrimary,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      'Resend code',
                                      style: TextStyle(
                                        color: _isLoading
                                            ? AppColors.textSecondary
                                                  .withOpacity(0.4)
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                            ),

                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _verify2FA,
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
                                        'VERIFY',
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
