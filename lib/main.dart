import 'package:flutter/material.dart';
import 'package:leaderapp/app.dart';
import 'core/storage/hive_cache_service.dart';
import 'core/helpers/session_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive offline document cache
  await HiveCacheService().init();

  // Restore authenticated user session if present
  await SessionManager().loadPersistedSession();

  runApp(const App());
}
