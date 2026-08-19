import 'package:flutter/material.dart';

@immutable
abstract class NotificationsEvent {
  const NotificationsEvent();
}

/// Triggers loading of user notification logs.
class LoadNotifications extends NotificationsEvent {
  const LoadNotifications();
}

/// Toggles all unread notification statuses to read.
class MarkAllAsRead extends NotificationsEvent {
  const MarkAllAsRead();
}

/// Purges notifications history.
class ClearAllNotifications extends NotificationsEvent {
  const ClearAllNotifications();
}
