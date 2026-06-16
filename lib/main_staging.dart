import 'core/config/flavor_config.dart';
import 'main.dart';

void main() {
  FlavorConfig(
    flavor: Flavor.staging,
    baseUrl: 'https://mwmsdemo.megacess.com/api/v1/',
    baseDomain: 'https://mwmsdemo.megacess.com',
    storageDomain: 'https://mwmsdemo.megacess.com',
    flavorName: 'Staging',
  );

  mainCommon();
}
