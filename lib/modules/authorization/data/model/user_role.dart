abstract final class UserRole {
  static const admin = 'admin';
  static const manager = 'manager';
  static const mandor = 'mandor';
  static const checker = 'checker';

  static const supported = {admin, manager, mandor, checker};

  static String normalize(String role) => role.trim().toLowerCase();

  static bool isSupported(String role) => supported.contains(normalize(role));
}
