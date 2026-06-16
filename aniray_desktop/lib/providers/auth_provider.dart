import 'dart:convert';
import 'package:aniray_desktop/requests/auth_requests/auth_result.dart';
import 'package:aniray_desktop/requests/auth_requests/login_dto.dart';
import 'package:aniray_desktop/requests/auth_requests/verify_2fa_dto.dart';
import 'package:http/http.dart' as http;

class AuthProvider {
  static String? _baseUrl;
  final String _loginForStaff = "Auth/Login/ForStaff";
  final String _verify2FA = "Auth/Verify-2FA";
  final String _resend2FA = "Auth/Resend-2FA";

  AuthProvider() {
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "https://localhost:7247/",
    );
  }

  Future<AuthResult> loginForStaff() async {
    var url = "$_baseUrl$_loginForStaff";
    var uri = Uri.parse(url);

    var response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": LoginDto.email,
        "password": LoginDto.password,
      }),
    );

    var data = jsonDecode(response.body);

    if (response.statusCode < 299) {
      AuthResult.twoFactorRequired = data["twoFactorRequired"];
      AuthResult.userId = data["userId"];
      AuthResult.accessToken = data["accessToken"];
      AuthResult.refreshToken = data["refreshToken"];
      if (data["expiresAt"] != null) {
        AuthResult.expiresAt = DateTime.parse(data["expiresAt"]);
      }
      return AuthResult();
    }
    String errorMessage = "Something went wrong";

    if (data["errors"] != null) {
      final errors = data["errors"] as Map<String, dynamic>;

      errorMessage = errors.values.expand((e) => e).join("\n");
    }

    throw Exception(errorMessage);
  }

  Future<AuthResult> verify2FA() async {
    var url = "$_baseUrl$_verify2FA";
    var uri = Uri.parse(url);

    var response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": AuthResult.userId,
        "code": Verify2FADto.code,
      }),
    );

    var data = jsonDecode(response.body);

    if (response.statusCode < 299) {
      AuthResult.twoFactorRequired = data["twoFactorRequired"];
      AuthResult.userId = data["userId"];
      AuthResult.accessToken = data["accessToken"];
      AuthResult.refreshToken = data["refreshToken"];
      if (data["expiresAt"] != null) {
        AuthResult.expiresAt = DateTime.parse(data["expiresAt"]);
      }
      return AuthResult();
    }
    String errorMessage = "Something went wrong";

    if (data["errors"] != null) {
      final errors = data["errors"] as Map<String, dynamic>;

      errorMessage = errors.values.expand((e) => e).join("\n");
    }

    throw Exception(errorMessage);
  }

  Future<AuthResult> resend2FA() async {
    var uri = Uri.parse("$_baseUrl$_resend2FA?userId=${AuthResult.userId}");

    var response = await http.post(uri);

    var data = jsonDecode(response.body);

    if (response.statusCode < 299) {
      AuthResult.twoFactorRequired = data["twoFactorRequired"];
      AuthResult.userId = data["userId"];
      AuthResult.accessToken = data["accessToken"];
      AuthResult.refreshToken = data["refreshToken"];

      if (data["expiresAt"] != null) {
        AuthResult.expiresAt = DateTime.parse(data["expiresAt"]);
      }

      return AuthResult();
    }

    String errorMessage = "Something went wrong";

    if (data["errors"] != null) {
      final errors = data["errors"] as Map<String, dynamic>;
      errorMessage = errors.values.expand((e) => e).join("\n");
    }

    throw Exception(errorMessage);
  }
}
