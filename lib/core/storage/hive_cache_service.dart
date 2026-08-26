import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Local storage and document cache service.
/// Caching is currently DISABLED to ensure all views always fetch fresh, live API data.
class HiveCacheService {
  static final HiveCacheService _instance = HiveCacheService._internal();
  factory HiveCacheService() => _instance;
  HiveCacheService._internal();

  /// Global master toggle for caching. Set to false to bypass all local caches.
  static bool isCacheEnabled = false;

  static const String _boxName = 'leader_app_offline_cache';
  Box? _cacheBox;

  /// Initializes Hive storage and clears old residual cache boxes on startup.
  Future<void> init() async {
    try {
      await Hive.initFlutter();
      _cacheBox = await Hive.openBox(_boxName);
      // Always purge stale cached documents so app always requests live API data
      await _cacheBox?.clear();
      if (kDebugMode) {
        debugPrint('📦 [HIVE CACHE] Storage initialized. Live API mode active (caching disabled).');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [HIVE CACHE] Initialization: $e');
      }
    }
  }

  /// Writes a JSON document or list to local storage (disabled when isCacheEnabled == false).
  Future<void> put(String key, dynamic data) async {
    if (!isCacheEnabled) return;
    try {
      if (_cacheBox == null || !_cacheBox!.isOpen) {
        _cacheBox = await Hive.openBox(_boxName);
      }
      final payload = {
        'cached_at': DateTime.now().toIso8601String(),
        'payload': data,
      };
      await _cacheBox?.put(key, jsonEncode(payload));
      if (kDebugMode) {
        debugPrint('💾 [HIVE CACHE] Stored key: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [HIVE CACHE] Failed to write key "$key": $e');
      }
    }
  }

  /// Retrieves a cached document from offline storage (returns null when isCacheEnabled == false).
  dynamic get(String key) {
    if (!isCacheEnabled) return null;
    try {
      if (_cacheBox == null || !_cacheBox!.isOpen) return null;
      final raw = _cacheBox?.get(key);
      if (raw == null) return null;

      final decoded = jsonDecode(raw.toString());
      if (decoded is Map && decoded.containsKey('payload')) {
        return decoded['payload'];
      }
      return decoded;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [HIVE CACHE] Failed to read key "$key": $e');
      }
      return null;
    }
  }

  /// Type-safe getter that deserializes cached JSON with a model transformer.
  T? getModel<T>(String key, T Function(dynamic json) fromJson) {
    if (!isCacheEnabled) return null;
    final raw = get(key);
    if (raw == null) return null;
    try {
      return fromJson(raw);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [HIVE CACHE] Deserialization failed for "$key": $e');
      }
      return null;
    }
  }

  /// Deletes a specific cached document by key.
  Future<void> delete(String key) async {
    try {
      await _cacheBox?.delete(key);
    } catch (_) {}
  }

  /// Clears the entire offline cache.
  Future<void> clearAll() async {
    try {
      await _cacheBox?.clear();
      if (kDebugMode) {
        debugPrint('🧹 [HIVE CACHE] Offline cache cleared.');
      }
    } catch (_) {}
  }
}

