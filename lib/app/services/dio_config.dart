import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioConfig {
  static Dio? _instance;
  static const String baseUrl = 'http://159.89.166.142:8000/api/';
  static const Duration timeout = Duration(seconds: 30);

  static Future<Dio> getInstance() async {
    if (_instance == null) {
      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
        sendTimeout: timeout,
        responseType: ResponseType.json,
      ));

      // Add interceptors
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));

      // Add auth interceptor
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Handle token expiry/auth errors
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('auth_token');
            // You can add navigation to login or token refresh logic here
          }
          return handler.next(error);
        },
      ));

      _instance = dio;
    }
    return _instance!;
  }

  static void reset() {
    _instance = null;
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;

  factory ApiException.fromDioError(DioException error) {
    String message = 'Something went wrong';
    int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timed out';
        break;
      case DioExceptionType.badResponse:
        message = error.response?.data?['message'] ??
            error.response?.data?['error'] ??
            'Server error';
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection';
        break;
      default:
        message = 'Network error occurred';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: error.response?.data,
    );
  }
}
