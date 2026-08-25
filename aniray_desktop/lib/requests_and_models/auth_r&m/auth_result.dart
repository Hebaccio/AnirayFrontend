import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthResult {
  static bool? twoFactorRequired;
  static int? userId;
  static String? accessToken;
  static String? refreshToken;
  static DateTime? expiresAt;
  static String? role;

  // ---------------------------------------------------------------------------
  // SECURE STORAGE
  // ---------------------------------------------------------------------------

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _accessTokenKey = "accessToken";
  static const String _refreshTokenKey = "refreshToken";

  // ---------------------------------------------------------------------------
  // AUTHENTICATION FAILURE STATE
  // ---------------------------------------------------------------------------

  static bool _authenticationFailureHandled = false;

  static bool get authenticationFailureHandled => _authenticationFailureHandled;

  static void markAuthenticationFailureHandled() {
    _authenticationFailureHandled = true;
  }

  static void resetAuthenticationFailureHandled() {
    _authenticationFailureHandled = false;
  }

  // ---------------------------------------------------------------------------
  // ACCESS TOKEN
  // ---------------------------------------------------------------------------

  static void setAccessToken(String? token) {
    accessToken = token;

    if (token == null || token.isEmpty) {
      role = null;
      expiresAt = null;
      return;
    }

    final decodedToken = JwtDecoder.decode(token);

    role =
        decodedToken["role"]?.toString() ??
        decodedToken["http://schemas.microsoft.com/ws/2008/06/identity/claims/role"]
            ?.toString();

    expiresAt = JwtDecoder.getExpirationDate(token);
  }

  // ---------------------------------------------------------------------------
  // PERSISTENT AUTHENTICATION
  // ---------------------------------------------------------------------------

  static Future<void> saveTokens() async {
    final currentAccessToken = accessToken;
    final currentRefreshToken = refreshToken;

    if (currentAccessToken == null || currentAccessToken.isEmpty) {
      await _storage.delete(key: _accessTokenKey);
    } else {
      await _storage.write(key: _accessTokenKey, value: currentAccessToken);
    }

    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      await _storage.delete(key: _refreshTokenKey);
    } else {
      await _storage.write(key: _refreshTokenKey, value: currentRefreshToken);
    }
  }

  static Future<bool> restoreAuthentication() async {
    final storedAccessToken = await _storage.read(key: _accessTokenKey);

    final storedRefreshToken = await _storage.read(key: _refreshTokenKey);

    if (storedAccessToken == null ||
        storedAccessToken.isEmpty ||
        storedRefreshToken == null ||
        storedRefreshToken.isEmpty) {
      await clearPersistentAuthentication();
      return false;
    }

    try {
      setAccessToken(storedAccessToken);

      refreshToken = storedRefreshToken;

      return true;
    } catch (_) {
      await clearPersistentAuthentication();
      clear();

      return false;
    }
  }

  static Future<void> clearPersistentAuthentication() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  // ---------------------------------------------------------------------------
  // ROLES
  // ---------------------------------------------------------------------------

  static bool get isUser => role == "User";

  static bool get isEmployee => role == "Employee";

  static bool get isBoss => role == "Boss";

  // ---------------------------------------------------------------------------
  // TOKEN EXPIRATION
  // ---------------------------------------------------------------------------

  static bool get isAccessTokenExpired {
    final expiry = expiresAt;

    if (expiry == null) {
      return true;
    }

    return DateTime.now().toUtc().isAfter(expiry.toUtc());
  }

  static bool isAccessTokenExpiringSoon({
    Duration buffer = const Duration(seconds: 45),
  }) {
    final expiry = expiresAt;

    if (expiry == null) {
      return true;
    }

    final now = DateTime.now().toUtc();
    final refreshThreshold = expiry.toUtc().subtract(buffer);

    return now.isAfter(refreshThreshold);
  }

  // ---------------------------------------------------------------------------
  // CLEAR AUTHENTICATION
  // ---------------------------------------------------------------------------

  static void clear() {
    twoFactorRequired = null;
    userId = null;
    accessToken = null;
    refreshToken = null;
    expiresAt = null;
    role = null;
  }

  static Future<void> clearAuthentication() async {
    clear();
    await clearPersistentAuthentication();
  }
}

/*

  static bool get isUser => false;
  static bool get isEmployee => false;
  static bool get isBoss => true;

class AuthResult2 {
  static String? accessTokenForEmployees =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjIiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiaGFtemFoZWJpYm92aWMwMUBnbWFpbC5jb20iLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJCb3NzIiwiZXhwIjoxNzg3NjYyODMyLCJpc3MiOiJNeUFwaSIsImF1ZCI6Ik15QXBpQ2xpZW50In0.yRnBGoslu8KV71D8-Q1x5Cfs1wkkOcADBCj4ek1jIB4";
  static String? accessTokenForUsers =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjIiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiaGFtemFoZWJpYm92aWMwMUBnbWFpbC5jb20iLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJVc2VyIiwiZXhwIjoxNzg3NjYyODAyLCJpc3MiOiJNeUFwaSIsImF1ZCI6Ik15QXBpQ2xpZW50In0.IlzgQOwIKr8ZRuptQ_G8VsjSDIPasg2VjQAeNumn__w";
}
*/
