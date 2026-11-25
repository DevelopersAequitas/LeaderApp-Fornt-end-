import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/leader_permissions.dart';
import 'notification_destination.dart';

/// The only thing the navigator needs from the real `NavigatorState`.
abstract class NotificationNavTarget {
  /// `true` once a Navigator exists (the app widget tree is mounted).
  bool get isAvailable;

  Future<void> pushNamed(String route, {Object? arguments});
}

/// Opens notification destinations safely.
///
/// A tap is **never** acted on until all of these hold:
///  1. a Navigator exists (the app tree is mounted),
///  2. the leader is authenticated, and
///  3. the home shell reported it is ready ([markReady]) — i.e. splash, session
///     restore and the maintenance/update gate are finished.
/// Until then the latest tap is kept as a *pending* destination (cold start,
/// background launch, or a tap while signed out) and opened exactly once as
/// soon as the conditions are met. A pending tap older than [pendingTtl] is
/// discarded so a stale notification can never surprise a later session.
///
/// Opening a Circle or Report fetches it by id first; a missing/deleted entity
/// and an unauthorised destination show a message and fall back to the
/// Notifications feed instead of a broken screen.
class NotificationNavigator {
  NotificationNavigator({
    required this.target,
    required this.isAuthenticated,
    required this.permissions,
    required this.resolveCircle,
    required this.resolveReport,
    required this.showMessage,
    DateTime Function()? now,
    this.pendingTtl = const Duration(minutes: 15),
    this.duplicateWindow = const Duration(seconds: 2),
    this.homeRoute = '/home',
    this.peerProfileRoute = '/peer-profile',
    this.circleDetailsRoute = '/circle-details',
    this.reportDetailsRoute = '/report-details',
    this.profileRoute = '/profile',
    this.roleManagementRoute = '/role-management',
    this.notificationsRoute = '/notifications',
    this.leaderActivitiesRoute = '/leader-activities',
    this.circularsRoute = '/circulars',
    this.circleEventsRoute = '/circle-events',
    this.businessDealsRoute = '/business-deals',
    this.peerCollaborationRoute = '/peer-collaboration',
  }) : _now = now ?? DateTime.now;

  final NotificationNavTarget target;
  final bool Function() isAuthenticated;
  final LeaderPermissions Function() permissions;

  /// Fetch a Circle/Report by id. Return `null` when it does not exist (any
  /// more) or cannot be loaded.
  final Future<Object?> Function(String circleId) resolveCircle;
  final Future<Object?> Function(String reportId) resolveReport;

  final void Function(String message) showMessage;

  final Duration pendingTtl;
  final Duration duplicateWindow;
  final String homeRoute;
  final String peerProfileRoute;
  final String circleDetailsRoute;
  final String reportDetailsRoute;
  final String profileRoute;
  final String roleManagementRoute;
  final String notificationsRoute;
  final String leaderActivitiesRoute;
  final String circularsRoute;
  final String circleEventsRoute;
  final String businessDealsRoute;
  final String peerCollaborationRoute;

  final DateTime Function() _now;

  bool _ready = false;
  _Pending? _pending;
  String? _lastKey;
  DateTime? _lastAt;

  /// Whether a tap is waiting for authentication/readiness.
  bool get hasPending => _pending != null;

  /// Entry point for every notification tap (foreground local notification,
  /// background tap, cold-start `getInitialMessage`, and a tap in the feed).
  ///
  /// [openFeedWhenUnknown]: push taps open the feed when the payload names no
  /// screen; a tap inside the feed itself should just mark the item read.
  void handle(
    Map<String, dynamic> data, {
    bool openFeedWhenUnknown = true,
  }) {
    final payload = NotificationPayload.fromMap(data);
    final request = _Pending(payload, openFeedWhenUnknown, _now());

    if (!_canNavigateNow) {
      _pending = request; // latest tap wins
      return;
    }
    unawaited(_open(request));
  }

  /// Called by the home shell once it is mounted (after splash/login). Opens a
  /// pending tap, if any, exactly once.
  void markReady() {
    _ready = true;
    _flush();
  }

  /// Marks the app as not ready (e.g. after sign-out) and drops a pending tap.
  void reset() {
    _ready = false;
    _pending = null;
  }

  bool get _canNavigateNow =>
      _ready && target.isAvailable && isAuthenticated();

  void _flush() {
    final p = _pending;
    if (p == null) return;
    if (!_canNavigateNow) return;
    _pending = null;
    if (_now().difference(p.createdAt) > pendingTtl) return; // stale: discard
    unawaited(_open(p));
  }

  Future<void> _open(_Pending request) async {
    // Ignore a duplicate delivery of the same tap (e.g. FCM + local tap).
    final key = '${request.payload.target}|${request.payload.type}|'
        '${request.payload.category}|${request.payload.entityType}|'
        '${request.payload.entityId}';
    final now = _now();
    if (_lastKey == key &&
        _lastAt != null &&
        now.difference(_lastAt!) < duplicateWindow) {
      return;
    }
    _lastKey = key;
    _lastAt = now;

    final destination = request.payload.destination;

    if (!isDestinationAllowed(destination, permissions())) {
      showMessage('You do not have access to that screen.');
      await target.pushNamed(notificationsRoute);
      return;
    }

    switch (destination) {
      case NoDestination():
        if (request.openFeedWhenUnknown) {
          await target.pushNamed(notificationsRoute);
        }
      case NotificationsFeedDestination():
        await target.pushNamed(notificationsRoute);
      case ProfileDestination():
        await target.pushNamed(profileRoute);
      case RoleManagementDestination(:final roleId):
        await target.pushNamed(
          roleManagementRoute,
          arguments: roleId != null ? {'role_id': roleId} : null,
        );
      case HomeTabDestination(:final tab):
        await target.pushNamed(homeRoute, arguments: {'tab': tab});
      case PeerProfileDestination(:final peerId):
        await target.pushNamed(peerProfileRoute, arguments: peerId);
      case CircleDetailsDestination(:final circleId):
        await _openResolved(
          await _safeResolve(resolveCircle, circleId),
          circleDetailsRoute,
          'That Circle is no longer available.',
        );
      case ReportDetailsDestination(:final reportId):
        await _openResolved(
          await _safeResolve(resolveReport, reportId),
          reportDetailsRoute,
          'That report is no longer available.',
        );
      case ActionCenterDestination(
          :final approvalId,
          :final category,
          :final activityType,
          :final circleId,
        ):
        await target.pushNamed(
          leaderActivitiesRoute,
          arguments: {
            if (approvalId != null) 'approval_id': approvalId,
            if (category != null) 'category': category,
            if (activityType != null) 'type': activityType,
            if (circleId != null) 'circle_id': circleId,
          },
        );
      case CircularsDestination(:final circularId):
        await target.pushNamed(
          circularsRoute,
          arguments: circularId != null ? {'circular_id': circularId} : null,
        );
      case CircleEventsDestination(:final eventId, :final circleId):
        if (circleId != null && circleId.isNotEmpty) {
          final resolved = await _safeResolve(resolveCircle, circleId);
          if (resolved == null) {
            showMessage('That Circle event is no longer available.');
            await target.pushNamed(notificationsRoute);
          } else {
            await target.pushNamed(
              circleEventsRoute,
              arguments: eventId != null
                  ? {'circle': resolved, 'event_id': eventId}
                  : resolved,
            );
          }
        } else {
          showMessage('That Circle event is no longer available.');
          await target.pushNamed(notificationsRoute);
        }
      case FinanceDetailsDestination(:final transactionId, :final isOfflinePayment):
        await target.pushNamed(
          homeRoute,
          arguments: {
            'tab': 3,
            if (transactionId != null) 'transaction_id': transactionId,
            'is_offline_payment': isOfflinePayment,
          },
        );
      case BusinessDealsDestination(:final dealId):
        await target.pushNamed(
          businessDealsRoute,
          arguments: dealId != null ? {'deal_id': dealId} : null,
        );
      case PeerCollaborationDestination(:final askId):
        await target.pushNamed(
          peerCollaborationRoute,
          arguments: askId != null ? {'ask_id': askId} : null,
        );
    }
  }

  Future<Object?> _safeResolve(
    Future<Object?> Function(String id) resolver,
    String id,
  ) async {
    try {
      return await resolver(id);
    } catch (e) {
      debugPrint('NotificationNavigator: could not resolve "$id": $e');
      return null;
    }
  }

  Future<void> _openResolved(
    Object? entity,
    String route,
    String missingMessage,
  ) async {
    if (entity == null) {
      showMessage(missingMessage);
      await target.pushNamed(notificationsRoute);
      return;
    }
    await target.pushNamed(route, arguments: entity);
  }
}

class _Pending {
  _Pending(this.payload, this.openFeedWhenUnknown, this.createdAt);
  final NotificationPayload payload;
  final bool openFeedWhenUnknown;
  final DateTime createdAt;
}
