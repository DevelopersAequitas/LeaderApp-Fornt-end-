// ==============================================================================
// File: lib/main.dart
// Description: Application Bootstrap & Initialization Entry Point
// Framework: Flutter | Architecture: Model-View-Presenter (MVP) + BLoC
// Responsibilities:
//   - Initializes core Flutter bindings (`WidgetsFlutterBinding.ensureInitialized`)
//   - Configures Hive offline key-value storage and pre-loads `splash.json` Lottie composition
//   - Restores persisted cryptographic session tokens and active user profile
//   - Prints developer diagnostics and active REST environment configuration
//   - Mounts the root `App` widget tree
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leaderapp/app.dart';
import 'package:lottie/lottie.dart';
import 'core/constants/api_endpoints.dart';
import 'core/helpers/session_manager.dart';
import 'core/storage/hive_cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize Hive offline document cache and pre-load splash Lottie animation concurrently
  await Future.wait([
    HiveCacheService().init(),
    AssetLottie('assets/animations/splash.json').load(),
  ]);

  // Restore authenticated user session if present
  await SessionManager().loadPersistedSession();

  if (kDebugMode) {
    debugPrint(
      '🚀 [LeaderApp] Running in DEBUG mode (package: com.unity.leadersapp.dev)',
    );
    debugPrint(
      '🌐 [LeaderApp] Active Base URL: ${ApiEndpoints.baseUrl} (${ApiEndpoints.activeEnvironment.name})',
    );
  }

  runApp(const App());
}
