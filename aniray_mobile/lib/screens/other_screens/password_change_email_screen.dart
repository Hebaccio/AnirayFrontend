import 'package:flutter/material.dart';

import '../../helpers/app_colors.dart';
import '../../providers/auth_provider/auth_provider.dart';
import '../../requests_and_models/auth_r&m/auth_result.dart';
import 'password_change_code_screen.dart';

class PasswordChangeEmailScreen extends StatefulWidget {
  const PasswordChangeEmailScreen({
    super.key,
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  State<PasswordChangeEmailScreen> createState() =>
      _PasswordChangeEmailScreenState();
}

class _PasswordChangeEmailScreenState extends State<PasswordChangeEmailScreen> {
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  bool _showValidationErrors = false;
  String? _emailError;

  final RegExp _emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

  bool _validate() {
    final email = _emailController.text.trim();

    String? emailError;

    if (email.isEmpty) {
      emailError = "Email is required";
    } else if (!_emailRegex.hasMatch(email)) {
      emailError = "Enter a valid email address";
    }

    setState(() {
      _emailError = emailError;
      _showValidationErrors = true;
    });

    return emailError == null;
  }

  Future<void> _sendCode() async {
    if (!_validate()) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    try {
      final provider = AuthProvider();

      final email = _emailController.text.trim();

      await provider.send2FAForPasswordReset(email);

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PasswordChangeCodeScreen(
            title: "",
            userId: AuthResult.userId!,
            email: email,
            onBack: () {
              Navigator.of(context).pop();
            },
            onCompleted: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("A 2FA code has been sent to your email address."),
        ),
      );
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
            "Password Reset Error",
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

  InputDecoration _inputDecoration({required String label}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textPrimary),
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
        child: Column(
          children: [
            // BACK BUTTON
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: IconButton(
                  onPressed: _isLoading ? null : widget.onBack,
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                  ),
                  tooltip: "Back",
                ),
              ),
            ),

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
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
                                  // BACK BUTTON
                                  const SizedBox(height: 10),

                                  // TITLE
                                  Text(
                                    "Forgot Password?",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  // DESCRIPTION
                                  const Text(
                                    "Enter the email address associated with "
                                    "your account and we will send you a 2FA code "
                                    "that will allow you to change your password.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),

                                  const SizedBox(height: 30),

                                  // EMAIL
                                  TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.done,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    onSubmitted: (_) {
                                      if (!_isLoading) {
                                        _sendCode();
                                      }
                                    },
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                    ),
                                    decoration: _inputDecoration(
                                      label: "Email",
                                    ),
                                  ),

                                  if (_showValidationErrors &&
                                      _emailError != null)
                                    _buildValidationError(_emailError!),

                                  const SizedBox(height: 24),

                                  // SEND CODE BUTTON
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _sendCode,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.backgroundTertiary,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: AppColors
                                            .backgroundTertiary
                                            .withOpacity(0.6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(AppColors.textPrimary),
                                              ),
                                            )
                                          : const Text(
                                              "SEND CODE",
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
          ],
        ),
      ),
    );
  }
}
