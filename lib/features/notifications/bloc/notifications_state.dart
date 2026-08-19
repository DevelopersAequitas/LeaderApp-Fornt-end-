import 'package:flutter/material.dart';
import '../model/notification_model.dart';

@immutable
class NotificationsState {
  final bool isLoading;
  final List<NotificationModel> notifications;
  final String errorMessage;

  const NotificationsState({
    this.isLoading = false,
    this.notifications = const [],
    this.errorMessage = '',
  });

  NotificationsState copyWith({
    bool? isLoading,
    List<NotificationModel>? notifications,
    String? errorMessage,
  }) {
    return NotificationsState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
