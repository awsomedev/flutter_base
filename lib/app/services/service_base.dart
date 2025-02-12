import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:madeira/app/models/login_model.dart';
import 'package:madeira/app/widgets/admin_only_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:madeira/app/services/dio_config.dart';

enum HttpMethod { get, post, put, delete, patch }

class ServiceBase {
  static const String _baseUrl =
      'http://43.204.196.183:8000/api/'; // Update with your actual base URL
  static const Duration _timeout = Duration(seconds: 30);

  ServiceBase(this._prefs);
  final SharedPreferences _prefs;

  // Getter for base URL
  static String get baseUrl => _baseUrl;

  // Get stored auth token
  // String? get authToken =>
  //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjo0ODkwNzc1NTc3LCJpYXQiOjE3MzcxNzU1NzcsImp0aSI6IjRmNThkZDUxYjVlZDQ4OWQ5YWFjODNjZTM2NWM1MTc4IiwidXNlcl9pZCI6MX0.hJJY5fY1gUN1PbW2Z5-tXf4CdnqTV_btZogojn0SsTw';
  String? get authToken => _prefs.getString('auth_token');

  // Get stored user ID
  String? get userId => _prefs.getString('user_id');

  // Common headers for all requests
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  // Headers without content type for multipart requests
  Map<String, String> get _authHeaders => {
        'Accept': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  // Generic HTTP request method
  Future<T> request<T>({
    required String endpoint,
    required HttpMethod method,
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final dio = await DioConfig.getInstance();
      Response response;

      switch (method) {
        case HttpMethod.get:
          response = await dio.get(
            endpoint,
            queryParameters: queryParameters,
          );
          break;
        case HttpMethod.post:
          response = await dio.post(
            endpoint,
            data: body,
            queryParameters: queryParameters,
          );
          break;
        case HttpMethod.put:
          response = await dio.put(
            endpoint,
            data: body,
            queryParameters: queryParameters,
          );
          break;
        case HttpMethod.delete:
          response = await dio.delete(
            endpoint,
            data: body,
            queryParameters: queryParameters,
          );
          break;
        case HttpMethod.patch:
          response = await dio.patch(
            endpoint,
            data: body,
            queryParameters: queryParameters,
          );
          break;
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        if (fromJson != null) {
          return fromJson(response.data);
        }
        return response.data as T;
      } else {
        throw ApiException(
          message: response.data['error'] ??
              response.data['message'] ??
              'Unknown error',
          statusCode: response.statusCode,
          data: response.data,
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected error: $e');
    }
  }

  // Helper methods for common HTTP methods
  Future<T> get<T>({
    required String endpoint,
    Map<String, String>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.get,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }

  Future<T> post<T>({
    required String endpoint,
    required Map<String, dynamic> body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.post,
      body: body,
      fromJson: fromJson,
    );
  }

  Future<T> put<T>({
    required String endpoint,
    required Map<String, dynamic> body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.put,
      body: body,
      fromJson: fromJson,
    );
  }

  Future<T> delete<T>({
    required String endpoint,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.delete,
      fromJson: fromJson,
    );
  }

  // FormData upload method
  Future<T> uploadFormData<T>({
    required String endpoint,
    String method = 'POST',
    Map<String, dynamic>? fields,
    Map<String, List<File>>? files,
    void Function(int, int)? onSendProgress,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final dio = await DioConfig.getInstance();
      final formDataMap = <String, dynamic>{};

      // Add fields if any
      if (fields != null) {
        formDataMap.addAll(fields);
      }

      // Add files if any
      if (files != null) {
        await Future.forEach(files.entries,
            (MapEntry<String, List<File>> entry) async {
          if (entry.value.isNotEmpty) {
            if (entry.value.length == 1) {
              // Single file
              final file = entry.value.first;
              formDataMap[entry.key] = await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              );
            } else {
              // Multiple files
              final multipartFiles = await Future.wait(
                entry.value.map((file) => MultipartFile.fromFile(
                      file.path,
                      filename: file.path.split('/').last,
                    )),
              );
              formDataMap[entry.key] = multipartFiles;
            }
          }
        });
      }

      final formDataObj = FormData.fromMap(formDataMap);
      Response response;

      switch (method.toUpperCase()) {
        case 'PUT':
          response = await dio.put(
            endpoint,
            data: formDataObj,
            onSendProgress: onSendProgress,
          );
          break;
        case 'PATCH':
          response = await dio.patch(
            endpoint,
            data: formDataObj,
            onSendProgress: onSendProgress,
          );
          break;
        default:
          response = await dio.post(
            endpoint,
            data: formDataObj,
            onSendProgress: onSendProgress,
          );
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        if (fromJson != null) {
          return fromJson(response.data);
        }
        return response.data as T;
      } else {
        throw ApiException(
          message: response.data['error'] ??
              response.data['message'] ??
              'Unknown error',
          statusCode: response.statusCode,
          data: response.data,
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected error: $e');
    }
  }

  // Token management methods
  Future<void> saveAuthToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  Future<void> saveUserId(String id) async {
    await _prefs.setString('user_id', id);
  }

  Future<String?> getUserId() async {
    return _prefs.getString('user_id');
  }

  Future<void> saveUser(UserModel user) async {
    await _prefs.setString('user', jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    final userJson = _prefs.getString('user');
    return userJson != null ? UserModel.fromJson(jsonDecode(userJson)) : null;
  }

  Future<void> clearAuth() async {
    await _prefs.remove('auth_token');
    await _prefs.remove('user_id');
    await _prefs.remove('user');
    await AdminTracker.clearAdmin();
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }
}

class ApiMessageError extends Error {
  final String message;
  @override
  String toString() {
    return message;
  }

  ApiMessageError(this.message);
}
