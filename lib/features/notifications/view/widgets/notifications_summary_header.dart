import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Renders the top summary header with unread alerts pill, Mark all as read, and Clear all actions.
class NotificationsSummaryHeader extends StatelessWidget {
  final int totalCount;
  final int unreadCount;
  final VoidCallback onMarkAllRead;
  final VoidCallback onClearAll;

  const NotificationsSummaryHeader({
    super.key,
    required this.totalCount,
    required this.unreadCount,
    required this.onMarkAllRead,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          // Total & Unread Summary
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    totalCount == 1
                        ? '1 Notification'
                        : '$totalCount Notifications',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Text(
                      '$unreadCount new',
                      style: const TextStyle(
                        color: Color(0xFFD97706),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Actions
          if (totalCount > 0) ...[
            if (unreadCount > 0)
              InkWell(
                onTap: onMarkAllRead,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 3,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.done_all_rounded,
                        size: 13,
                        color: Color(0xFF2563EB),
                      ),
                      SizedBox(width: 2),
                      Text(
                        'Read all',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(width: 4),
            InkWell(
              onTap: onClearAll,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 3,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: 13,
                      color: Color(0xFFDC2626),
                    ),
                    SizedBox(width: 2),
                    Text(
                      'Clear',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
