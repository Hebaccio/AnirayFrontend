import 'dart:convert';

import 'package:aniray_desktop/providers/api_client.dart';
import 'package:aniray_desktop/providers/api_exception.dart';
import 'package:aniray_desktop/requests/new_paged_result.dart';

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

  Future<TModelUser> entityGetByIdForUsers(int id) {
    return _getById(
      id: id,
      path: '/EntityGetById/ForUsers',
      fromJson: modelUserFromJson,
    );
  }

  Future<TModelEmployee> entityGetByIdForEmployees(int id) {
    return _getById(
      id: id,
      path: '/EntityGetById/ForEmployees',
      fromJson: modelEmployeeFromJson,
    );
  }

  Future<PagedResult<TModelUser>> getPagedEntityForUsers(TSearchUser search) {
    return _getPaged(
      search: search,
      path: '/GetPagedEntity/ForUsers',
      toJson: searchUserToJson,
      fromJson: modelUserFromJson,
    );
  }

  Future<PagedResult<TModelEmployee>> getPagedEntityForEmployees(
    TSearchEmployee search,
  ) {
    return _getPaged(
      search: search,
      path: '/GetPagedEntity/ForEmployees',
      toJson: searchEmployeeToJson,
      fromJson: modelEmployeeFromJson,
    );
  }

  Future<TModelUser> insertEntityForUsers(TInsertUser request) {
    return _insert(
      request: request,
      path: '/InsertEntity/ForUsers',
      toJson: insertUserToJson,
      fromJson: modelUserFromJson,
    );
  }

  Future<TModelEmployee> insertEntityForEmployees(TInsertEmployee request) {
    return _insert(
      request: request,
      path: '/InsertEntity/ForEmployees',
      toJson: insertEmployeeToJson,
      fromJson: modelEmployeeFromJson,
    );
  }

  Future<TModelUser> updateEntityForUsers(int id, TUpdateUser request) {
    return _update(
      id: id,
      request: request,
      path: '/UpdateEntity/ForUsers',
      toJson: updateUserToJson,
      fromJson: modelUserFromJson,
    );
  }

  Future<TModelEmployee> updateEntityForEmployees(
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

  Future<T> _getById<T>({
    required int id,
    required String path,
    required FromJson<T> fromJson,
  }) async {
    final requestUrl = '$url$path/$id';

    final response = await apiClient.get(requestUrl);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return fromJson(data as Map<String, dynamic>);
    }

    throw _createApiException(response.statusCode, data);
  }

  Future<PagedResult<TModel>> _getPaged<TSearch, TModel>({
    required TSearch search,
    required String path,
    required ToJson<TSearch> toJson,
    required FromJson<TModel> fromJson,
  }) async {
    final queryJson = toJson(search);

    final queryParameters = _toQueryParameters(queryJson);

    final requestUrl = '$url$path';

    final response = await apiClient.get(
      requestUrl,
      queryParameters: queryParameters,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final json = data as Map<String, dynamic>;

      return PagedResult<TModel>.fromJson(
        json,
        (item) => fromJson(item as Map<String, dynamic>),
      );
    }

    throw _createApiException(response.statusCode, data);
  }

  Future<TModel> _insert<TInsert, TModel>({
    required TInsert request,
    required String path,
    required ToJson<TInsert> toJson,
    required FromJson<TModel> fromJson,
  }) async {
    final requestUrl = '$url$path';

    final response = await apiClient.post(
      requestUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(toJson(request)),
    );

    print('STATUS: ${response.statusCode}');
    print('BODY: "${response.body}"');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return fromJson(data as Map<String, dynamic>);
    }

    throw _createApiException(response.statusCode, data);
  }

  Future<TModel> _update<TUpdate, TModel>({
    required int id,
    required TUpdate request,
    required String path,
    required ToJson<TUpdate> toJson,
    required FromJson<TModel> fromJson,
  }) async {
    final requestUrl = '$url$path/$id';

    final response = await apiClient.patch(
      requestUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(toJson(request)),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return fromJson(data as Map<String, dynamic>);
    }

    throw _createApiException(response.statusCode, data);
  }

  Map<String, String> _toQueryParameters(Map<String, dynamic> json) {
    return Map.fromEntries(
      json.entries
          .where((entry) => entry.value != null)
          .map((entry) => MapEntry(entry.key, entry.value.toString())),
    );
  }

  ApiException _createApiException(int statusCode, dynamic data) {
    String message = 'Unknown API error.';

    if (data is Map<String, dynamic> && data['message'] is String) {
      message = data['message'] as String;
    }

    return ApiException(statusCode: statusCode, message: message);
  }
}
