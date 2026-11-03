import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';

/// Contract interface defining Notifications View callbacks.
abstract class NotificationsViewContract {
  void onNotificationLoading();
  void onNotificationLoaded();
  void onNotificationError(String error);
  void onNotificationTapped(String screen, Map<String, dynamic> data);
}

/// Presenter coordinating visual actions and state transitions for Notifications.
class NotificationsPresenter {
  final NotificationsViewContract view;
  final NotificationsBloc bloc;

  NotificationsPresenter({
    required this.view,
    required this.bloc,
  });

  void loadNotifications({String category = 'all', bool isRefresh = false}) {
    bloc.add(LoadNotifications(category: category, isRefresh: isRefresh));
  }

  void filterCategory(String category) {
    bloc.add(FilterNotificationsByCategory(category));
  }

  void markAsRead(String notificationId) {
    bloc.add(MarkNotificationAsRead(notificationId));
  }

  void markAllAsRead() {
    bloc.add(const MarkAllNotificationsAsRead());
  }

  void handleNotificationClick(
    String notificationId,
    String screen,
    Map<String, dynamic> data,
  ) {
    markAsRead(notificationId);
    view.onNotificationTapped(screen, data);
  }
}

