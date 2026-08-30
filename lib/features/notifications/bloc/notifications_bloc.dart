import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/notifications_repository.dart';
import '../model/notification_model.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

/// Business Logic Component for managing user notification alerts via Clean Architecture.
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository _notificationsRepository;

  NotificationsBloc({NotificationsRepository? notificationsRepository})
      : _notificationsRepository =
            notificationsRepository ?? NotificationsRepositoryImpl(),
        super(const NotificationsState()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<FilterNotifications>(_onFilterNotifications);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<ClearAllNotifications>(_onClearAllNotifications);
  }

  List<NotificationModel> _applyFilter(
    List<NotificationModel> list,
    String filter,
  ) {
    switch (filter) {
      case 'Unread':
        return list.where((n) => n.isUnread).toList();
      case 'Referrals':
        return list
            .where((n) => n.type == NotificationType.referral)
            .toList();
      case 'Deals':
        return list.where((n) => n.type == NotificationType.deal).toList();
      case 'Meetings':
        return list.where((n) => n.type == NotificationType.meeting).toList();
      case 'Alerts':
        return list
            .where((n) =>
                n.type == NotificationType.alert ||
                n.type == NotificationType.report)
            .toList();
      default:
        return list;
    }
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
    }

    try {
      final response = await _notificationsRepository.getNotifications();
      final all = response.data ?? const [];
      final filtered = _applyFilter(all, state.selectedFilter);

      emit(
        state.copyWith(
          isLoading: false,
          allNotifications: all,
          filteredNotifications: filtered,
          errorMessage: '',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onFilterNotifications(
    FilterNotifications event,
    Emitter<NotificationsState> emit,
  ) {
    final filtered = _applyFilter(state.allNotifications, event.filter);
    emit(
      state.copyWith(
        selectedFilter: event.filter,
        filteredNotifications: filtered,
      ),
    );
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final updated = state.allNotifications
        .map((n) => n.isUnread ? n.copyWith(isUnread: false) : n)
        .toList();
    final filtered = _applyFilter(updated, state.selectedFilter);

    emit(
      state.copyWith(
        allNotifications: updated,
        filteredNotifications: filtered,
      ),
    );

    try {
      await _notificationsRepository.markAsRead(notificationIds: ['all']);
    } catch (_) {}
  }

  void _onClearAllNotifications(
    ClearAllNotifications event,
    Emitter<NotificationsState> emit,
  ) {
    emit(
      state.copyWith(
        allNotifications: const [],
        filteredNotifications: const [],
      ),
    );
  }
}
