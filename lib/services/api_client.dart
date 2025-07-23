import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // For debugPrint

class ApiClient {
  late Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://192.168.1.68:8000/api/',
        connectTimeout: const Duration(seconds: 5), // 5 seconds
        receiveTimeout: const Duration(seconds: 3), // 3 seconds
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add interceptors
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('--- ApiClient Request Interceptor ---');
          debugPrint(
            'Sending ${options.method} request to: ${options.baseUrl}${options.path}',
          );
          debugPrint('Headers: ${options.headers}');
          if (options.data != null) {
            debugPrint('Body: ${options.data}');
          }
          debugPrint('-------------------------------------');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('--- ApiClient Response Interceptor ---');
          debugPrint(
            'Received response from: ${response.requestOptions.baseUrl}${response.requestOptions.path}',
          );
          debugPrint('Status: ${response.statusCode}');
          debugPrint('Data: ${response.data}');
          debugPrint('--------------------------------------');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint('--- ApiClient Error Interceptor ---');
          debugPrint('Error Type: ${e.type}');
          debugPrint('Error Message: ${e.message}');
          debugPrint('Original Error: ${e.error}');
          debugPrint('Response Data: ${e.response?.data}');
          debugPrint('-----------------------------------');
          // Example: Handle 401 Unauthorized globally
          if (e.response?.statusCode == 401) {
            // You might trigger a re-authentication flow here
            debugPrint('Unauthorized access detected! Redirecting to login...');
          }
          return handler.next(e); // Continue with the error
        },
      ),
    );
  }

  // You can add generic methods here if needed, or rely on services directly
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
