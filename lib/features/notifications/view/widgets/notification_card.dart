import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/utils/date_time_utils.dart';
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
    return DateTimeUtils.formatTimeAgo(dt);
  }

  String _formatCategory(String cat) {
    if (cat.trim().isEmpty) return 'General';
    final clean = cat.replaceAll(RegExp(r'[_\-]+'), ' ').trim();
    final words = clean.split(' ').where((w) => w.isNotEmpty).map((w) {
      if (w.length <= 1) return w.toUpperCase();
      return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
    });
    return words.join(' ');
  }

  String _formatScreenName(String screen) {
    final clean = screen.replaceAll(RegExp(r'[/_\-]+'), ' ').trim();
    if (clean.isEmpty) return 'Details';
    return '${clean[0].toUpperCase()}${clean.substring(1).toLowerCase()}';
  }

  Color _getCategoryColor(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('milestone')) return const Color(0xFFF59E0B);
    if (lower.contains('circle') || lower.contains('team')) {
      return AppColor.primaryBlue;
    }
    if (lower.contains('peer') || lower.contains('member')) {
      return const Color(0xFF10B981);
    }
    if (lower.contains('report') || lower.contains('audit')) {
      return const Color(0xFF8B5CF6);
    }
    if (lower.contains('finance') || lower.contains('payment')) {
      return const Color(0xFFE11D48);
    }
    return const Color(0xFF64748B);
  }

  IconData _getCategoryIcon(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('milestone')) return Icons.emoji_events_rounded;
    if (lower.contains('circle') || lower.contains('team')) {
      return Icons.groups_rounded;
    }
    if (lower.contains('peer') || lower.contains('member')) {
      return Icons.person_search_rounded;
    }
    if (lower.contains('report') || lower.contains('audit')) {
      return Icons.assessment_rounded;
    }
    if (lower.contains('finance') || lower.contains('payment')) {
      return Icons.account_balance_wallet_rounded;
    }
    return Icons.notifications_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(notification.category);
    final isUnread = notification.isUnread;
    final hasActionScreen = notification.screen.isNotEmpty &&
        notification.screen != '/dashboard' &&
        notification.screen != 'dashboard';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFFAFCFF) : AppColor.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnread
              ? AppColor.primaryBlue.withValues(alpha: 0.22)
              : AppColor.lightBorder.withValues(alpha: 0.8),
          width: isUnread ? 1.1 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnread
                ? AppColor.primaryBlue.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Executive Accent Indicator for unread cards
              if (isUnread)
                Container(
                  width: 3.5,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1D4ED8), Color(0xFFE11D48)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

              // Main Card Interactive Surface
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isUnread ? 12 : 14,
                        13,
                        14,
                        13,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Squircle Icon
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  catColor.withValues(alpha: 0.16),
                                  catColor.withValues(alpha: 0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: catColor.withValues(alpha: 0.18),
                                width: 0.8,
                              ),
                            ),
                            child: Icon(
                              _getCategoryIcon(notification.category),
                              size: 20,
                              color: catColor,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Text Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top row: Category Badge & Time Ago
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Category Pill Badge (Flexible with Ellipsis prevents overflow)
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              catColor.withValues(alpha: 0.08),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: catColor.withValues(
                                                alpha: 0.18),
                                            width: 0.7,
                                          ),
                                        ),
                                        child: Text(
                                          _formatCategory(
                                              notification.category),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: catColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Time Ago & Unread Glowing Dot
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          _formatTimeAgo(
                                              notification.createdAt),
                                          style: TextStyle(
                                            color: isUnread
                                                ? AppColor.lightTextSecondary
                                                : AppColor.lightTextMuted,
                                            fontSize: 11,
                                            fontWeight: isUnread
                                                ? FontWeight.w500
                                                : FontWeight.w400,
                                          ),
                                        ),
                                        if (isUnread) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF1D4ED8),
                                                  Color(0xFFE11D48)
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColor.primaryPink
                                                      .withValues(alpha: 0.4),
                                                  blurRadius: 3,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Title
                                Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: isUnread
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: AppColor.lightTextPrimary,
                                    letterSpacing: -0.15,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Message Body
                                Text(
                                  notification.message,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: isUnread
                                        ? const Color(0xFF334155)
                                        : AppColor.lightTextSecondary,
                                    height: 1.4,
                                  ),
                                ),

                                // Deep Link Prompt (if actionable)
                                if (hasActionScreen) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.primaryBlue
                                          .withValues(alpha: 0.06),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: AppColor.primaryBlue
                                            .withValues(alpha: 0.12),
                                        width: 0.7,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'View ${_formatScreenName(notification.screen)}',
                                          style: const TextStyle(
                                            color: AppColor.primaryBlue,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 11,
                                          color: AppColor.primaryBlue,
                                        ),
                                      ],
                                    ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
