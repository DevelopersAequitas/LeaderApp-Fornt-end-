import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/notification_count_service.dart';
import '../model/leader_notification_model.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final ApiClient _apiClient;

  NotificationsBloc({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(),
        super(const NotificationsState()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadMoreNotifications>(_onLoadMoreNotifications);
    on<FilterNotificationsByCategory>(_onFilterNotificationsByCategory);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(state.copyWith(status: NotificationsStatus.loading));
    }

    try {
      final categoryParam = event.category.isNotEmpty && event.category != 'all'
          ? '&category=${event.category}'
          : '';
      final url =
          '${ApiEndpoints.leaderNotifications}?page=1&per_page=20$categoryParam';

      final res = await _apiClient.get<dynamic>(url);

      if (res.success) {
        List<dynamic> rawList = [];
        int? serverUnreadCount = res.unreadCount;
        int currentPage = 1;
        int lastPage = 1;
        bool hasMore = false;

        if (res.data is List) {
          rawList = res.data as List;
        } else if (res.data is Map) {
          final map = res.data as Map;
          final nested = map['data'] ?? map['notifications'] ?? map['items'];
          if (nested is List) {
            rawList = nested;
          }
          if (serverUnreadCount == null && map['unread_count'] is num) {
            serverUnreadCount = (map['unread_count'] as num).toInt();
          }
        }

        if (res.meta != null) {
          currentPage = res.meta!.currentPage;
          lastPage = res.meta!.lastPage;
          hasMore = res.meta!.hasMore;
        }

        final items = rawList
            .map((item) => LeaderNotificationModel.fromJson(
                Map<String, dynamic>.from(item as Map)))
            .where((n) => n.isLeaderNotification)
            .toList();

        final unreadCount =
            serverUnreadCount ?? items.where((n) => n.isUnread).length;
        NotificationCountService.instance.updateCount(unreadCount);

        emit(state.copyWith(
          status: NotificationsStatus.success,
          notifications: items,
          unreadCount: unreadCount,
          activeCategory: event.category,
          currentPage: currentPage,
          lastPage: lastPage,
          hasMore: hasMore,
          isLoadingMore: false,
        ));
      } else {
        emit(state.copyWith(
          status: NotificationsStatus.failure,
          errorMessage: res.message ?? 'Failed to load notifications.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: NotificationsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMoreNotifications(
    LoadMoreNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final nextPage = state.currentPage + 1;
      final categoryParam =
          state.activeCategory.isNotEmpty && state.activeCategory != 'all'
              ? '&category=${state.activeCategory}'
              : '';
      final url =
          '${ApiEndpoints.leaderNotifications}?page=$nextPage&per_page=20$categoryParam';

      final res = await _apiClient.get<dynamic>(url);

      if (res.success) {
        List<dynamic> rawList = [];
        int currentPage = nextPage;
        int lastPage = state.lastPage;
        bool hasMore = false;

        if (res.data is List) {
          rawList = res.data as List;
        } else if (res.data is Map) {
          final map = res.data as Map;
          final nested = map['data'] ?? map['notifications'] ?? map['items'];
          if (nested is List) {
            rawList = nested;
          }
          final meta = map['meta'] ?? map['pagination'];
          if (meta is Map) {
            currentPage = (meta['current_page'] as num?)?.toInt() ?? nextPage;
            lastPage = (meta['last_page'] as num?)?.toInt() ?? state.lastPage;
            hasMore = (meta['has_more'] as bool?) ?? (currentPage < lastPage);
          }
        }

        final newItems = rawList
            .map((item) => LeaderNotificationModel.fromJson(
                Map<String, dynamic>.from(item as Map)))
            .where((n) => n.isLeaderNotification)
            .toList();

        final existingIds = state.notifications.map((n) => n.id).toSet();
        final combined = [
          ...state.notifications,
          ...newItems.where((n) => !existingIds.contains(n.id)),
        ];

        if (res.unreadCount != null) {
          NotificationCountService.instance.updateCount(res.unreadCount!);
        }

        emit(state.copyWith(
          notifications: combined,
          currentPage: currentPage,
          lastPage: lastPage,
          hasMore: hasMore,
          isLoadingMore: false,
          unreadCount: res.unreadCount ?? state.unreadCount,
        ));
      } else {
        emit(state.copyWith(isLoadingMore: false));
      }
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  void _onFilterNotificationsByCategory(
    FilterNotificationsByCategory event,
    Emitter<NotificationsState> emit,
  ) {
    emit(state.copyWith(activeCategory: event.category));
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    // Optimistic local update
    final updatedList = state.notifications.map((n) {
      if (n.id == event.notificationId) {
        return n.copyWith(isUnread: false);
      }
      return n;
    }).toList();

    final newUnreadCount = state.unreadCount > 0
        ? state.unreadCount - 1
        : updatedList.where((n) => n.isUnread).length;
    NotificationCountService.instance.updateCount(newUnreadCount);
    emit(state.copyWith(
      notifications: updatedList,
      unreadCount: newUnreadCount,
    ));

    try {
      await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.leaderNotificationReadSingle(event.notificationId),
        body: {'notification_id': event.notificationId},
      );
    } catch (_) {
      // Keep optimistic update
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final updatedList = state.notifications
        .map((n) => n.copyWith(isUnread: false))
        .toList();

    NotificationCountService.instance.clear();
    emit(state.copyWith(
      notifications: updatedList,
      unreadCount: 0,
      isMarkingRead: true,
    ));

    try {
      await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.leaderNotificationsMarkAllRead,
      );
    } catch (_) {
      // Keep optimistic state
    } finally {
      emit(state.copyWith(isMarkingRead: false));
    }
  }
}
