import '../model/login_response.dart';
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
        await _storageService.saveToken(loginResponse.token);
        if (loginResponse.user.userRole.isNotEmpty) {
          await _storageService.saveUserRole(loginResponse.user.userRole);
        }
        // Print the successful login response to console
        print('Login success: ${response.data}');
        return loginResponse;
      }
    }
    return null;
  }

  /// Get user role securely
  Future<String?> getUserRole() async {
    return _storageService.getUserRole();
  }

  /// Get token securely
  Future<String?> getToken() async {
    return _storageService.getToken();
  }

  /// Logout and clear token securely
  Future<void> logout() async {
    await _storageService.deleteToken();
  }
}
