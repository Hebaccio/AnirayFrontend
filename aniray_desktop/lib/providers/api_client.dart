import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _client;
  final String? accessTokenForEmployees;

  ApiClient(this._client, {this.accessTokenForEmployees});

  Map<String, String> _getHeaders({Map<String, String>? headers}) {
    final result = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    if (accessTokenForEmployees != null &&
        accessTokenForEmployees!.isNotEmpty) {
      result['Authorization'] = 'Bearer $accessTokenForEmployees';
    }

    return result;
  }

  Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) {
    final uri = Uri.parse(url).replace(queryParameters: queryParameters);

    return _client.get(uri, headers: _getHeaders(headers: headers));
  }

  Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _client.post(
      Uri.parse(url),
      headers: _getHeaders(headers: headers),
      body: body,
    );
  }

  Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _client.put(
      Uri.parse(url),
      headers: _getHeaders(headers: headers),
      body: body,
    );
  }

  Future<http.Response> patch(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _client.patch(
      Uri.parse(url),
      headers: _getHeaders(headers: headers),
      body: body,
    );
  }

  Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _client.delete(
      Uri.parse(url),
      headers: _getHeaders(headers: headers),
      body: body,
    );
  }
}
