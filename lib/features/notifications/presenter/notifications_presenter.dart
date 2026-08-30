import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';

abstract class NotificationsViewContract {
  void onNotificationsLoading();
  void onNotificationsLoaded();
  void onNotificationsError(String error);
}

class NotificationsPresenter {
  final NotificationsViewContract view;
  final NotificationsBloc bloc;

  NotificationsPresenter({required this.view, required this.bloc});

  void load({bool isRefresh = false}) {
    bloc.add(LoadNotifications(isRefresh: isRefresh));
  }

  void filter(String filter) {
    bloc.add(FilterNotifications(filter));
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
