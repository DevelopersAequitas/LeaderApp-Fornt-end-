import 'package:flutter/material.dart';

import '../../data/repositories/reports_repository.dart';
import '../../data/repositories/teams_repository.dart';
import '../helpers/session_manager.dart';
import '../routes/app_routes.dart';
import 'notification_navigator.dart';

/// Adapts the app's global [NavigatorState] to [NotificationNavTarget].
class _AppNavTarget implements NotificationNavTarget {
  @override
  bool get isAvailable => AppRoutes.navigatorKey.currentState != null;

  @override
  Future<void> pushNamed(String route, {Object? arguments}) async {
    await AppRoutes.navigatorKey.currentState
        ?.pushNamed(route, arguments: arguments);
  }
}

/// The single, app-wide notification navigator wired to the real session,
/// permissions, repositories and navigator. Every notification tap — FCM
/// foreground/background/cold start, local-notification tap, and a tap in the
/// Notifications feed — goes through [AppNotificationNavigator.instance].
class AppNotificationNavigator {
  AppNotificationNavigator._();

  static final NotificationNavigator instance = NotificationNavigator(
    target: _AppNavTarget(),
    isAuthenticated: () => SessionManager().isAuthenticated,
    permissions: () => SessionManager().permissions,
    resolveCircle: (id) async {
      final res = await TeamsRepositoryImpl().getCircleDetails(id);
      return res.success ? res.data : null;
    },
    resolveReport: (id) async {
      final res = await ReportsRepositoryImpl().getReportDetails(id);
      return res.success ? res.data : null;
    },
    showMessage: (message) {
      final context = AppRoutes.navigatorKey.currentContext;
      if (context == null) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    },
    homeRoute: AppRoutes.home,
    peerProfileRoute: AppRoutes.peerProfile,
    circleDetailsRoute: AppRoutes.circleDetails,
    reportDetailsRoute: AppRoutes.reportDetails,
    profileRoute: AppRoutes.profile,
    roleManagementRoute: AppRoutes.roleManagement,
    notificationsRoute: AppRoutes.notifications,
    leaderActivitiesRoute: AppRoutes.leaderActivities,
    circularsRoute: AppRoutes.circulars,
    circleEventsRoute: AppRoutes.circleEvents,
    businessDealsRoute: AppRoutes.businessDeals,
    peerCollaborationRoute: AppRoutes.peerCollaboration,
  );
}
