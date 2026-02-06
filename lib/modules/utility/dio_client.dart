import 'package:dio/dio.dart';
import 'secure_storage_service.dart';

/// A reusable Dio HTTP client with token injection and error handling.
class DioClient {
  final String baseUrl;
  final SecureStorageService storageService;
  late final Dio dio;

  DioClient({required this.baseUrl, required this.storageService}) {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Inject token if available
          final token = await storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          print('🌐 [Dio] Request: ${options.method} ${options.uri}');
          print('🌐 [Dio] Headers: ${options.headers}');
          print('🌐 [Dio] Data: ${options.data}');

          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Handle 401 Unauthorized: clear token and optionally notify
          if (e.response?.statusCode == 401) {
            await storageService.deleteToken();
            // Optionally: trigger a logout/auth error event here
          }
          return handler.next(e);
        },
      ),
    );
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  /// POST request
  Future<Response<T>> post<T>(String path, {dynamic data, Options? options}) {
    return dio.post<T>(path, data: data, options: options);
  }

  /// PUT request
  Future<Response<T>> put<T>(String path, {dynamic data, Options? options}) {
    return dio.put<T>(path, data: data, options: options);
  }

  /// DELETE request
  Future<Response<T>> delete<T>(String path, {dynamic data, Options? options}) {
    return dio.delete<T>(path, data: data, options: options);
  }
}
