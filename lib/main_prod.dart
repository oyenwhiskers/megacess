import 'package:flutter/material.dart';
import 'core/config/flavor_config.dart';
import 'main.dart';

void main() {
  FlavorConfig(
    flavor: Flavor.production,
    baseUrl: 'https://mwms.megacess.com/api/v1/',
    baseDomain: 'https://mwms.megacess.com',
    storageDomain: 'https://mwms.megacess.com',
    flavorName: 'Production',
  );

  mainCommon();
}
