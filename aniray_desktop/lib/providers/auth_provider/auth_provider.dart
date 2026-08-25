import 'dart:async';
import 'dart:convert';

import 'package:aniray_desktop/requests_and_models/auth_r&m/auth_result.dart';
import 'package:aniray_desktop/requests_and_models/auth_r&m/login_dto.dart';
import 'package:aniray_desktop/requests_and_models/auth_r&m/verify_2fa_dto.dart';
import 'package:http/http.dart' as http;

class AuthProvider {
  static String? _baseUrl;

  final String _loginForStaff = "Auth/Login/ForStaff";
  final String _loginForUsers = "Auth/Login/ForUsers";
  final String _logout = "Auth/Logout";
  final String _refresh = "Auth/Refresh";
  final String _verify2FA = "Auth/Verify-2FA";
  final String _resend2FA = "Auth/Resend-2FA";

  AuthProvider() {
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "https://localhost:7247/",
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

    final data = jsonDecode(response.body);
    if (response.statusCode < 299) {
      AuthResult.resetAuthenticationFailureHandled();

      AuthResult.twoFactorRequired = data["twoFactorRequired"];
      AuthResult.userId = data["userId"];

      AuthResult.setAccessToken(data["accessToken"]);

      AuthResult.refreshToken = data["refreshToken"];

      if (data["expiresAt"] != null) {
        AuthResult.expiresAt = DateTime.parse(data["expiresAt"]);
      }

      return AuthResult();
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

    final data = jsonDecode(response.body);

    if (response.statusCode < 299) {
      AuthResult.resetAuthenticationFailureHandled();

      AuthResult.twoFactorRequired = data["twoFactorRequired"];
      AuthResult.userId = data["userId"];

      AuthResult.setAccessToken(data["accessToken"]);

      AuthResult.refreshToken = data["refreshToken"];

      if (data["expiresAt"] != null) {
        AuthResult.expiresAt = DateTime.parse(data["expiresAt"]);
      }

      return AuthResult();
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

    final data = jsonDecode(response.body);

    if (response.statusCode < 299) {
      AuthResult.resetAuthenticationFailureHandled();

      AuthResult.twoFactorRequired = data["twoFactorRequired"];
      AuthResult.userId = data["userId"];

      AuthResult.setAccessToken(data["accessToken"]);

      AuthResult.refreshToken = data["refreshToken"];

      if (data["expiresAt"] != null) {
        AuthResult.expiresAt = DateTime.parse(data["expiresAt"]);
      }

      return AuthResult();
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<AuthResult> resend2FA() async {
    final uri = Uri.parse("$_baseUrl$_resend2FA?userId=${AuthResult.userId}");

    final response = await http.post(uri);

    final data = jsonDecode(response.body);

    if (response.statusCode < 299) {
      AuthResult.twoFactorRequired = data["twoFactorRequired"];
      AuthResult.userId = data["userId"];

      AuthResult.setAccessToken(data["accessToken"]);

      AuthResult.refreshToken = data["refreshToken"];

      if (data["expiresAt"] != null) {
        AuthResult.expiresAt = DateTime.parse(data["expiresAt"]);
      }

      return AuthResult();
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<AuthResult> refresh() async {
    final accessToken = AuthResult.accessToken;
    final refreshToken = AuthResult.refreshToken;

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception("No access token available for refresh.");
    }

    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception("No refresh token available.");
    }

    final uri = Uri.parse("$_baseUrl$_refresh");

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "accessToken": accessToken,
        "refreshToken": refreshToken,
      }),
    );

    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = null;
    }

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

      if (data["expiresAt"] != null) {
        AuthResult.expiresAt = DateTime.parse(data["expiresAt"]);
      }

      return AuthResult();
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<void> logout() async {
    final refreshToken = AuthResult.refreshToken;

    if (refreshToken == null || refreshToken.isEmpty) {
      AuthResult.clear();
      return;
    }

    final uri = Uri.parse("$_baseUrl$_logout");

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refreshToken": refreshToken}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      AuthResult.clear();
      return;
    }

    String errorMessage = "Failed to logout.";

    try {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        if (data["message"] != null) {
          errorMessage = data["message"].toString();
        } else if (data["errors"] != null) {
          final errors = data["errors"] as Map<String, dynamic>;

          errorMessage = errors.values
              .expand((e) => e is List ? e : [e])
              .join("\n");
        }
      }
    } catch (_) {
      // Keep default error message.
    }

    throw Exception(errorMessage);
  }

  String _extractErrorMessage(dynamic data) {
    String errorMessage = "Something went wrong.";

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

    return errorMessage;
  }
}
