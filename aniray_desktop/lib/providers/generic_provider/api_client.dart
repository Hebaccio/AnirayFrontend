import 'dart:async';

import 'package:aniray_desktop/providers/auth_provider/auth_provider.dart';
import 'package:aniray_desktop/requests_and_models/helper_r&m/api_result_helpers/api_response.dart';
import 'package:aniray_desktop/requests_and_models/auth_r&m/auth_result.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _client;

  final AuthProvider _authProvider;

  /// Called when the access token can no longer be refreshed.
  ///
  /// The application/root widget can use this callback to:
  /// - clear the current screen
  /// - navigate to LoginScreen
  /// - show a "Session expired" message
  final void Function()? onAuthenticationFailed;

  /// GLOBAL refresh lock.
  ///
  /// This must be static because multiple ApiClient instances can exist.
  ///
  /// Without this being static, this situation can happen:
  ///
  /// ApiClient A -> refresh
  /// ApiClient B -> refresh
  /// ApiClient C -> refresh
  ///
  /// Each ApiClient would have its own lock.
  static Future<void>? _refreshFuture;

  ApiClient(
    this._client, {
    AuthProvider? authProvider,
    this.onAuthenticationFailed,
  }) : _authProvider = authProvider ?? AuthProvider();

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
        _handleAuthenticationFailure();

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
      // Another request already refreshed the token.
      //
      // Do NOT refresh again.
      // Simply retry with the new token.

      final retryResponse = await request();

      if (retryResponse.statusCode == 401) {
        _handleAuthenticationFailure();
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
      _handleAuthenticationFailure();

      return ApiResponse<String>(statusCode: 401, body: response.body);
    }

    // -------------------------------------------------------------------------
    // STEP 7
    //
    // Refresh.
    //
    // _refreshAccessToken() guarantees that only ONE refresh operation
    // exists globally.
    // -------------------------------------------------------------------------

    try {
      await _refreshAccessToken();
    } catch (_) {
      _handleAuthenticationFailure();

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
    // Do NOT refresh again.
    // -------------------------------------------------------------------------

    if (retryResponse.statusCode == 401) {
      _handleAuthenticationFailure();
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
    // If another ApiClient is already refreshing, wait for it.
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
      // Only clear the lock belonging to this refresh operation.
      if (identical(_refreshFuture, refreshCompleter.future)) {
        _refreshFuture = null;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // AUTHENTICATION FAILURE
  // ---------------------------------------------------------------------------

  void _handleAuthenticationFailure() {
    // Multiple requests can discover the authentication failure
    // simultaneously.
    //
    // Only the first one should clear authentication and navigate
    // to LoginScreen.

    if (AuthResult.authenticationFailureHandled) {
      return;
    }

    AuthResult.markAuthenticationFailureHandled();

    AuthResult.clear();

    onAuthenticationFailed?.call();
  }
}
