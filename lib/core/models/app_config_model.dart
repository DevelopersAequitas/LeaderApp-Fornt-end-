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
        'We are currently performing essential infrastructure upgrades. Please check back shortly.',
    this.forceUpdateTitle = 'App Update Required',
    this.forceUpdateMessage =
        'A critical new version of Peers Leader is required to continue. Please update the app from the store.',
    this.optionalUpdateTitle = 'New Update Available',
    this.optionalUpdateMessage =
        'A new version is available with enhanced features and performance improvements.',
    this.storeUrlAndroid =
        'https://play.google.com/store/apps/details?id=com.unity.leadersapp',
    this.storeUrlIos = 'https://apps.apple.com/app/peers-leader/id123456789',
    this.allowedBypassRoles = const ['superAdmin', 'super_admin'],
  });

  factory AppConfigModel.fromJson(Map<String, dynamic> json) {
    final bypassList = <String>[];
    final rawRoles = json['allowed_bypass_roles'] ?? json['allowedBypassRoles'];
    if (rawRoles is List) {
      for (final r in rawRoles) {
        bypassList.add(r.toString());
      }
    } else {
      bypassList.addAll(['superAdmin', 'super_admin']);
    }

    final rawAndroidUrl = json['store_url_android'] as String? ??
        json['storeUrlAndroid'] as String?;
    final rawIosUrl = json['store_url_ios'] as String? ??
        json['storeUrlIos'] as String?;

    return AppConfigModel(
      minRequiredVersion: json['min_required_version'] as String? ??
          json['minRequiredVersion'] as String? ??
          '1.0.0',
      latestVersion: json['latest_version'] as String? ??
          json['latestVersion'] as String? ??
          '1.0.0',
      isMaintenanceMode: json['is_maintenance_mode'] as bool? ??
          json['isMaintenanceMode'] as bool? ??
          json['maintenance_mode'] as bool? ??
          false,
      maintenanceTitle: json['maintenance_title'] as String? ??
          json['maintenanceTitle'] as String? ??
          'System Under Maintenance',
      maintenanceMessage: json['maintenance_message'] as String? ??
          json['maintenanceMessage'] as String? ??
          'We are currently performing essential infrastructure upgrades. Please check back shortly.',
      forceUpdateTitle: json['force_update_title'] as String? ??
          json['forceUpdateTitle'] as String? ??
          'App Update Required',
      forceUpdateMessage: json['force_update_message'] as String? ??
          json['forceUpdateMessage'] as String? ??
          'A critical new version of Peers Leader is required to continue. Please update the app from the store.',
      optionalUpdateTitle: json['optional_update_title'] as String? ??
          json['optionalUpdateTitle'] as String? ??
          'New Update Available',
      optionalUpdateMessage: json['optional_update_message'] as String? ??
          json['optionalUpdateMessage'] as String? ??
          'A new version is available with enhanced features and performance improvements.',
      storeUrlAndroid: (rawAndroidUrl != null && rawAndroidUrl.isNotEmpty)
          ? rawAndroidUrl
          : 'https://play.google.com/store/apps/details?id=com.unity.leadersapp',
      storeUrlIos: (rawIosUrl != null && rawIosUrl.isNotEmpty)
          ? rawIosUrl
          : 'https://apps.apple.com/app/peers-leader/id123456789',
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
