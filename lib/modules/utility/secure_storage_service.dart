import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing and retrieving sensitive data like tokens.
class SecureStorageService {
  static const _tokenKey = 'auth_token';
  static const _roleKey = 'user_role';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Save token securely
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Read token securely
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Delete token securely
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Save user role securely
  Future<void> saveUserRole(String role) async {
    await _storage.write(key: _roleKey, value: role);
  }

  /// Read user role securely
  Future<String?> getUserRole() async {
    return await _storage.read(key: _roleKey);
  }

  /// Delete user role securely
  Future<void> deleteUserRole() async {
    await _storage.delete(key: _roleKey);
  }
}
