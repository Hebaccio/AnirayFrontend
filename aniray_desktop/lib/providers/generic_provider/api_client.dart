import 'dart:async';

import 'package:aniray_desktop/providers/auth_provider/auth_provider.dart';
import 'package:aniray_desktop/requests_and_models/helper_r&m/api_result_helpers/api_response.dart';
import 'package:aniray_desktop/requests_and_models/auth_r&m/auth_result.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _client;

  final AuthProvider _authProvider;

  /// GLOBAL authentication failure callback.
  ///
  /// This is static because multiple ApiClient instances can exist.
  ///
  /// The application configures this once from main.dart.
  static Future<void> Function()? _onAuthenticationFailed;

  /// GLOBAL refresh lock.
  ///
  /// This must be static because multiple ApiClient instances can exist.
  static Future<void>? _refreshFuture;

  ApiClient(this._client, {AuthProvider? authProvider})
    : _authProvider = authProvider ?? AuthProvider();

  // ---------------------------------------------------------------------------
  // GLOBAL AUTHENTICATION FAILURE HANDLER
  // ---------------------------------------------------------------------------

  static void setAuthenticationFailureHandler(Future<void> Function() handler) {
    _onAuthenticationFailed = handler;
  }

  // ---------------------------------------------------------------------------
  // HEADERS
  // ---------------------------------------------------------------------------

  Map<String, String> _getHeaders({Map<String, String>? headers}) {
    final result = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    final token = AuthResult.accessToken;

    if (token != null && token.isNotEmpty) {
      result['Authorization'] = 'Bearer $token';
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // GET
  // ---------------------------------------------------------------------------

  Future<ApiResponse<String>> get(
    String url, {
    Map<String, String>? headers,
    Map<String, List<String>>? queryParameters,
  }) async {
    final uri = Uri.parse(url).replace(queryParameters: queryParameters);

    return _executeWithAuthentication(
      request: () => _client.get(uri, headers: _getHeaders(headers: headers)),
    );
  }

  // ---------------------------------------------------------------------------
  // POST
  // ---------------------------------------------------------------------------

  Future<ApiResponse<String>> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse(url);

    return _executeWithAuthentication(
      request: () => _client.post(
        uri,
        headers: _getHeaders(headers: headers),
        body: body,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PUT
  // ---------------------------------------------------------------------------

  Future<ApiResponse<String>> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse(url);

    return _executeWithAuthentication(
      request: () => _client.put(
        uri,
        headers: _getHeaders(headers: headers),
        body: body,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PATCH
  // ---------------------------------------------------------------------------

  Future<ApiResponse<String>> patch(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse(url);

    return _executeWithAuthentication(
      request: () => _client.patch(
        uri,
        headers: _getHeaders(headers: headers),
        body: body,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DELETE
  // ---------------------------------------------------------------------------

  Future<ApiResponse<String>> delete(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse(url);

    return _executeWithAuthentication(
      request: () => _client.delete(
        uri,
        headers: _getHeaders(headers: headers),
        body: body,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // AUTHENTICATION HANDLING
  // ---------------------------------------------------------------------------

  Future<ApiResponse<String>> _executeWithAuthentication({
    required Future<http.Response> Function() request,
  }) async {
    // -------------------------------------------------------------------------
    // STEP 1
    //
    // Proactively refresh if the access token is expired/about to expire.
    // -------------------------------------------------------------------------

    if (AuthResult.accessToken != null &&
        AuthResult.isAccessTokenExpiringSoon()) {
      try {
        await _refreshAccessToken();
      } catch (_) {
        await _handleAuthenticationFailure();

        return ApiResponse<String>(statusCode: 401, body: '');
      }
    }

    // -------------------------------------------------------------------------
    // STEP 2
    //
    // Remember which access token this request is using.
    // -------------------------------------------------------------------------

    final tokenUsedForRequest = AuthResult.accessToken;

    // -------------------------------------------------------------------------
    // STEP 3
    //
    // Execute the request.
    // -------------------------------------------------------------------------

    final response = await request();

    // -------------------------------------------------------------------------
    // STEP 4
    //
    // Anything other than 401 is finished.
    // -------------------------------------------------------------------------

    if (response.statusCode != 401) {
      return ApiResponse<String>(
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    // -------------------------------------------------------------------------
    // STEP 5
    //
    // We received 401.
    //
    // Check whether another request already refreshed the token.
    // -------------------------------------------------------------------------

    final currentToken = AuthResult.accessToken;

    if (tokenUsedForRequest != null &&
        currentToken != null &&
        tokenUsedForRequest != currentToken) {
      final retryResponse = await request();

      if (retryResponse.statusCode == 401) {
        await _handleAuthenticationFailure();
      }

      return ApiResponse<String>(
        statusCode: retryResponse.statusCode,
        body: retryResponse.body,
      );
    }

    // -------------------------------------------------------------------------
    // STEP 6
    //
    // There is no refresh token available.
    // Authentication is dead.
    // -------------------------------------------------------------------------

    final refreshToken = AuthResult.refreshToken;

    if (refreshToken == null || refreshToken.isEmpty) {
      await _handleAuthenticationFailure();

      return ApiResponse<String>(statusCode: 401, body: response.body);
    }

    // -------------------------------------------------------------------------
    // STEP 7
    //
    // Refresh.
    // -------------------------------------------------------------------------

    try {
      await _refreshAccessToken();
    } catch (_) {
      await _handleAuthenticationFailure();

      return ApiResponse<String>(statusCode: 401, body: response.body);
    }

    // -------------------------------------------------------------------------
    // STEP 8
    //
    // Retry the original request exactly once.
    // -------------------------------------------------------------------------

    final retryResponse = await request();

    // -------------------------------------------------------------------------
    // STEP 9
    //
    // If the new token also gets 401, authentication is dead.
    // -------------------------------------------------------------------------

    if (retryResponse.statusCode == 401) {
      await _handleAuthenticationFailure();
    }

    return ApiResponse<String>(
      statusCode: retryResponse.statusCode,
      body: retryResponse.body,
    );
  }

  // ---------------------------------------------------------------------------
  // REFRESH ACCESS TOKEN
  // ---------------------------------------------------------------------------

  Future<void> _refreshAccessToken() async {
    final existingRefresh = _refreshFuture;

    if (existingRefresh != null) {
      return existingRefresh;
    }

    final refreshCompleter = Completer<void>();

    _refreshFuture = refreshCompleter.future;

    try {
      await _authProvider.refresh();

      if (!refreshCompleter.isCompleted) {
        refreshCompleter.complete();
      }
    } catch (e, stackTrace) {
      if (!refreshCompleter.isCompleted) {
        refreshCompleter.completeError(e, stackTrace);
      }

      rethrow;
    } finally {
      if (identical(_refreshFuture, refreshCompleter.future)) {
        _refreshFuture = null;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // AUTHENTICATION FAILURE
  // ---------------------------------------------------------------------------

  static Future<void> _handleAuthenticationFailure() async {
    // Multiple requests can discover the authentication failure
    // simultaneously.
    //
    // Only the first one should clear authentication and navigate.

    if (AuthResult.authenticationFailureHandled) {
      return;
    }

    AuthResult.markAuthenticationFailureHandled();

    // IMPORTANT:
    // Clear both RAM AND secure storage.
    await AuthResult.clearAuthentication();

    // Tell the application to go to LoginScreen.
    await _onAuthenticationFailed?.call();
  }
}
