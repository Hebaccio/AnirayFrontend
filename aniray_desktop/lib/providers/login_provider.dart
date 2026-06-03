import 'dart:convert';
import 'package:aniray_desktop/requests/auth_requests/auth_result.dart';
import 'package:aniray_desktop/requests/auth_requests/login_dto.dart';
import 'package:http/http.dart' as http;

class LoginProvider {
  static String? _baseUrl;
  final String _urlContinuation = "Auth/Login/ForStaff";

  LoginProvider() {
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "https://localhost:7247/",
    );
  }

  Future<AuthResult> post() async {
    var url = "$_baseUrl$_urlContinuation";
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
      print("2FA: ${AuthResult.twoFactorRequired}");
      print("UserID: ${AuthResult.userId}");
      print("Access Token: ${AuthResult.accessToken}");
      print("Refresh Token: ${AuthResult.refreshToken}");
      print("Expires At: ${AuthResult.expiresAt}");
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
