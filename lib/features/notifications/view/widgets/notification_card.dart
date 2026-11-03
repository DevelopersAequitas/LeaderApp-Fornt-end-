import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../model/leader_notification_model.dart';

class NotificationCard extends StatelessWidget {
  final LeaderNotificationModel notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  String _formatTimeAgo(DateTime dt) {
    // Local device timezone difference
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'milestones':
        return const Color(0xFFF59E0B);
      case 'circle':
        return AppColor.primaryBlue;
      case 'peers':
        return const Color(0xFF10B981);
      case 'reports':
        return const Color(0xFF8B5CF6);
      case 'finance':
        return const Color(0xFFEC4899);
      case 'system':
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'milestones':
        return Icons.emoji_events_rounded;
      case 'circle':
        return Icons.groups_rounded;
      case 'peers':
        return Icons.person_search_rounded;
      case 'reports':
        return Icons.assessment_rounded;
      case 'finance':
        return Icons.account_balance_wallet_rounded;
      case 'system':
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(notification.category);
    final isUnread = notification.isUnread;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isUnread
            ? AppColor.primaryBlue.withValues(alpha: 0.04)
            : AppColor.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread
              ? AppColor.primaryBlue.withValues(alpha: 0.25)
              : AppColor.lightBorder,
          width: isUnread ? 1.2 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Icon Badge
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(notification.category),
                    size: 20,
                    color: catColor,
                  ),
                ),
                const SizedBox(width: 12),

                // Main Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Category Chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6.5, vertical: 2),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              notification.category.toUpperCase(),
                              style: TextStyle(
                                color: catColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          // Time Ago (Timezone-Aware)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatTimeAgo(notification.createdAt),
                                style: const TextStyle(
                                  color: AppColor.lightTextMuted,
                                  fontSize: 11,
                                ),
                              ),
                              if (isUnread) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: AppColor.primaryBlue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Title
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight:
                              isUnread ? FontWeight.w700 : FontWeight.w600,
                          color: AppColor.lightTextPrimary,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Message Body
                      Text(
                        notification.message,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColor.lightTextSecondary,
                          height: 1.35,
                        ),
                      ),

                      if (notification.screen.isNotEmpty &&
                          notification.screen != '/dashboard') ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Tap to view ${notification.screen.replaceAll('/', '')}',
                              style: const TextStyle(
                                color: AppColor.primaryBlue,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 12,
                              color: AppColor.primaryBlue,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
