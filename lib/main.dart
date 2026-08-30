// ==============================================================================
// File: lib/main.dart
// Description: Application Bootstrap & Initialization Entry Point
// Framework: Flutter | Architecture: Model-View-Presenter (MVP) + BLoC
// Responsibilities:
//   - Initializes core Flutter bindings (`WidgetsFlutterBinding.ensureInitialized`)
//   - Configures Hive offline key-value storage and cache subsystems
//   - Restores persisted cryptographic session tokens and active user profile
//   - Prints developer diagnostics and active REST environment configuration
//   - Mounts the root `App` widget tree
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leaderapp/app.dart';
import 'core/storage/hive_cache_service.dart';
import 'core/helpers/session_manager.dart';
import 'core/constants/api_endpoints.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive offline document cache
  await HiveCacheService().init();

  // Restore authenticated user session if present
  await SessionManager().loadPersistedSession();

  if (kDebugMode) {
    debugPrint('🚀 [LeaderApp] Running in DEBUG mode (package: com.unity.leadersapp.dev)');
    debugPrint('🌐 [LeaderApp] Active Base URL: ${ApiEndpoints.baseUrl} (${ApiEndpoints.activeEnvironment.name})');
  }

  runApp(const App());
}
