import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/notifications_repository.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

/// Business Logic Component for managing user notification alerts via Clean Architecture.
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository _notificationsRepository;

  NotificationsBloc({NotificationsRepository? notificationsRepository})
      : _notificationsRepository = notificationsRepository ?? NotificationsRepositoryImpl(),
        super(const NotificationsState()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<ClearAllNotifications>(_onClearAllNotifications);
  }

  Future<void> _onLoadNotifications(LoadNotifications event, Emitter<NotificationsState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    try {
      final response = await _notificationsRepository.getNotifications();
      emit(
        state.copyWith(
          isLoading: false,
          notifications: response.data ?? const [],
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onMarkAllAsRead(MarkAllAsRead event, Emitter<NotificationsState> emit) async {
    final updated = state.notifications
        .map((n) => n.isUnread ? n.copyWith(isUnread: false) : n)
        .toList();
    emit(state.copyWith(notifications: updated));

    try {
      await _notificationsRepository.markAsRead(notificationIds: ['all']);
    } catch (_) {}
  }

  void _onClearAllNotifications(ClearAllNotifications event, Emitter<NotificationsState> emit) {
    emit(state.copyWith(notifications: const []));
  }
}
