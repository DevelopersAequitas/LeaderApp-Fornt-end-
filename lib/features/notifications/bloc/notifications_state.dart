import 'package:flutter/foundation.dart';
import '../model/leader_notification_model.dart';

enum NotificationsStatus { initial, loading, success, failure }

@immutable
class NotificationsState {
  final NotificationsStatus status;
  final List<LeaderNotificationModel> notifications;
  final String activeCategory;
  final int unreadCount;
  final String? errorMessage;
  final bool isMarkingRead;
  final int currentPage;
  final int lastPage;
  final bool hasMore;
  final bool isLoadingMore;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.activeCategory = 'all',
    this.unreadCount = 0,
    this.errorMessage,
    this.isMarkingRead = false,
    this.currentPage = 1,
    this.lastPage = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  bool get isLoading => status == NotificationsStatus.loading;
  bool get isSuccess => status == NotificationsStatus.success;
  bool get isFailure => status == NotificationsStatus.failure;

  List<LeaderNotificationModel> get filteredNotifications {
    if (activeCategory == 'all') {
      return notifications;
    }
    return notifications.where((n) {
      final cat = n.category.toLowerCase();
      final type = n.type.toLowerCase();
      final target = activeCategory.toLowerCase();
      return cat == target || cat.contains(target) || type.contains(target);
    }).toList();
  }

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<LeaderNotificationModel>? notifications,
    String? activeCategory,
    int? unreadCount,
    String? errorMessage,
    bool? isMarkingRead,
    int? currentPage,
    int? lastPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      activeCategory: activeCategory ?? this.activeCategory,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage,
      isMarkingRead: isMarkingRead ?? this.isMarkingRead,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

