import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/notification_model.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

/// Business Logic Component for managing user notification alerts.
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc() : super(const NotificationsState()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<ClearAllNotifications>(_onClearAllNotifications);
  }

  // Mock notifications matching the mockup screenshots
  static const List<NotificationModel> _mockNotificationsDb = [
    NotificationModel(
      id: '1',
      title: 'New referral submitted',
      type: NotificationType.referral,
      description: 'Priya Sharma referred Vikram Malhotra.',
      time: '2h ago',
      isUnread: true,
    ),
    NotificationModel(
      id: '2',
      title: 'Business deal closed',
      type: NotificationType.deal,
      description: 'James O\'Brien closed a ₹8,400 deal.',
      time: '4h ago',
      isUnread: true,
    ),
    NotificationModel(
      id: '3',
      title: 'Peer at risk',
      type: NotificationType.alert,
      description: 'David Kim\'s attendance dropped to 65%.',
      time: 'Yesterday',
      isUnread: true,
    ),
    NotificationModel(
      id: '4',
      title: 'Meeting reminder',
      type: NotificationType.meeting,
      description: 'Monthly Circle on Aug 1 at 7:30 AM.',
      time: '2 days ago',
      isUnread: false,
    ),
    NotificationModel(
      id: '5',
      title: 'Report received',
      type: NotificationType.report,
      description: 'Arjun Patel submitted monthly report.',
      time: '3 days ago',
      isUnread: false,
    ),
  ];

  void _onLoadNotifications(LoadNotifications event, Emitter<NotificationsState> emit) {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    emit(
      state.copyWith(
        isLoading: false,
        notifications: _mockNotificationsDb,
      ),
    );
  }

  void _onMarkAllAsRead(MarkAllAsRead event, Emitter<NotificationsState> emit) {
    final updated = state.notifications
        .map((n) => n.isUnread ? n.copyWith(isUnread: false) : n)
        .toList();
    emit(state.copyWith(notifications: updated));
  }

  void _onClearAllNotifications(ClearAllNotifications event, Emitter<NotificationsState> emit) {
    emit(state.copyWith(notifications: const []));
  }
}
