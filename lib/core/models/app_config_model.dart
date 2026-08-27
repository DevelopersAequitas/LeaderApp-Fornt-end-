/// Model representing remote system configurations, version requirements, and maintenance states.
class AppConfigModel {
  final String minRequiredVersion;
  final String latestVersion;
  final bool isMaintenanceMode;
  final String maintenanceTitle;
  final String maintenanceMessage;
  final String forceUpdateTitle;
  final String forceUpdateMessage;
  final String optionalUpdateTitle;
  final String optionalUpdateMessage;
  final String storeUrlAndroid;
  final String storeUrlIos;
  final List<String> allowedBypassRoles;

  const AppConfigModel({
    this.minRequiredVersion = '1.0.0',
    this.latestVersion = '1.0.0',
    this.isMaintenanceMode = false,
    this.maintenanceTitle = 'System Under Maintenance',
    this.maintenanceMessage =
        'We are currently performing essential system upgrades to enhance your experience. Please check back shortly.',
    this.forceUpdateTitle = 'App Update Required',
    this.forceUpdateMessage =
        'A critical new version of Leader App is available. Please update to continue using the application.',
    this.optionalUpdateTitle = 'New Update Available',
    this.optionalUpdateMessage =
        'A new version with performance improvements and new features is available.',
    this.storeUrlAndroid = 'https://play.google.com/store/apps/details?id=com.unity.leadersapp',
    this.storeUrlIos = 'https://apps.apple.com/app/leader-app/id123456789',
    this.allowedBypassRoles = const ['superAdmin', 'super_admin'],
  });

  factory AppConfigModel.fromJson(Map<String, dynamic> json) {
    final bypassList = <String>[];
    if (json['allowed_bypass_roles'] is List) {
      for (final r in json['allowed_bypass_roles']) {
        bypassList.add(r.toString());
      }
    } else {
      bypassList.addAll(['superAdmin', 'super_admin']);
    }

    return AppConfigModel(
      minRequiredVersion: json['min_required_version'] as String? ?? '1.0.0',
      latestVersion: json['latest_version'] as String? ?? '1.0.0',
      isMaintenanceMode: json['is_maintenance_mode'] as bool? ?? json['maintenance_mode'] as bool? ?? false,
      maintenanceTitle: json['maintenance_title'] as String? ?? 'System Under Maintenance',
      maintenanceMessage: json['maintenance_message'] as String? ??
          'We are currently performing essential system upgrades. Please check back shortly.',
      forceUpdateTitle: json['force_update_title'] as String? ?? 'App Update Required',
      forceUpdateMessage: json['force_update_message'] as String? ??
          'A critical new version of Leader App is available. Please update to continue.',
      optionalUpdateTitle: json['optional_update_title'] as String? ?? 'New Update Available',
      optionalUpdateMessage: json['optional_update_message'] as String? ??
          'A new version with performance improvements is available.',
      storeUrlAndroid: json['store_url_android'] as String? ??
          'https://play.google.com/store/apps/details?id=com.unity.leadersapp',
      storeUrlIos: json['store_url_ios'] as String? ??
          'https://apps.apple.com/app/leader-app/id123456789',
      allowedBypassRoles: bypassList,
    );
  }

  Map<String, dynamic> toJson() => {
        'min_required_version': minRequiredVersion,
        'latest_version': latestVersion,
        'is_maintenance_mode': isMaintenanceMode,
        'maintenance_title': maintenanceTitle,
        'maintenance_message': maintenanceMessage,
        'force_update_title': forceUpdateTitle,
        'force_update_message': forceUpdateMessage,
        'optional_update_title': optionalUpdateTitle,
        'optional_update_message': optionalUpdateMessage,
        'store_url_android': storeUrlAndroid,
        'store_url_ios': storeUrlIos,
        'allowed_bypass_roles': allowedBypassRoles,
      };
}
