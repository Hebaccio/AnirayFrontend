import 'package:aniray_desktop/requests/auth_requests/auth_result.dart';
import 'package:http/http.dart' as http;
import 'api_response.dart';

class ApiClient {
  final http.Client _client;

  ApiClient(this._client);

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

  Future<ApiResponse<String>> get(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse(url).replace(queryParameters: queryParameters);

    final response = await _client.get(
      uri,
      headers: _getHeaders(headers: headers),
    );

    return ApiResponse<String>(
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  Future<ApiResponse<String>> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final response = await _client.post(
      Uri.parse(url),
      headers: _getHeaders(headers: headers),
      body: body,
    );

    return ApiResponse<String>(
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  Future<ApiResponse<String>> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final response = await _client.put(
      Uri.parse(url),
      headers: _getHeaders(headers: headers),
      body: body,
    );

    return ApiResponse<String>(
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  Future<ApiResponse<String>> patch(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final response = await _client.patch(
      Uri.parse(url),
      headers: _getHeaders(headers: headers),
      body: body,
    );

    return ApiResponse<String>(
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  Future<ApiResponse<String>> delete(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final response = await _client.delete(
      Uri.parse(url),
      headers: _getHeaders(headers: headers),
      body: body,
    );

    return ApiResponse<String>(
      statusCode: response.statusCode,
      body: response.body,
    );
  }
}
