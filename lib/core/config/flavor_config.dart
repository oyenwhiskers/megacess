enum Flavor { production, staging, local }

class FlavorConfig {
  final Flavor flavor;
  final String baseUrl;
  final String baseDomain;
  final String storageDomain;
  final String flavorName;

  static FlavorConfig? _instance;

  factory FlavorConfig({
    required Flavor flavor,
    required String baseUrl,
    required String baseDomain,
    required String storageDomain,
    String flavorName = '',
  }) {
    _instance ??= FlavorConfig._internal(
      flavor,
      baseUrl,
      baseDomain,
      storageDomain,
      flavorName,
    );
    return _instance!;
  }

  FlavorConfig._internal(
    this.flavor,
    this.baseUrl,
    this.baseDomain,
    this.storageDomain,
    this.flavorName,
  );

  static FlavorConfig get instance {
    return _instance!;
  }

  static bool isProduction() => _instance?.flavor == Flavor.production;
  static bool isStaging() => _instance?.flavor == Flavor.staging;
  static bool isLocal() => _instance?.flavor == Flavor.local;
}
