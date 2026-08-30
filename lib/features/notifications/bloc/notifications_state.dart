import 'package:equatable/equatable.dart';
import '../model/notification_model.dart';

class NotificationsState extends Equatable {
  final bool isLoading;
  final List<NotificationModel> allNotifications;
  final List<NotificationModel> filteredNotifications;
  final String selectedFilter;
  final String errorMessage;

  const NotificationsState({
    this.isLoading = false,
    this.allNotifications = const [],
    this.filteredNotifications = const [],
    this.selectedFilter = 'All',
    this.errorMessage = '',
  });

  int get unreadCount => allNotifications.where((n) => n.isUnread).length;
  int get totalCount => allNotifications.length;

  NotificationsState copyWith({
    bool? isLoading,
    List<NotificationModel>? allNotifications,
    List<NotificationModel>? filteredNotifications,
    String? selectedFilter,
    String? errorMessage,
  }) {
    return NotificationsState(
      isLoading: isLoading ?? this.isLoading,
      allNotifications: allNotifications ?? this.allNotifications,
      filteredNotifications: filteredNotifications ?? this.filteredNotifications,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        allNotifications,
        filteredNotifications,
        selectedFilter,
        errorMessage,
      ];
}
