import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'secure_storage_service.dart';

/// A reusable Dio HTTP client with bearer-token injection and auth cleanup.
class DioClient {
  final String baseUrl;
  final SecureStorageService storageService;
  late final Dio dio;

  DioClient({required this.baseUrl, required this.storageService}) {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Never log credentials, authorization headers, or request bodies.
          if (kDebugMode) {
            debugPrint('[Dio] ${options.method} ${options.uri}');
          }

          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            await storageService.clearSession();
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(String path, {dynamic data, Options? options}) {
    return dio.post<T>(path, data: data, options: options);
  }

  Future<Response<T>> put<T>(String path, {dynamic data, Options? options}) {
    return dio.put<T>(path, data: data, options: options);
  }

  Future<Response<T>> delete<T>(String path, {dynamic data, Options? options}) {
    return dio.delete<T>(path, data: data, options: options);
  }
}
