import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/notification_model.dart';
import 'notification_card.dart';

/// Renders a date-grouped section of notifications with unread items prioritized on top.
class NotificationDateGroup extends StatelessWidget {
  final String dateTitle;
  final List<NotificationModel> notifications;
  final ValueChanged<NotificationModel>? onNotificationTap;

  const NotificationDateGroup({
    super.key,
    required this.dateTitle,
    required this.notifications,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) return const SizedBox.shrink();

    // Sort: Unread notifications move to top (up side), Read ones move down side
    final sortedList = List<NotificationModel>.from(notifications)
      ..sort((a, b) {
        if (a.isUnread && !b.isUnread) return -1;
        if (!a.isUnread && b.isUnread) return 1;
        return 0;
      });

    final unreadInGroup = sortedList.where((n) => n.isUnread).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Date Section Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Text(
                dateTitle.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: unreadInGroup > 0
                      ? const Color(0xFFEFF6FF)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  unreadInGroup > 0
                      ? '${sortedList.length} ($unreadInGroup new)'
                      : '${sortedList.length}',
                  style: TextStyle(
                    color: unreadInGroup > 0
                        ? const Color(0xFF2563EB)
                        : AppColors.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Divider(color: AppColors.border, height: 1),
              ),
            ],
          ),
        ),
        // Notifications list
        ...sortedList.map(
          (notif) => NotificationCard(
            notification: notif,
            onTap: onNotificationTap != null
                ? () => onNotificationTap!(notif)
                : null,
          ),
        ),
      ],
    );
  }
}
