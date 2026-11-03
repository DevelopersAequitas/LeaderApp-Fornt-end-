import 'package:flutter/foundation.dart';

@immutable
abstract class NotificationsEvent {
  const NotificationsEvent();
}

/// Triggers initial fetch or pull-to-refresh of notifications.
class LoadNotifications extends NotificationsEvent {
  final String category;
  final bool isRefresh;

  const LoadNotifications({
    this.category = 'all',
    this.isRefresh = false,
  });
}

/// Dispatched when changing active category chip (all, milestones, circle, peers, system, finance, reports).
class FilterNotificationsByCategory extends NotificationsEvent {
  final String category;

  const FilterNotificationsByCategory(this.category);
}

/// Dispatched when user taps or dismisses a single notification.
class MarkNotificationAsRead extends NotificationsEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);
}

/// Dispatched when tapping "Mark all read".
class MarkAllNotificationsAsRead extends NotificationsEvent {
  const MarkAllNotificationsAsRead();
}

