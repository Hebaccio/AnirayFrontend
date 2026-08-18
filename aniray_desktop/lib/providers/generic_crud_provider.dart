import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aniray_desktop/providers/api_response.dart';
import 'package:aniray_desktop/providers/api_client.dart';
import 'package:aniray_desktop/providers/api_result.dart';
import 'package:aniray_desktop/requests/paged_result.dart';

import '../providers/base_provider.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);
typedef ToJson<T> = Map<String, dynamic> Function(T value);

class GenericCrudProvider<
  TModelUser,
  TModelEmployee,
  TSearchUser,
  TSearchEmployee,
  TInsertUser,
  TInsertEmployee,
  TUpdateUser,
  TUpdateEmployee
>
    extends BaseProvider {
  final ApiClient apiClient;

  final FromJson<TModelUser> modelUserFromJson;
  final FromJson<TModelEmployee> modelEmployeeFromJson;

  final ToJson<TSearchUser> searchUserToJson;
  final ToJson<TSearchEmployee> searchEmployeeToJson;

  final ToJson<TInsertUser> insertUserToJson;
  final ToJson<TInsertEmployee> insertEmployeeToJson;

  final ToJson<TUpdateUser> updateUserToJson;
  final ToJson<TUpdateEmployee> updateEmployeeToJson;

  GenericCrudProvider({
    required String endpoint,
    required this.apiClient,
    required this.modelUserFromJson,
    required this.modelEmployeeFromJson,
    required this.searchUserToJson,
    required this.searchEmployeeToJson,
    required this.insertUserToJson,
    required this.insertEmployeeToJson,
    required this.updateUserToJson,
    required this.updateEmployeeToJson,
  }) : super(endpoint);

  // ---------------------------------------------------------------------------
  // GET BY ID
  // ---------------------------------------------------------------------------

  Future<ApiResult<TModelUser>> entityGetByIdForUsers(int? id) {
    return _getById(
      id: id,
      path: '/EntityGetById/ForUsers',
      fromJson: modelUserFromJson,
    );
  }

  Future<ApiResult<TModelEmployee>> entityGetByIdForEmployees(int id) {
    return _getById(
      id: id,
      path: '/EntityGetById/ForEmployees',
      fromJson: modelEmployeeFromJson,
    );
  }

  Future<ApiResult<T>> _getById<T>({
    int? id,
    required String path,
    required FromJson<T> fromJson,
  }) {
    final requestUrl = id == null ? '$url$path' : '$url$path/$id';

    return _execute<T>(
      request: () => apiClient.get(requestUrl),
      fromJson: fromJson,
    );
  }

  // ---------------------------------------------------------------------------
  // GET PAGED
  // ---------------------------------------------------------------------------

  Future<ApiResult<PagedResult<TModelUser>>> getPagedEntityForUsers(
    TSearchUser search,
  ) {
    return _getPaged(
      search: search,
      path: '/GetPagedEntity/ForUsers',
      toJson: searchUserToJson,
      fromJson: modelUserFromJson,
    );
  }

  Future<ApiResult<PagedResult<TModelEmployee>>> getPagedEntityForEmployees(
    TSearchEmployee search,
  ) {
    return _getPaged(
      search: search,
      path: '/GetPagedEntity/ForEmployees',
      toJson: searchEmployeeToJson,
      fromJson: modelEmployeeFromJson,
    );
  }

  Future<ApiResult<PagedResult<TModel>>> _getPaged<TSearch, TModel>({
    required TSearch search,
    required String path,
    required ToJson<TSearch> toJson,
    required FromJson<TModel> fromJson,
  }) {
    final queryJson = toJson(search);

    final queryParameters = _toQueryParameters(queryJson);

    final requestUrl = '$url$path';

    return _execute<PagedResult<TModel>>(
      request: () =>
          apiClient.get(requestUrl, queryParameters: queryParameters),
      fromJson: (json) => PagedResult<TModel>.fromJson(
        json,
        (item) => fromJson(item as Map<String, dynamic>),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INSERT
  // ---------------------------------------------------------------------------

  Future<ApiResult<TModelUser>> insertEntityForUsers(TInsertUser request) {
    return _insert(
      request: request,
      path: '/InsertEntity/ForUsers',
      toJson: insertUserToJson,
      fromJson: modelUserFromJson,
    );
  }

  Future<ApiResult<TModelEmployee>> insertEntityForEmployees(
    TInsertEmployee request,
  ) {
    return _insert(
      request: request,
      path: '/InsertEntity/ForEmployees',
      toJson: insertEmployeeToJson,
      fromJson: modelEmployeeFromJson,
    );
  }

  Future<ApiResult<TModel>> _insert<TInsert, TModel>({
    required TInsert request,
    required String path,
    required ToJson<TInsert> toJson,
    required FromJson<TModel> fromJson,
  }) {
    final requestUrl = '$url$path';

    return _execute<TModel>(
      request: () => apiClient.post(
        requestUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(toJson(request)),
      ),
      fromJson: fromJson,
    );
  }

  // ---------------------------------------------------------------------------
  // UPDATE
  // ---------------------------------------------------------------------------

  Future<ApiResult<TModelUser>> updateEntityForUsers(
    int? id,
    TUpdateUser request,
  ) {
    return _update(
      id: id,
      request: request,
      path: '/UpdateEntity/ForUsers',
      toJson: updateUserToJson,
      fromJson: modelUserFromJson,
    );
  }

  Future<ApiResult<TModelEmployee>> updateEntityForEmployees(
    int id,
    TUpdateEmployee request,
  ) {
    return _update(
      id: id,
      request: request,
      path: '/UpdateEntity/ForEmployees',
      toJson: updateEmployeeToJson,
      fromJson: modelEmployeeFromJson,
    );
  }

  Future<ApiResult<TModel>> _update<TUpdate, TModel>({
    int? id,
    required TUpdate request,
    required String path,
    required ToJson<TUpdate> toJson,
    required FromJson<TModel> fromJson,
  }) {
    final requestUrl = id == null ? '$url$path' : '$url$path/$id';

    return _execute<TModel>(
      request: () => apiClient.patch(
        requestUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(toJson(request)),
      ),
      fromJson: fromJson,
    );
  }

  // ---------------------------------------------------------------------------
  // SOFT DELETE
  // ---------------------------------------------------------------------------

  Future<ApiResult<TModelUser>> softDelete(int? id) {
    return _softDelete(
      id: id,
      path: '/SoftDelete',
      fromJson: modelUserFromJson,
    );
  }

  Future<ApiResult<T>> _softDelete<T>({
    int? id,
    required String path,
    required FromJson<T> fromJson,
  }) {
    final requestUrl = id == null ? '$url$path' : '$url$path/$id';

    return _execute<T>(
      request: () => apiClient.delete(requestUrl),
      fromJson: fromJson,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, List<String>> _toQueryParameters(Map<String, dynamic> json) {
    final Map<String, List<String>> parameters = {};

    for (final entry in json.entries) {
      final value = entry.value;

      // Ignore null values.
      if (value == null) {
        continue;
      }

      // Lists need to be sent as repeated query parameters.
      //
      // Example:
      //
      // genreIds: [1, 2]
      //
      // becomes:
      //
      // GenreIds=1&GenreIds=2
      if (value is List) {
        final values = value
            .where((item) => item != null)
            .map((item) => item.toString())
            .toList();

        if (values.isNotEmpty) {
          parameters[entry.key] = values;
        }

        continue;
      }

      // Normal scalar parameter.
      parameters[entry.key] = [value.toString()];
    }

    return parameters;
  }

  dynamic _decodeResponseBody(String body) {
    if (body.isEmpty) {
      return null;
    }

    return jsonDecode(body);
  }

  ApiResult<T> _createApiResult<T>({
    required int statusCode,
    required dynamic data,
    required FromJson<T> fromJson,
  }) {
    if (data is Map<String, dynamic>) {
      final message = data['message'] as String?;

      if (data.length == 1 && message != null) {
        return ApiResult<T>(
          statusCode: statusCode,
          data: null,
          message: message,
        );
      }

      return ApiResult<T>(
        statusCode: statusCode,
        data: fromJson(data),
        message: null,
      );
    }

    return ApiResult<T>(
      statusCode: statusCode,
      data: null,
      message: _messageForStatusCode(statusCode),
    );
  }

  Future<ApiResult<T>> _execute<T>({
    required Future<ApiResponse<String>> Function() request,
    required FromJson<T> fromJson,
  }) async {
    try {
      final response = await request();

      final data = _decodeResponseBody(response.body);

      return _createApiResult<T>(
        statusCode: response.statusCode,
        data: data,
        fromJson: fromJson,
      );
    } on TimeoutException {
      return ApiResult<T>(
        statusCode: null,
        data: null,
        message: 'The request timed out. Please try again.',
      );
    } on SocketException {
      return ApiResult<T>(
        statusCode: null,
        data: null,
        message: 'Unable to connect to the server.',
      );
    } on FormatException {
      return ApiResult<T>(
        statusCode: null,
        data: null,
        message: 'The server returned an invalid response.',
      );
    } catch (e) {
      return ApiResult<T>(
        statusCode: null,
        data: null,
        message: 'An unexpected error occurred.',
      );
    }
  }

  String _messageForStatusCode(int statusCode) {
    switch (statusCode) {
      // 2xx — Success
      case 200:
        return 'Request completed successfully.';
      case 201:
        return 'Resource created successfully.';
      case 202:
        return 'Request accepted for processing.';
      case 204:
        return 'Request completed successfully with no content.';

      // 3xx — Redirection
      case 300:
        return 'Multiple possible responses were found.';
      case 301:
        return 'The requested resource has been permanently moved.';
      case 302:
        return 'The requested resource has been temporarily moved.';
      case 303:
        return 'See another resource for the requested result.';
      case 304:
        return 'The resource has not been modified.';
      case 307:
        return 'The request should be repeated at another location.';
      case 308:
        return 'The resource has been permanently moved.';

      // 4xx — Client errors
      case 400:
        return 'Bad request.';
      case 401:
        return 'Unauthorized to perform this action.';
      case 402:
        return 'Payment is required.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 405:
        return 'The requested action is not allowed.';
      case 406:
        return 'The requested response format is not acceptable.';
      case 407:
        return 'Proxy authentication is required.';
      case 408:
        return 'The request timed out.';
      case 409:
        return 'The request conflicts with the current state of the resource.';
      case 410:
        return 'The requested resource is no longer available.';
      case 411:
        return 'The request is missing required information.';
      case 412:
        return 'The request conditions were not met.';
      case 413:
        return 'The request is too large.';
      case 414:
        return 'The requested URL is too long.';
      case 415:
        return 'The request format is not supported.';
      case 416:
        return 'The requested range cannot be satisfied.';
      case 417:
        return 'The request could not be completed as expected.';
      case 418:
        return 'The server cannot fulfill the request.';
      case 422:
        return 'The request contains invalid data.';
      case 423:
        return 'The requested resource is locked.';
      case 424:
        return 'The request failed because a related request failed.';
      case 425:
        return 'The request cannot be processed yet.';
      case 426:
        return 'A protocol upgrade is required.';
      case 428:
        return 'The request requires additional conditions.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 431:
        return 'The request headers are too large.';
      case 451:
        return 'The requested resource is unavailable for legal reasons.';

      // 5xx — Server errors
      case 500:
        return 'Server Side Error, check Logs please.';

      default:
        return 'Request failed with status code $statusCode.';
    }
  }
}
