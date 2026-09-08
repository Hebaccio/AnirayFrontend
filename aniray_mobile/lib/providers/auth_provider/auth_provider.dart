import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../requests_and_models/auth_r&m/auth_result.dart';
import '../../requests_and_models/auth_r&m/login_dto.dart';
import '../../requests_and_models/auth_r&m/verify_2fa_dto.dart';

class AuthProvider {
  static String? _baseUrl;

  final String _loginForStaff = "Auth/Login/ForStaff";
  final String _loginForUsers = "Auth/Login/ForUsers";
  final String _logout = "Auth/Logout";
  final String _refresh = "Auth/Refresh";
  final String _verify2FA = "Auth/Verify-2FA";
  final String _resend2FA = "Auth/Resend-2FA";
  final String _send2FAForPasswordReset = "Auth/Send2FAForPasswordReset";
  final String _verify2FAForPasswordReset = "Auth/Verify2FAForPasswordReset";

  AuthProvider() {
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "https://10.0.2.2:7247/",
    );
  }

  Future<AuthResult> loginForUsers() async {
    final url = "$_baseUrl$_loginForUsers";
    final uri = Uri.parse(url);

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": LoginDto.email,
        "password": LoginDto.password,
      }),
    );

    final data = _decodeResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _processAuthenticationResponse(data);
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<AuthResult> loginForStaff() async {
    final url = "$_baseUrl$_loginForStaff";
    final uri = Uri.parse(url);

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": LoginDto.email,
        "password": LoginDto.password,
      }),
    );

    final data = _decodeResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _processAuthenticationResponse(data);
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<AuthResult> verify2FA() async {
    final url = "$_baseUrl$_verify2FA";
    final uri = Uri.parse(url);

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": AuthResult.userId,
        "code": Verify2FADto.code,
      }),
    );

    final data = _decodeResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _processAuthenticationResponse(data);
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<AuthResult> resend2FA() async {
    final uri = Uri.parse("$_baseUrl$_resend2FA?userId=${AuthResult.userId}");

    final response = await http.post(uri);

    final data = _decodeResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _processAuthenticationResponse(data);
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<AuthResult> refresh() async {
    final currentAccessToken = AuthResult.accessToken;
    final currentRefreshToken = AuthResult.refreshToken;

    if (currentAccessToken == null || currentAccessToken.isEmpty) {
      throw Exception("No access token available for refresh.");
    }

    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      throw Exception("No refresh token available.");
    }

    final uri = Uri.parse("$_baseUrl$_refresh");

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "accessToken": currentAccessToken,
        "refreshToken": currentRefreshToken,
      }),
    );

    final data = _decodeResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (data is! Map<String, dynamic>) {
        throw Exception("Invalid refresh response from server.");
      }

      final newAccessToken = data["accessToken"]?.toString();
      final newRefreshToken = data["refreshToken"]?.toString();

      if (newAccessToken == null || newAccessToken.isEmpty) {
        throw Exception("Server did not return a new access token.");
      }

      if (newRefreshToken == null || newRefreshToken.isEmpty) {
        throw Exception("Server did not return a new refresh token.");
      }

      AuthResult.resetAuthenticationFailureHandled();

      AuthResult.twoFactorRequired = data["twoFactorRequired"];
      AuthResult.userId = data["userId"];

      AuthResult.setAccessToken(newAccessToken);
      AuthResult.refreshToken = newRefreshToken;

      await AuthResult.saveTokens();

      return AuthResult();
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<bool> restoreSession() async {
    final restored = await AuthResult.restoreAuthentication();

    if (!restored) {
      return false;
    }

    if (!AuthResult.isAccessTokenExpired) {
      return true;
    }

    try {
      await refresh();
      return true;
    } catch (_) {
      await AuthResult.clearAuthentication();
      return false;
    }
  }

  Future<void> logout() async {
    final currentRefreshToken = AuthResult.refreshToken;

    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      await AuthResult.clearAuthentication();
      return;
    }

    final uri = Uri.parse("$_baseUrl$_logout");

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refreshToken": currentRefreshToken}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      await AuthResult.clearAuthentication();
      return;
    }

    String errorMessage = "Failed to logout.";

    try {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        if (data["message"] != null) {
          errorMessage = data["message"].toString();
        } else if (data["errors"] != null) {
          final errors = data["errors"];

          if (errors is Map<String, dynamic>) {
            errorMessage = errors.values
                .expand((e) => e is List ? e : [e])
                .join("\n");
          }
        }
      }
    } catch (_) {
      // Keep default error message.
    }

    throw Exception(errorMessage);
  }

  // --------------------------------------------------
  // PASSWORD RESET
  // --------------------------------------------------

  Future<AuthResult> send2FAForPasswordReset(String email) async {
    final uri = Uri.parse(
      "$_baseUrl$_send2FAForPasswordReset",
    ).replace(queryParameters: {"email": email});

    final response = await http.post(uri);

    final data = _decodeResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _processAuthenticationResponse(data);
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<AuthResult> verify2FAForPasswordReset({
    required int userId,
    required String code,
    required String newPassword,
    required String newRepeatPassword,
  }) async {
    final uri = Uri.parse("$_baseUrl$_verify2FAForPasswordReset");

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "code": code,
        "newPassword": newPassword,
        "newRepeatPassword": newRepeatPassword,
      }),
    );

    final data = _decodeResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _processAuthenticationResponse(data);
    }

    throw Exception(_extractErrorMessage(data));
  }

  // --------------------------------------------------

  Future<AuthResult> _processAuthenticationResponse(dynamic data) async {
    if (data is! Map<String, dynamic>) {
      throw Exception("Invalid authentication response from server.");
    }

    AuthResult.resetAuthenticationFailureHandled();

    AuthResult.twoFactorRequired = data["twoFactorRequired"];
    AuthResult.userId = data["userId"];

    AuthResult.setAccessToken(data["accessToken"]?.toString());

    AuthResult.refreshToken = data["refreshToken"]?.toString();

    await AuthResult.saveTokens();

    return AuthResult();
  }

  dynamic _decodeResponse(http.Response response) {
    if (response.body.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return null;
    }
  }

  String _extractErrorMessage(dynamic data) {
    const defaultMessage = "Something went wrong.";

    if (data is Map<String, dynamic>) {
      if (data["message"] != null) {
        return data["message"].toString();
      }

      if (data["errors"] != null) {
        final errors = data["errors"];

        if (errors is Map<String, dynamic>) {
          return errors.values.expand((e) => e is List ? e : [e]).join("\n");
        }
      }
    }

    return defaultMessage;
  }
}
