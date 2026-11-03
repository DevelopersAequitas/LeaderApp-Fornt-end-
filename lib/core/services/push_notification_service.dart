// ==============================================================================
// File: lib/core/services/push_notification_service.dart
// Description: Centralized Push Notification Service (FCM & System Heads-Up Alerts)
// Framework: Flutter | Package: firebase_messaging & permission_handler
// ==============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../firebase_options.dart';
import '../constants/api_endpoints.dart';
import '../helpers/session_manager.dart';
import '../network/api_client.dart';
import '../routes/app_routes.dart';
import '../storage/secure_storage_service.dart';
import 'local_notification_service.dart';
import 'notification_count_service.dart';
import 'top_banner_notification_service.dart';

/// Top-level background message handler required by Firebase Messaging
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
  debugPrint('📲 [PushNotificationService] Background message received: ${message.messageId}');

  // If the message has no system notification block, trigger heads-up local notification
  if (message.notification == null && message.data.isNotEmpty) {
    try {
      await LocalNotificationService.instance.initialize();
      final title = message.data['title']?.toString() ?? 'Leader Alert';
      final body = message.data['body']?.toString() ?? message.data['message']?.toString() ?? '';
      if (title.isNotEmpty || body.isNotEmpty) {
        await LocalNotificationService.instance.showNotification(
          title: title,
          body: body,
          payload: jsonEncode(message.data),
        );
      }
    } catch (_) {}
  }
}

/// Central Push Notification Service managing FCM token lifecycle, permissions,
/// foreground presentation with local notifications, and background/terminated tap handling.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  String? _cachedFcmToken;
  String? _lastSyncedToken;

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;
  StreamSubscription<String>? _tokenSubscription;

  /// Initializes Firebase Core, Messaging, Local Notifications and registers handlers.
  /// Designed to be lightweight and non-blocking so app launch performance is unaffected.
  Future<void> initialize() async {
    try {
      // 1. Ensure Firebase App is initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      // 2. Set background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 3. Initialize Local Notification Service (for heads-up foreground banners)
      await LocalNotificationService.instance.initialize();

      // 4. Request Permissions asynchronously
      unawaited(requestNotificationPermissions());

      // 5. Configure iOS foreground presentation options
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 6. Listen to foreground messages (always re-hook active stream listener)
      await _foregroundSubscription?.cancel();
      _foregroundSubscription = FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // 7. Handle notification tapped while app is in background
      await _openedAppSubscription?.cancel();
      _openedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

      // 8. Handle notification that launched the app from terminated state
      unawaited(_checkInitialMessage());

      // 9. Listen to token registration / refresh events
      await _tokenSubscription?.cancel();
      _tokenSubscription = _messaging.onRegistered.listen((token) {
        debugPrint('🔄 [PushNotificationService] FCM Token received via onRegistered: $token');
        _cachedFcmToken = token;
        unawaited(syncTokenWithBackend(token, true));
      });

      // 10. Fetch token and sync with backend in BACKGROUND (zero blocking on app startup)
      unawaited(_backgroundTokenLifecycle());

      debugPrint('🚀 [PushNotificationService] Push notification system initialized successfully');
    } catch (e, st) {
      debugPrint('❌ [PushNotificationService] Failed to initialize push notifications: $e\n$st');
    }
  }

  /// Checks if the app was launched by tapping a push notification from terminated state
  Future<void> _checkInitialMessage() async {
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _onMessageOpenedApp(initialMessage);
      }
    } catch (e) {
      debugPrint('⚠️ [PushNotificationService] Error checking initial message: $e');
    }
  }

  /// Runs token registration and backend synchronization in background without delaying startup
  Future<void> _backgroundTokenLifecycle() async {
    try {
      // Register device with FCM to trigger onRegistered
      try {
        await _messaging.register();
      } catch (_) {}

      // Fallback: fetch directly
      await fetchAndRegisterFcmToken();
    } catch (e) {
      debugPrint('⚠️ [PushNotificationService] Background token lifecycle error: $e');
    }
  }

  /// Explicitly requests notification permissions across Android (API 33+) and iOS
  Future<bool> requestNotificationPermissions() async {
    try {
      // Android 13+ (API 33+) explicit runtime permission
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          final result = await Permission.notification.request();
          debugPrint('📱 [PushNotificationService] Android POST_NOTIFICATIONS status: $result');
        }
      }

      // Firebase Messaging standard request (iOS and general)
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final isAuthorized = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      debugPrint('📱 [PushNotificationService] Permission status: ${settings.authorizationStatus}');
      return isAuthorized;
    } catch (e) {
      debugPrint('⚠️ [PushNotificationService] Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Fetches the device FCM token and registers it with the backend if user is logged in
  Future<String?> fetchAndRegisterFcmToken() async {
    try {
      // ignore: deprecated_member_use
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        _cachedFcmToken = token;
        debugPrint('🔑 [PushNotificationService] FCM Token: $token');
        await syncTokenWithBackend(token);
      }
      return token;
    } catch (e) {
      debugPrint('⚠️ [PushNotificationService] Error fetching FCM token: $e');
      return null;
    }
  }

  /// Sends the FCM device token to the server push endpoints in the background.
  /// Tags the payload with `app: 'leader'` and `device_id: 'leader_...'` to prevent
  /// clobbering or overwriting tokens from the separate Peers Global member app.
  Future<void> syncTokenWithBackend([String? token, bool force = false]) async {
    final fcmToken = token ?? _cachedFcmToken;
    if (fcmToken == null || fcmToken.isEmpty) return;

    // Check if user is authenticated
    if (!SessionManager().isAuthenticated) {
      debugPrint('ℹ️ [PushNotificationService] Skipping token sync: user not authenticated yet');
      return;
    }

    if (!force && _lastSyncedToken == fcmToken) {
      debugPrint('ℹ️ [PushNotificationService] Token already synced with backend for this session');
      return;
    }

    try {
      final platform = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'unknown');
      final rawDeviceId = await _getOrCreateDeviceId();
      final leaderDeviceId = rawDeviceId.startsWith('leader_') ? rawDeviceId : 'leader_$rawDeviceId';

      final payload = {
        'token': fcmToken,
        'fcm_token': fcmToken,
        'platform': platform,
        'device_id': leaderDeviceId,
        'app': 'leader',
        'app_type': 'leader',
        'app_name': 'leader_app',
        'app_version': '1.0.0',
      };

      // 1. Primary: Dedicated Leader Endpoint /leader/push-token
      try {
        await ApiClient().dio.post(
          ApiEndpoints.leaderPushTokenRegistration,
          data: payload,
        );
        _lastSyncedToken = fcmToken;
        debugPrint('✅ [PushNotificationService] Push token synced to dedicated endpoint: ${ApiEndpoints.leaderPushTokenRegistration}');
        return;
      } catch (e) {
        debugPrint('ℹ️ [PushNotificationService] Primary leader push-token endpoint skipped or failed, trying fallback: $e');
      }

      // 2. Secondary fallback endpoint: /user/push-token (with 'app: leader' & 'leader_' deviceId prefix)
      try {
        await ApiClient().dio.post(
          ApiEndpoints.pushTokenRegistration,
          data: payload,
        );
        _lastSyncedToken = fcmToken;
        debugPrint('✅ [PushNotificationService] Push token synced to ${ApiEndpoints.pushTokenRegistration}');
      } catch (e) {
        debugPrint('⚠️ [PushNotificationService] Failed syncing to pushTokenRegistration: $e');
      }

      // 3. Central fallback endpoint: /push-tokens
      try {
        await ApiClient().dio.post(
          ApiEndpoints.pushTokens,
          data: payload,
        );
        debugPrint('✅ [PushNotificationService] Push token synced to ${ApiEndpoints.pushTokens}');
      } catch (_) {}
    } catch (e) {
      debugPrint('❌ [PushNotificationService] Unexpected error syncing push token: $e');
    }
  }

  /// Handles incoming push notification when app is in FOREGROUND.
  /// Displays a native OS heads-up system notification banner at the top of the screen.
  /// Strictly NEVER renders any in-app Flutter SnackBar.
  void _onForegroundMessage(RemoteMessage message) {
    debugPrint('📩 [PushNotificationService] Foreground Push Message: ${message.messageId}');

    // Extract title & body
    final title = message.notification?.title ??
        message.data['title']?.toString() ??
        'Leader Alert';

    final body = message.notification?.body ??
        message.data['body']?.toString() ??
        message.data['message']?.toString() ??
        '';

    final payloadString = jsonEncode(message.data);

    // Trigger local notification system heads-up popup
    LocalNotificationService.instance.showNotification(
      title: title,
      body: body,
      payload: payloadString,
    );

    // Display sleek top-sliding in-app heads-up banner (never overlaps bottom navigation)
    TopBannerNotificationService.instance.show(
      title: title,
      message: body,
      onTap: () {
        routeFromNotificationData(message.data);
      },
    );

    // Increment notification unread count dynamically
    NotificationCountService.instance.unreadCount.value =
        NotificationCountService.instance.unreadCount.value + 1;
  }

  /// Handles notification tap when app is backgrounded or terminated
  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('🚀 [PushNotificationService] Opened app from push notification: ${message.data}');
    routeFromNotificationData(message.data);
  }

  /// Routes to target screen based on notification payload
  void routeFromNotificationData(Map<String, dynamic> data) {
    final rawTarget = (data['route'] ?? data['screen'] ?? data['click_action'])?.toString().trim();
    if (rawTarget == null || rawTarget.isEmpty) {
      AppRoutes.navigatorKey.currentState?.pushNamed(AppRoutes.notifications);
      return;
    }

    final target = rawTarget.toLowerCase();
    if (target.contains('team') || target.contains('circle')) {
      AppRoutes.navigatorKey.currentState?.pushNamed(AppRoutes.home, arguments: {'tab': 2});
    } else if (target.contains('finance')) {
      AppRoutes.navigatorKey.currentState?.pushNamed(AppRoutes.home, arguments: {'tab': 3});
    } else if (target.contains('report')) {
      AppRoutes.navigatorKey.currentState?.pushNamed(AppRoutes.home, arguments: {'tab': 4});
    } else if (target.contains('peer')) {
      AppRoutes.navigatorKey.currentState?.pushNamed(AppRoutes.home, arguments: {'tab': 1});
    } else if (target.contains('profile')) {
      AppRoutes.navigatorKey.currentState?.pushNamed(AppRoutes.profile);
    } else if (target.contains('notification')) {
      AppRoutes.navigatorKey.currentState?.pushNamed(AppRoutes.notifications);
    } else if (target == '/dashboard' || target == 'dashboard') {
      AppRoutes.navigatorKey.currentState?.pushNamed(AppRoutes.home, arguments: {'tab': 0});
    } else {
      AppRoutes.navigatorKey.currentState?.pushNamed(rawTarget);
    }
  }

  /// Generates or retrieves a persistent device identifier
  Future<String> _getOrCreateDeviceId() async {
    try {
      final savedId = await SecureStorageService().getAuthToken();
      if (savedId != null && savedId.isNotEmpty) {
        return 'device_${savedId.hashCode.abs()}';
      }
    } catch (_) {}
    return 'device_${Platform.operatingSystem}_${DateTime.now().millisecondsSinceEpoch}';
  }
}
