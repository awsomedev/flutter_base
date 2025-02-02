import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum HttpMethod { get, post, put, delete, patch }

class ServiceBase {
  static const String _baseUrl =
      'http://3.110.136.32:8000/api/'; // Update with your actual base URL
  static const Duration _timeout = Duration(seconds: 30);

  ServiceBase(this._prefs);
  final SharedPreferences _prefs;

  // Getter for base URL
  String get baseUrl => _baseUrl;

  // Get stored auth token
  String? get authToken =>
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjo0ODkwNzc1NTc3LCJpYXQiOjE3MzcxNzU1NzcsImp0aSI6IjRmNThkZDUxYjVlZDQ4OWQ5YWFjODNjZTM2NWM1MTc4IiwidXNlcl9pZCI6MX0.hJJY5fY1gUN1PbW2Z5-tXf4CdnqTV_btZogojn0SsTw';
  // String? get authToken => _prefs.getString('auth_token');

  // Get stored user ID
  String? get userId => _prefs.getString('user_id');

  // Common headers for all requests
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
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
      print('$_baseUrl$endpoint');
      final uri = Uri.parse('$_baseUrl$endpoint').replace(
        queryParameters: queryParameters,
      );

      http.Response response;

      switch (method) {
        case HttpMethod.get:
          response = await http.get(uri, headers: _headers).timeout(_timeout);
          break;
        case HttpMethod.post:
          response = await http
              .post(uri, headers: _headers, body: jsonEncode(body))
              .timeout(_timeout);
          break;
        case HttpMethod.put:
          response = await http
              .put(uri, headers: _headers, body: jsonEncode(body))
              .timeout(_timeout);
          break;
        case HttpMethod.delete:
          response =
              await http.delete(uri, headers: _headers).timeout(_timeout);
          break;
        case HttpMethod.patch:
          response = await http
              .patch(uri, headers: _headers, body: jsonEncode(body))
              .timeout(_timeout);
          break;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (fromJson != null) {
          return fromJson(jsonDecode(response.body));
        }
        return jsonDecode(response.body) as T;
      } else {
        throw Exception(
          'Request failed with status: ${response.statusCode}\n${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
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

  // Token management methods
  Future<void> saveAuthToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  Future<void> saveUserId(String id) async {
    await _prefs.setString('user_id', id);
  }

  Future<String?> getUserId() async {
    return '4';
    // return _prefs.getString('user_id');
  }

  Future<void> clearAuth() async {
    await _prefs.remove('auth_token');
    await _prefs.remove('user_id');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return true;
    // return prefs.getString('auth_token') != null;
  }
}
