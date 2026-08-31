import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/notification_model.dart';

/// Renders a Material 3 Notification Card with unread indicator and category styling.
class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color iconBg = const Color(0xFFF1F5F9);
    Color iconColor = const Color(0xFF64748B);
    IconData iconData = Icons.notifications_none_rounded;
    String badgeLabel = 'ALERT';
    Color badgeBg = const Color(0xFFF1F5F9);
    Color badgeTextColor = const Color(0xFF64748B);

    switch (notification.type) {
      case NotificationType.referral:
        iconBg = const Color(0xFFEFF6FF);
        iconColor = const Color(0xFF2563EB);
        iconData = Icons.campaign_outlined;
        badgeLabel = 'REFERRAL';
        badgeBg = const Color(0xFFDBEAFE);
        badgeTextColor = const Color(0xFF1E40AF);
        break;
      case NotificationType.deal:
        iconBg = const Color(0xFFDCFCE7);
        iconColor = const Color(0xFF16A34A);
        iconData = Icons.monetization_on_outlined;
        badgeLabel = 'DEAL';
        badgeBg = const Color(0xFFDCFCE7);
        badgeTextColor = const Color(0xFF166534);
        break;
      case NotificationType.alert:
        iconBg = const Color(0xFFFEE2E2);
        iconColor = const Color(0xFFDC2626);
        iconData = Icons.bolt_rounded;
        badgeLabel = 'ALERT';
        badgeBg = const Color(0xFFFEE2E2);
        badgeTextColor = const Color(0xFF991B1B);
        break;
      case NotificationType.meeting:
        iconBg = const Color(0xFFFEF3C7);
        iconColor = const Color(0xFFD97706);
        iconData = Icons.calendar_today_outlined;
        badgeLabel = 'MEETING';
        badgeBg = const Color(0xFFFEF3C7);
        badgeTextColor = const Color(0xFF92400E);
        break;
      case NotificationType.report:
        iconBg = const Color(0xFFEBF3FB);
        iconColor = AppColors.primary;
        iconData = Icons.description_outlined;
        badgeLabel = 'REPORT';
        badgeBg = const Color(0xFFEBF3FB);
        badgeTextColor = AppColors.primary;
        break;
    }

    final isUnread = notification.isUnread;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFF8FAFD) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnread ? const Color(0xFFBFDBFE) : AppColors.border,
          width: isUnread ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isUnread ? 0.025 : 0.01),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unread dot indicator
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(top: 13, right: 8),
                  decoration: BoxDecoration(
                    color: isUnread
                        ? const Color(0xFF2563EB)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
                // Icon Box
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(iconData, color: iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 13,
                                fontWeight: isUnread
                                    ? FontWeight.w800
                                    : FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Category tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badgeLabel,
                              style: TextStyle(
                                color: badgeTextColor,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        notification.description,
                        style: TextStyle(
                          color: isUnread
                              ? AppColors.text.withValues(alpha: 0.85)
                              : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: isUnread
                              ? FontWeight.w500
                              : FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.time,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
