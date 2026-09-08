import 'package:flutter/material.dart';

import '../../helpers/app_colors.dart';
import '../../providers/auth_provider/auth_provider.dart';

class PasswordChangeCodeScreen extends StatefulWidget {
  const PasswordChangeCodeScreen({
    super.key,
    required this.title,
    required this.userId,
    required this.email,
    required this.onBack,
    required this.onCompleted,
  });

  final String title;
  final int userId;
  final String email;
  final VoidCallback onBack;
  final VoidCallback onCompleted;

  @override
  State<PasswordChangeCodeScreen> createState() =>
      _PasswordChangeCodeScreenState();
}

class _PasswordChangeCodeScreenState extends State<PasswordChangeCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _isResending = false;
  bool _showValidationErrors = false;

  bool _obscureNewPassword = true;
  bool _obscureRepeatPassword = true;

  String? _codeError;
  String? _newPasswordError;
  String? _repeatPasswordError;

  bool _validate() {
    final code = _codeController.text.trim();
    final newPassword = _newPasswordController.text;
    final repeatPassword = _repeatPasswordController.text;

    String? codeError;
    String? newPasswordError;
    String? repeatPasswordError;

    if (code.isEmpty) {
      codeError = "2FA code is required";
    }

    if (newPassword.isEmpty) {
      newPasswordError = "New password is required";
    } else if (newPassword.length < 8 || newPassword.length > 20) {
      newPasswordError = "Password must be between 8 and 20 characters";
    }

    if (repeatPassword.isEmpty) {
      repeatPasswordError = "Please repeat your new password";
    } else if (newPassword != repeatPassword) {
      repeatPasswordError = "Passwords do not match";
    }

    setState(() {
      _codeError = codeError;
      _newPasswordError = newPasswordError;
      _repeatPasswordError = repeatPasswordError;
      _showValidationErrors = true;
    });

    return codeError == null &&
        newPasswordError == null &&
        repeatPasswordError == null;
  }

  Future<void> _changePassword() async {
    if (!_validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = AuthProvider();

      await provider.verify2FAForPasswordReset(
        userId: widget.userId,
        code: _codeController.text.trim(),
        newPassword: _newPasswordController.text,
        newRepeatPassword: _repeatPasswordController.text,
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.backgroundTertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Password Changed",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Your password has been changed successfully. "
            "You can now log in with your new password.",
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

      if (!mounted) return;

      // Password reset completed successfully.
      // Return directly to LoginScreen.
      widget.onCompleted();
    } catch (e) {
      if (!mounted) return;

      final errorMessage = e.toString().replaceFirst("Exception: ", "");

      // Backend returns this after the 3rd failed attempt.
      if (errorMessage ==
          "Failed 3rd attempt, you have to do the process again!") {
        await _showThreeAttemptsFailedDialog();

        if (!mounted) return;

        // Return directly to LoginScreen.
        widget.onCompleted();

        return;
      }

      // First and second failed attempts, or any other backend error.
      _showErrorDialog(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showThreeAttemptsFailedDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundTertiary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Password Reset Failed",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Failed 3rd attempt, you have to do the process again!",
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
  }

  Future<void> _resendCode() async {
    if (_isResending || _isLoading) return;

    setState(() {
      _isResending = true;
    });

    try {
      final provider = AuthProvider();

      await provider.send2FAForPasswordReset(widget.email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("A new 2FA code has been sent to your email address."),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      _showErrorDialog(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundTertiary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Password Reset Error",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          message,
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
  }

  InputDecoration _inputDecoration({
    required String label,
    Widget? suffixIcon,
  }) {
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
      suffixIcon: suffixIcon,
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
    _codeController.dispose();
    _newPasswordController.dispose();
    _repeatPasswordController.dispose();
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
                  onPressed: (_isLoading || _isResending)
                      ? null
                      : widget.onBack,
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
                                  // TITLE
                                  Text(
                                    "Change Password",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  // DESCRIPTION
                                  Text(
                                    "Enter the 2FA code sent to ${widget.email} "
                                    "and choose your new password.",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),

                                  const SizedBox(height: 30),

                                  // 2FA CODE
                                  TextField(
                                    controller: _codeController,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    maxLength: 6,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                    ),
                                    decoration: _inputDecoration(
                                      label: "2FA Code",
                                    ).copyWith(counterText: ""),
                                  ),

                                  if (_showValidationErrors &&
                                      _codeError != null)
                                    _buildValidationError(_codeError!),

                                  const SizedBox(height: 18),

                                  // NEW PASSWORD
                                  TextField(
                                    controller: _newPasswordController,
                                    obscureText: _obscureNewPassword,
                                    textInputAction: TextInputAction.next,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                    ),
                                    decoration: _inputDecoration(
                                      label: "New Password",
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _obscureNewPassword =
                                                !_obscureNewPassword;
                                          });
                                        },
                                        icon: Icon(
                                          _obscureNewPassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),

                                  if (_showValidationErrors &&
                                      _newPasswordError != null)
                                    _buildValidationError(_newPasswordError!),

                                  const SizedBox(height: 18),

                                  // REPEAT NEW PASSWORD
                                  TextField(
                                    controller: _repeatPasswordController,
                                    obscureText: _obscureRepeatPassword,
                                    textInputAction: TextInputAction.done,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    onSubmitted: (_) {
                                      if (!_isLoading && !_isResending) {
                                        _changePassword();
                                      }
                                    },
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                    ),
                                    decoration: _inputDecoration(
                                      label: "Repeat New Password",
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _obscureRepeatPassword =
                                                !_obscureRepeatPassword;
                                          });
                                        },
                                        icon: Icon(
                                          _obscureRepeatPassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),

                                  if (_showValidationErrors &&
                                      _repeatPasswordError != null)
                                    _buildValidationError(
                                      _repeatPasswordError!,
                                    ),

                                  const SizedBox(height: 24),

                                  // RESEND CODE
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: TextButton(
                                      onPressed: (_isLoading || _isResending)
                                          ? null
                                          : _resendCode,
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.textPrimary,
                                      ),
                                      child: _isResending
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
                                              "RESEND CODE",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1,
                                                fontSize: 14,
                                              ),
                                            ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // CHANGE PASSWORD BUTTON
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: (_isLoading || _isResending)
                                          ? null
                                          : _changePassword,
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
                                              "CHANGE PASSWORD",
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
