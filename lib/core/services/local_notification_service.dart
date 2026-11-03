// ==============================================================================
// File: lib/core/services/local_notification_service.dart
// Description: Local Notifications Service for Foreground Heads-Up Alerts
// Framework: Flutter | Package: flutter_local_notifications
// ==============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../routes/app_routes.dart';
import 'push_notification_service.dart';

/// Top-level background tap handler for local notifications (must be entry-point)
@pragma('vm:entry-point')
void notificationTapBackgroundHandler(NotificationResponse response) {
  debugPrint('🔔 [LocalNotificationService] Background tap: ${response.payload}');
}

/// Service managing foreground system notification popups and notification channels.
class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'leader_high_importance_channel';
  static const String channelName = 'Leader App Notifications';
  static const String channelDescription =
      'Real-time leadership updates, approvals, performance, and circular alerts';

  bool _isInitialized = false;

  /// Initializes local notifications with platform settings and high-priority channels
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Android Initialization Settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // 2. iOS / Darwin Initialization Settings
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      // 3. Initialize plugin
      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
        onDidReceiveBackgroundNotificationResponse:
            notificationTapBackgroundHandler,
      );

      // 4. Create Android Notification Channels (creates all possible channels to avoid OS drop)
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // Leader Channel
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDescription,
            importance: Importance.max,
            enableVibration: true,
            playSound: true,
          ),
        );

        // Peers Unity Woodblock Channel (Default channel sent by backend)
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'peers_unity_notifications_woodblock',
            'Peers Global Notifications',
            description: 'Peers Unity notification channel',
            importance: Importance.max,
            enableVibration: true,
            playSound: true,
          ),
        );

        // High Importance Channel
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'high_importance_channel',
            'High Importance Notifications',
            description: 'Emergency and critical alerts',
            importance: Importance.max,
            enableVibration: true,
            playSound: true,
          ),
        );
      }

      _isInitialized = true;
      debugPrint('🔔 [LocalNotificationService] Initialized successfully with all notification channels');
    } catch (e, st) {
      debugPrint('❌ [LocalNotificationService] Initialization error: $e\n$st');
    }
  }

  /// Displays a system heads-up notification while the app is in the foreground
  Future<void> showNotification({
    int? id,
    required String title,
    required String body,
    String? payload,
    String? customChannelId,
  }) async {
    try {
      final notificationId = id ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);
      final activeChannel = customChannelId ?? channelId;

      final androidDetails = AndroidNotificationDetails(
        activeChannel,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _localNotifications.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );

      debugPrint('🔔 [LocalNotificationService] Showed notification: "$title" on channel: "$activeChannel"');
    } catch (e, st) {
      debugPrint('❌ [LocalNotificationService] Failed to show notification: $e\n$st');
    }
  }

  /// Handles notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payloadString = response.payload;
    debugPrint('🔔 [LocalNotificationService] Foreground notification tapped. Payload: $payloadString');

    if (payloadString != null && payloadString.isNotEmpty) {
      try {
        final data = jsonDecode(payloadString);
        if (data is Map<String, dynamic>) {
          PushNotificationService.instance.routeFromNotificationData(data);
          return;
        }
      } catch (_) {}
    }

    // Default route
    AppRoutes.navigatorKey.currentState?.pushNamed(AppRoutes.notifications);
  }
}
