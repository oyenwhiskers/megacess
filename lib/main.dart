import 'package:flutter/material.dart';
import 'modules/authorization/data/service/auth_service.dart';
import 'modules/authorization/view/login_view.dart';
import 'modules/authorization/view/role_home.dart';
import 'dart:async';

import 'core/config/flavor_config.dart';
import 'core/config/env_config.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';

void main() {
  // Initialize FlavorConfig using centralized AppConfig
  // To switch environments, change the ENV constant in env_config.dart
  FlavorConfig(
    flavor: AppConfig.isProduction
        ? Flavor.production
        : AppConfig.isLocal
            ? Flavor.local
            : Flavor.staging,
    baseUrl: AppConfig.apiUrl,
    baseDomain: AppConfig.baseDomain,
    storageDomain: AppConfig.storageDomain,
    flavorName: AppConfig.environmentName,
  );

  // Log current configuration for debugging
  AppConfig.logConfiguration();

  mainCommon();
}

void mainCommon() {
  // Comprehensive error suppression to prevent red screens
  runZonedGuarded(
    () {
      // Set up global error handlers before running the app
      FlutterError.onError = (FlutterErrorDetails details) {
        final String errorString = details.exception.toString().toLowerCase();
        final String stackString = details.stack.toString().toLowerCase();

        // Suppress all dialog/disposal related errors
        if (errorString.contains('_dependents') ||
            errorString.contains('dependents.isempty') ||
            errorString.contains('assertion') ||
            errorString.contains('failed') ||
            stackString.contains('dispose') ||
            stackString.contains('modalscope') ||
            stackString.contains('navigator') ||
            stackString.contains('framework.dart') ||
            stackString.contains('widgets') ||
            details.library?.contains('flutter') == true) {
          // Log for debugging but don't show to user
          print(
            'Suppressed Flutter error: ${errorString.length > 50 ? errorString.substring(0, 50) : errorString}...',
          );
          return;
        }

        // For other errors, use default handler
        FlutterError.presentError(details);
      };

      runApp(const MyApp());
    },
    (error, stack) {
      // Catch any uncaught errors in the error zone
      print('Caught error in zone: $error\n$stack');
    },
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MegaCess',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  bool _checking = true;
  bool _loggedIn = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  void _checkLogin() async {
    final role = await AuthService().restoreSessionRole();
    if (!mounted) return;
    setState(() {
      _loggedIn = role != null;
      _userRole = role;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: AppColors.mcBgApp,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.frond6),
        ),
      );
    }
    if (_loggedIn && _userRole != null) {
      return homeForRole(_userRole!) ?? const LoginView();
    }
    return const LoginView();
  }
}
