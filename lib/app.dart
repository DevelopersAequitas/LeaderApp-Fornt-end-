// ==============================================================================
// File: lib/app.dart
// Description: Root Application Widget & Global Route Configurator
// Framework: Flutter Material 3 | Architecture: Central Navigation Container
// Responsibilities:
//   - Configures global `MaterialApp` theme tokens and brightness system
//   - Connects centralized dynamic routing dispatcher via `AppRoutes.onGenerateRoute`
//   - Defines initial launch route pointing to `SplashView`
// ==============================================================================

import 'package:flutter/material.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

/// The root Widget of the Leader App.
/// Configures MaterialApp with routing, enterprise themes, and global settings.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peers Unity: Leader App',
      debugShowCheckedModeBanner: false,
      navigatorKey: AppRoutes.navigatorKey,
      themeMode: ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
