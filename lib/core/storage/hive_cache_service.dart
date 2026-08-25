import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// High-performance local NoSQL document cache service powered by Hive.
/// Emulates Firebase/Firestore-style offline persistence for zero-latency app launch
/// and seamless resilience in offline or low-connectivity network conditions.
class HiveCacheService {
  static final HiveCacheService _instance = HiveCacheService._internal();
  factory HiveCacheService() => _instance;
  HiveCacheService._internal();

  static const String _boxName = 'leader_app_offline_cache';
  Box? _cacheBox;

  /// Initializes Hive storage and opens the primary document cache box.
  Future<void> init() async {
    try {
      await Hive.initFlutter();
      _cacheBox = await Hive.openBox(_boxName);
      if (kDebugMode) {
        debugPrint('📦 [HIVE CACHE] Offline cache initialized with ${_cacheBox?.length} cached documents.');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [HIVE CACHE] Initialization failed: $e');
      }
    }
  }

  /// Writes a JSON document or list to local offline storage.
  Future<void> put(String key, dynamic data) async {
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

  /// Retrieves a cached document from offline storage.
  dynamic get(String key) {
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
