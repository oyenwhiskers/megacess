// env_config.dart - Centralized Environment Configuration
// ==============================================
// DEVELOPER: CHANGE ENV TO SWITCH BETWEEN ENVIRONMENTS
// ==============================================

const String ENV =
    'staging'; // CHANGE THIS TO 'production' TO SWITCH ENVIRONMENTS

// Environment Configuration Maps
class AppConfig {
  // API Base URLs for each environment
  static const Map<String, String> _apiUrls = {
    'staging': 'https://mwmsdemo.megacess.com/api/v1/',
    'production': 'https://mwms.megacess.com/api/v1/',
  };

  // Base Domain URLs for each environment
  static const Map<String, String> _domainUrls = {
    'staging': 'https://mwmsdemo.megacess.com',
    'production': 'https://mwms.megacess.com',
  };

  // Current environment's API URL
  static String get apiUrl {
    final url = _apiUrls[ENV];
    if (url == null) {
      throw Exception(
        'Invalid environment: "$ENV". Must be "staging" or "production".',
      );
    }
    return url;
  }

  // Current environment's base domain
  static String get baseDomain {
    final domain = _domainUrls[ENV];
    if (domain == null) {
      throw Exception(
        'Invalid environment: "$ENV". Must be "staging" or "production".',
      );
    }
    return domain;
  }

  // Storage Domain - uses the same domain as the environment
  // This ensures staging uses staging storage and production uses production storage
  static String get storageDomain => baseDomain;

  // Current environment name (for display/logging)
  static String get environmentName => ENV.toUpperCase();

  // Check if current environment is production
  static bool get isProduction => ENV == 'production';

  // Check if current environment is staging
  static bool get isStaging => ENV == 'staging';

  // Log current configuration (helpful for debugging)
  static void logConfiguration() {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Environment: $environmentName');
    print('API URL: $apiUrl');
    print('Base Domain: $baseDomain');
    print('Storage Domain: $storageDomain');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  // Get all configuration URLs (useful for debugging)
  static Map<String, String> getAllConfigs() {
    return {
      'environment': ENV,
      'apiUrl': apiUrl,
      'baseDomain': baseDomain,
      'storageDomain': storageDomain,
    };
  }
}
