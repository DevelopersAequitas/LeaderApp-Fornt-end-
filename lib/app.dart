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
import 'package:flutter/services.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_colors.dart';

/// The root Widget of the Leader App.
/// Configures MaterialApp with routing, themes, and global settings.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peers Unity: Leader App',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'LibreFranklin',
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.cardBg,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.cardBg,
          foregroundColor: AppColors.text,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
            systemNavigationBarDividerColor: AppColors.border,
          ),
          iconTheme: IconThemeData(color: AppColors.text),
          titleTextStyle: TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
