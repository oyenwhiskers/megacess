import '../model/login_response.dart';
import '../model/user_role.dart';
import '../../../utility/dio_client.dart';
import '../../../utility/secure_storage_service.dart';
import '../../../../core/config/flavor_config.dart';
import 'package:dio/dio.dart';

class AuthService {
  final String _baseUrl = FlavorConfig.instance.baseUrl;
  final SecureStorageService _storageService = SecureStorageService();
  late final DioClient _dioClient = DioClient(
    baseUrl: _baseUrl,
    storageService: _storageService,
  );

  /// Login with username and password, save token and role securely if successful
  Future<LoginResponse?> login(String username, String password) async {
    final response = await _dioClient.post(
      'auth/login',
      data: {'user_nickname': username, 'password': password},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    if (response.statusCode == 200) {
      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        final loginResponse = LoginResponse.fromJson(data['data']);
        final role = UserRole.normalize(loginResponse.user.userRole);
        if (!UserRole.isSupported(role)) {
          throw StateError('This account role is not supported by the mobile app.');
        }

        await _storageService.saveToken(loginResponse.token);
        await _storageService.saveUserRole(role);
        return loginResponse;
      }
    }
    return null;
  }

  /// Get user role securely
  Future<String?> getUserRole() async {
    return _storageService.getUserRole();
  }

  /// Validate a stored session with the backend and return its current role.
  Future<String?> restoreSessionRole() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      await _storageService.clearSession();
      return null;
    }

    try {
      final response = await _dioClient.get('profile');
      if (response.statusCode == 200 &&
          response.data is Map &&
          response.data['success'] == true &&
          response.data['data'] is Map) {
        final role = UserRole.normalize(
          response.data['data']['user_role']?.toString() ?? '',
        );
        if (UserRole.isSupported(role)) {
          await _storageService.saveUserRole(role);
          return role;
        }
        await _storageService.clearSession();
        return null;
      }
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        await _storageService.clearSession();
        return null;
      }

      // Keep a known session on temporary connectivity failures.
      final storedRole = await getUserRole();
      if (storedRole != null && UserRole.isSupported(storedRole)) {
        return UserRole.normalize(storedRole);
      }
      return null;
    }

    await _storageService.clearSession();
    return null;
  }

  /// Get token securely
  Future<String?> getToken() async {
    return _storageService.getToken();
  }

  /// Revoke the backend session and always clear local authentication state.
  Future<void> logout() async {
    try {
      final token = await _storageService.getToken();
      if (token != null && token.isNotEmpty) {
        await _dioClient.post('auth/logout');
      }
    } catch (_) {
      // Local logout must still succeed if the API cannot be reached.
    } finally {
      await _storageService.clearSession();
    }
  }
}
