import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';

/// Contract interface defining Notifications view actions.
abstract class NotificationsViewContract {
  void onNotificationsLoading();
  void onNotificationsLoaded();
  void onNotificationsError(String error);
}

/// Presenter coordinating visual transitions for Notifications screen.
class NotificationsPresenter {
  final NotificationsViewContract view;
  final NotificationsBloc bloc;

  NotificationsPresenter({required this.view, required this.bloc});

  void load() {
    bloc.add(const LoadNotifications());
  }

  void markAllAsRead() {
    bloc.add(const MarkAllAsRead());
  }

  void clearAll() {
    bloc.add(const ClearAllNotifications());
  }

  void handleStateChange(NotificationsState state) {
    if (state.isLoading) {
      view.onNotificationsLoading();
    } else {
      view.onNotificationsLoaded();
    }

    if (state.errorMessage.isNotEmpty) {
      view.onNotificationsError(state.errorMessage);
    }
  }
}
