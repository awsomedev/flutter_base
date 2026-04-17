import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:madeira/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:madeira/app/widgets/network_error_dialog.dart';

class DioConfig {
  static Dio? _instance;
  static bool _isShowingNetworkError = false;
  static const String baseUrl = 'http://159.65.147.75:8000/api/';
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
          log("$token");
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            print('Token: $token');
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

          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.unknown) {
            if (!_isShowingNetworkError &&
                globalNavigatorKey.currentContext != null) {
              _isShowingNetworkError = true;
              showDialog(
                context: globalNavigatorKey.currentContext!,
                builder: (context) => NetworkErrorDialog(
                  onClose: () {
                    Navigator.of(context).pop(); // close dialog
                  },
                ),
                barrierDismissible: false,
              ).then((_) {
                _isShowingNetworkError = false;
              });
            }
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
