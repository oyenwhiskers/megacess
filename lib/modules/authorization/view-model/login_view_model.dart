import '../data/service/auth_service.dart';
import 'package:dio/dio.dart';
import '../data/model/login_response.dart';

class LoginViewModel {
  LoginResponse? _lastLoginResponse;

  /// Get the user role after successful login
  String? get userRole => _lastLoginResponse?.user.userRole;

  /// Expose lastLoginResponse for use in views
  LoginResponse? get lastLoginResponse => _lastLoginResponse;
  final AuthService _authService = AuthService();
  bool isLoading = false;
  String? errorMessage;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    try {
      final response = await _authService.login(email, password);
      isLoading = false;
      if (response != null && response.token.isNotEmpty) {
        _lastLoginResponse = response;
        return true;
      } else {
        errorMessage = 'Incorrect username or password.';
        return false;
      }
    } on DioException catch (e) {
      isLoading = false;
      if (e.response?.statusCode == 401) {
        errorMessage = 'Incorrect username or password.';
      } else {
        errorMessage = 'Login failed. Please try again.';
      }
      return false;
    } catch (e) {
      isLoading = false;
      errorMessage = 'Login failed. Please try again.';
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
