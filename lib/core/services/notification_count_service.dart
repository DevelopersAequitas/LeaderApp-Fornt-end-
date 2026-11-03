import 'package:flutter/foundation.dart';
import '../constants/api_endpoints.dart';
import '../network/api_client.dart';

/// Centralized service tracking the unread notifications count across the Leader App.
/// Real-time reactive updates via ValueNotifier.
class NotificationCountService {
  NotificationCountService._();
  static final NotificationCountService instance = NotificationCountService._();

  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  /// Updates the count value
  void updateCount(int count) {
    if (unreadCount.value != count) {
      unreadCount.value = count < 0 ? 0 : count;
    }
  }

  /// Decrements count by 1 (e.g., when a single notification is marked as read)
  void decrement() {
    if (unreadCount.value > 0) {
      unreadCount.value = unreadCount.value - 1;
    }
  }

  /// Clears count to 0 (e.g., when "Mark all read" is tapped)
  void clear() {
    unreadCount.value = 0;
  }

  /// Fetches unread count from server
  Future<void> fetchUnreadCount() async {
    try {
      final res = await ApiClient().get<dynamic>(
        ApiEndpoints.leaderNotificationsUnreadCount,
      );
      if (res.unreadCount != null) {
        updateCount(res.unreadCount!);
        return;
      }
      if (res.data != null) {
        if (res.data is Map) {
          final count = res.data['unread_count'];
          if (count is num) {
            updateCount(count.toInt());
            return;
          }
        }
      }
      if (res.rawJson != null) {
        final count = res.rawJson!['unread_count'];
        if (count is num) {
          updateCount(count.toInt());
          return;
        }
      }

      // Fallback: fetch from main notifications index endpoint header
      final listRes = await ApiClient().get<dynamic>(
        '${ApiEndpoints.leaderNotifications}?page=1&per_page=1',
      );
      if (listRes.unreadCount != null) {
        updateCount(listRes.unreadCount!);
      }
    } catch (e) {
      debugPrint('⚠️ [NotificationCountService] Error fetching unread count: $e');
    }
  }
}

