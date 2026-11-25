import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/dashboard_metrics_model.dart';
import 'dashboard_hero_card.dart';

class _ActivityStreamRow {
  final String title;
  final String description;
  final int count;
  final IconData icon;
  final Color accent;
  final String activityType;

  const _ActivityStreamRow({
    required this.title,
    required this.description,
    required this.count,
    required this.icon,
    required this.accent,
    required this.activityType,
  });
}

/// Concise Operational Activity Ledger positioned below primary executive sections.
///
/// Displays strictly single-domain verified activity counts without mixing or
/// summing unrelated categories.
class DashboardRecentActivitySection extends StatelessWidget {
  final DashboardMetricsModel metrics;
  final String? selectedCircle;

  const DashboardRecentActivitySection({
    super.key,
    required this.metrics,
    required this.selectedCircle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final textSecondary =
        isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;
    final dividerColor = isDark ? AppColor.darkDivider : AppColor.divider;

    final streams = <_ActivityStreamRow>[
      _ActivityStreamRow(
        title: '1-on-1 P2P Meetings',
        description: 'Discovery & collaboration sessions completed by Peers',
        count: metrics.p2pMeetings,
        icon: Icons.groups_2_outlined,
        accent: AppColor.primary,
        activityType: 'p2p-meetings',
      ),
      _ActivityStreamRow(
        title: 'Business Referrals Shared',
        description: 'Qualified commercial leads exchanged across Circles',
        count: metrics.referrals,
        icon: Icons.swap_horiz_rounded,
        accent: AppColor.tertiary,
        activityType: 'referrals',
      ),
      _ActivityStreamRow(
        title: 'Visitor Registrations',
        description: 'Prospective entrepreneurs invited to Circle conclaves',
        count: metrics.visitorRegistrations,
        icon: Icons.person_add_alt_1_outlined,
        accent: const Color(0xFF4F46E5),
        activityType: 'visitor-registrations',
      ),
      _ActivityStreamRow(
        title: 'Peers Introduced',
        description: 'New Peers successfully inducted into active Circles',
        count: metrics.introducedPeers,
        icon: Icons.how_to_reg_outlined,
        accent: AppColor.success,
        activityType: 'introduced-peers',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EnterpriseSectionHeader(
          title: 'Recent Activity',
          actionLabel: 'All Streams',
          onActionTap: () => Navigator.of(context).pushNamed(
            AppRoutes.leaderActivities,
            arguments: {
              'type': 'top-contributors',
              'circleId': ?selectedCircle,
            },
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: AppSpacing.pageHorizontal,
          child: EnterpriseSurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < streams.length; i++) ...[
                  _buildRow(
                    context: context,
                    row: streams[i],
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    isFirst: i == 0,
                    isLast: i == streams.length - 1,
                  ),
                  if (i < streams.length - 1)
                    Divider(height: 1, thickness: 1, color: dividerColor),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow({
    required BuildContext context,
    required _ActivityStreamRow row,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required bool isFirst,
    required bool isLast,
  }) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.leaderActivities,
        arguments: {
          'type': row.activityType,
          'circleId': ?selectedCircle,
        },
      ),
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(AppSpacing.radiusMd) : Radius.zero,
        bottom: isLast
            ? const Radius.circular(AppSpacing.radiusMd)
            : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: row.accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              alignment: Alignment.center,
              child: Icon(row.icon, size: 17, color: row.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleSmall.copyWith(color: textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    row.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColor.darkSurfaceSubtle
                    : AppColor.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                border: Border.all(
                  color: isDark ? AppColor.darkBorder : AppColor.outline,
                ),
              ),
              child: Text(
                DashboardHeroCard.formatReadableCount(row.count),
                style: AppTypography.metricSmall.copyWith(color: textPrimary),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
