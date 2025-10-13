import '../data/service/auth_service.dart';

class LoginViewModel {
  final AuthService _authService = AuthService();
  bool isLoading = false;
  String? errorMessage;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    final response = await _authService.login(email, password);
    isLoading = false;
    if (response != null && response.token.isNotEmpty) {
      return true;
    } else {
      errorMessage = 'Login failed';
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
