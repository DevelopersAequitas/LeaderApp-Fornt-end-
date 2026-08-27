import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/api_endpoints.dart';
import '../models/app_config_model.dart';
import '../network/api_client.dart';

/// Singleton service managing app version validation, native store in-app updates, and maintenance mode.
class AppConfigService {
  static final AppConfigService _instance = AppConfigService._internal();
  factory AppConfigService() => _instance;
  AppConfigService._internal();

  static const String currentAppVersion = '1.0.0';

  AppConfigModel _config = const AppConfigModel();
  AppConfigModel get config => _config;

  /// Fetches system configuration and updates memory state.
  Future<AppConfigModel> fetchAppConfig() async {
    try {
      final response = await ApiClient().get<AppConfigModel>(
        ApiEndpoints.appConfig,
        fromJsonT: (json) => AppConfigModel.fromJson(json as Map<String, dynamic>),
      );
      if (response.data != null) {
        _config = response.data!;
      }
    } catch (_) {}
    return _config;
  }

  /// Compares two semver strings (returns -1 if v1 < v2, 0 if v1 == v2, 1 if v1 > v2).
  int compareVersions(String v1, String v2) {
    try {
      final v1Parts = v1.split('.').map((p) => int.tryParse(p) ?? 0).toList();
      final v2Parts = v2.split('.').map((p) => int.tryParse(p) ?? 0).toList();
      for (int i = 0; i < 3; i++) {
        final p1 = i < v1Parts.length ? v1Parts[i] : 0;
        final p2 = i < v2Parts.length ? v2Parts[i] : 0;
        if (p1 < p2) return -1;
        if (p1 > p2) return 1;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  bool isForceUpdateRequired([String current = currentAppVersion]) {
    return compareVersions(current, _config.minRequiredVersion) < 0;
  }

  bool isOptionalUpdateAvailable([String current = currentAppVersion]) {
    return !isForceUpdateRequired(current) && compareVersions(current, _config.latestVersion) < 0;
  }

  bool isUnderMaintenance(String userRole) {
    if (!_config.isMaintenanceMode) return false;
    final normalized = userRole.toLowerCase().replaceAll('_', '').replaceAll(' ', '');
    for (final bypass in _config.allowedBypassRoles) {
      if (bypass.toLowerCase().replaceAll('_', '').replaceAll(' ', '') == normalized) {
        return false;
      }
    }
    return true;
  }

  /// Triggers the native store update flow adhering strictly to platform guidelines:
  /// - Android: Uses Google Play In-App Updates (`performImmediateUpdate` or `startFlexibleUpdate`)
  /// - iOS: Uses direct Apple App Store launcher or Upgrader (since iOS does not support in-app binary updates)
  Future<void> triggerNativeStoreUpdate({required bool isForce}) async {
    // 1. Android Native Play Store Flow
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final info = await InAppUpdate.checkForUpdate();
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          if (isForce && info.immediateUpdateAllowed) {
            await InAppUpdate.performImmediateUpdate();
            return;
          } else if (!isForce && info.flexibleUpdateAllowed) {
            final status = await InAppUpdate.startFlexibleUpdate();
            if (status == AppUpdateResult.success) {
              await InAppUpdate.completeFlexibleUpdate();
            }
            return;
          }
        }
      } catch (e) {
        debugPrint('InAppUpdate (Android) handled error/fallback: $e');
      }
    }

    // 2. iOS Native Apple App Store & Fallback Flow
    final storeUrl = (!kIsWeb && Platform.isIOS) ? _config.storeUrlIos : _config.storeUrlAndroid;
    try {
      final uri = Uri.parse(storeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Store launch error: $e');
    }
  }
}
