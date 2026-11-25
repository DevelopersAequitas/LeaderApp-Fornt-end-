import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../teams/model/teams_model.dart';
import '../../model/dashboard_metrics_model.dart';

/// Upcoming Circle Conclaves & Events Section.
///
/// Displays accessible Circle schedules from real `CircleTeamModel.cadence`
/// records along with event registration/attendance drill-down.
class DashboardUpcomingEventsSection extends StatelessWidget {
  final List<CircleTeamModel> circles;
  final DashboardMetricsModel metrics;
  final String? selectedCircle;

  const DashboardUpcomingEventsSection({
    super.key,
    required this.circles,
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

    final scheduledCircles = circles.where((c) {
      final cad = c.cadence;
      if (cad == null) return false;
      return cad.hasSchedule ||
          (cad.upcomingDisplay != null && cad.upcomingDisplay!.trim().isNotEmpty);
    }).take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EnterpriseSectionHeader(
          title: 'Upcoming Events',
          countLabel: metrics.eventRegistrations > 0
              ? '${metrics.eventRegistrations}'
              : null,
          actionLabel: 'View All',
          onActionTap: () => Navigator.of(context).pushNamed(
            AppRoutes.leaderActivities,
            arguments: {
              'type': 'event-registrations',
              'circleId': ?selectedCircle,
            },
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: AppSpacing.pageHorizontal,
          child: scheduledCircles.isEmpty
              ? EnterpriseEmptyState(
                  compact: true,
                  icon: Icons.event_note_outlined,
                  title: 'No recurring Circle schedules published',
                  description: metrics.eventRegistrations > 0
                      ? '${metrics.eventRegistrations} event registrations and ${metrics.eventAttendance} check-ins recorded in your scope.'
                      : 'Scheduled Circle conclaves and regional summits in your scope will appear here.',
                  actionLabel: metrics.eventRegistrations > 0
                      ? 'View Event Registrations'
                      : null,
                  onAction: metrics.eventRegistrations > 0
                      ? () => Navigator.of(context).pushNamed(
                            AppRoutes.leaderActivities,
                            arguments: {
                              'type': 'event-registrations',
                              'circleId': ?selectedCircle,
                            },
                          )
                      : null,
                )
              : EnterpriseSurfaceCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (int i = 0; i < scheduledCircles.length; i++) ...[
                        _buildEventRow(
                          context: context,
                          circle: scheduledCircles[i],
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isFirst: i == 0,
                          isLast: i == scheduledCircles.length - 1,
                        ),
                        if (i < scheduledCircles.length - 1)
                          Divider(height: 1, thickness: 1, color: dividerColor),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEventRow({
    required BuildContext context,
    required CircleTeamModel circle,
    required Color textPrimary,
    required Color textSecondary,
    required bool isFirst,
    required bool isLast,
  }) {
    final cad = circle.cadence;
    final dateText = (cad?.upcomingDisplay != null &&
            cad!.upcomingDisplay!.trim().isNotEmpty)
        ? cad.upcomingDisplay!.trim()
        : circle.effectiveCadenceSummary;
    final rawTimeText = circle.effectiveMeetingTimeRange;
    final dateAlreadyHasTime = dateText.contains('AM') ||
        dateText.contains('PM') ||
        RegExp(r'\d{1,2}:\d{2}').hasMatch(dateText);
    final timeText = dateAlreadyHasTime ? '' : rawTimeText;
    final locationText = (cad?.venue != null && cad!.venue.trim().isNotEmpty)
        ? cad.venue.trim()
        : (circle.location.trim().isNotEmpty
            ? '${circle.location.trim()} · ${circle.meetingMode}'
            : circle.meetingMode);
    final isActive = circle.status.toLowerCase() == 'active';

    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.circleEvents,
        arguments: circle,
      ),
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(AppSpacing.radiusMd) : Radius.zero,
        bottom: isLast ? const Radius.circular(AppSpacing.radiusMd) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColor.primaryContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.calendar_today_rounded,
                size: 17,
                color: AppColor.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${circle.name} Conclave',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleSmall.copyWith(
                            color: textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      EnterpriseStatusBadge(
                        label: isActive ? 'Scheduled' : circle.status,
                        tone: isActive
                            ? EnterpriseStatusTone.active
                            : EnterpriseStatusTone.inactive,
                        compact: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (dateText.isNotEmpty) dateText,
                      if (timeText.isNotEmpty) timeText,
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (locationText.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 13,
                          color: textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            locationText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
