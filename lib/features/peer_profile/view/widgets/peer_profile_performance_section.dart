import 'package:flutter/material.dart';
import '../../../../core/routes/app_page_route.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../peers/model/peer_model.dart';
import '../../model/peer_profile_model.dart';
import '../../model/peer_profile_sections_model.dart';
import '../peer_events_attendance_screen.dart';
import '../peer_testimonials_screen.dart';

/// Section G: Performance, Attendance, Events, P2P, Testimonials & Recognitions.
class PeerProfilePerformanceSection extends StatelessWidget {
  final PeerModel peer;
  final PeerProfileDetailModel details;
  final PeerPerformanceInfoModel performance;

  const PeerProfilePerformanceSection({
    super.key,
    required this.peer,
    required this.details,
    required this.performance,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final textSecondary =
        isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;
    final textMuted =
        isDark ? AppColor.darkTextTertiary : AppColor.lightTextMuted;

    final hasAttendance = performance.totalAttendanceRecorded > 0 ||
        performance.attendanceRatePercent != null;
    final hasEvents = performance.eventsRegisteredCount > 0 ||
        performance.eventsAttendedCount > 0;
    final hasEngagement = performance.p2pMeetingsCount > 0 ||
        performance.testimonialsGivenCount > 0 ||
        performance.testimonialsReceivedCount > 0 ||
        performance.reportsSubmittedCount > 0 ||
        performance.postsCount > 0 ||
        performance.creativesCount > 0;
    final hasRecognition =
        (performance.coinMilestoneTitle ?? '').isNotEmpty ||
            (performance.contributionAwardName ?? '').isNotEmpty ||
            performance.badges.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasAttendance) ...[
            EnterpriseSurfaceCard(
              onTap: () {
                Navigator.of(context).push(
                  AppPageRoute(
                    builder: (_) => PeerEventsAttendanceScreen(peer: peer),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'CIRCLE MEETING ATTENDANCE',
                          style: AppTypography.labelSmall
                              .copyWith(color: textMuted),
                        ),
                      ),
                      if (performance.attendanceRatePercent != null)
                        Text(
                          '${performance.attendanceRatePercent!.toStringAsFixed(performance.attendanceRatePercent!.truncateToDouble() == performance.attendanceRatePercent ? 0 : 1)}%',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColor.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _PerfStatTile(
                          label: 'Attended',
                          value: '${performance.attended}',
                          color: AppColor.success,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _PerfStatTile(
                          label: 'Absent',
                          value: '${performance.absent}',
                          color: AppColor.danger,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _PerfStatTile(
                          label: 'Late',
                          value: '${performance.lateCount}',
                          color: AppColor.warning,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _PerfStatTile(
                          label: 'Excused',
                          value: '${performance.excused}',
                          color: AppColor.info,
                        ),
                      ),
                    ],
                  ),
                  if (performance.totalAttendanceRecorded > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Based on ${performance.totalAttendanceRecorded} recorded sessions · Tap for full attendance log',
                      style: AppTypography.bodySmall
                          .copyWith(color: textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          if (hasEvents) ...[
            EnterpriseSurfaceCard(
              onTap: () {
                Navigator.of(context).push(
                  AppPageRoute(
                    builder: (_) => PeerEventsAttendanceScreen(peer: peer),
                  ),
                );
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.event_available_outlined,
                    color: AppColor.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Events Registered & Attended',
                          style: AppTypography.titleSmall.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${performance.eventsRegisteredCount} registered · ${performance.eventsAttendedCount} attended',
                          style: AppTypography.bodySmall
                              .copyWith(color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: textMuted,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          if (hasEngagement) ...[
            EnterpriseSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PEER ENGAGEMENT & OUTPUTS',
                    style: AppTypography.labelSmall.copyWith(color: textMuted),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (performance.p2pMeetingsCount > 0)
                        _PerfChipStat(
                          icon: Icons.people_outline_rounded,
                          label: 'P2P Meetings',
                          value: '${performance.p2pMeetingsCount}',
                        ),
                      if (performance.testimonialsGivenCount > 0 ||
                          performance.testimonialsReceivedCount > 0)
                        _PerfChipStat(
                          icon: Icons.format_quote_rounded,
                          label: 'Testimonials (Given / Rec)',
                          value:
                              '${performance.testimonialsGivenCount} / ${performance.testimonialsReceivedCount}',
                          onTap: () => Navigator.of(context).push(
                            AppPageRoute(
                              builder: (_) => PeerTestimonialsScreen(
                                peer: peer,
                                testimonials: details.testimonials,
                              ),
                            ),
                          ),
                        ),
                      if (performance.reportsSubmittedCount > 0)
                        _PerfChipStat(
                          icon: Icons.assignment_turned_in_outlined,
                          label: 'Leadership Reports',
                          value: '${performance.reportsSubmittedCount}',
                        ),
                      if (performance.postsCount > 0)
                        _PerfChipStat(
                          icon: Icons.feed_outlined,
                          label: 'Posts',
                          value: '${performance.postsCount}',
                        ),
                      if (performance.creativesCount > 0)
                        _PerfChipStat(
                          icon: Icons.image_outlined,
                          label: 'Creatives',
                          value: '${performance.creativesCount}',
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          if (hasRecognition)
            EnterpriseSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RECOGNITIONS & MILESTONES',
                    style: AppTypography.labelSmall.copyWith(color: textMuted),
                  ),
                  const SizedBox(height: 10),
                  if ((performance.coinMilestoneTitle ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            size: 16,
                            color: AppColor.warning,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Coin Milestone: ${performance.coinMilestoneTitle}',
                              style: AppTypography.bodyMedium
                                  .copyWith(color: textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if ((performance.contributionAwardName ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.emoji_events_outlined,
                            size: 16,
                            color: AppColor.success,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Award: ${performance.contributionAwardName}',
                              style: AppTypography.bodyMedium
                                  .copyWith(color: textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (performance.badges.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: performance.badges.map((b) {
                        final badgeName = (b['title'] ??
                                b['name'] ??
                                b['badge_name'] ??
                                'Milestone')
                            .toString();
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.primary.withValues(alpha: 0.08),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusPill),
                            border: Border.all(
                              color: AppColor.primary.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.workspace_premium_outlined,
                                size: 14,
                                color: AppColor.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                badgeName,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColor.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

          if (!hasAttendance &&
              !hasEvents &&
              !hasEngagement &&
              !hasRecognition)
            EnterpriseSurfaceCard(
              child: Text(
                'No performance metrics recorded yet.',
                style: AppTypography.bodyMedium.copyWith(color: textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}

class _PerfStatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _PerfStatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColor.darkSurfaceElevated : AppColor.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.titleSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmall.copyWith(
              color: isDark
                  ? AppColor.darkTextSecondary
                  : AppColor.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PerfChipStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _PerfChipStat({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColor.darkSurfaceElevated : AppColor.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: isDark ? AppColor.darkBorder : AppColor.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColor.primary),
            const SizedBox(width: 6),
            Text(
              '$label: ',
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColor.darkTextSecondary
                    : AppColor.lightTextSecondary,
              ),
            ),
            Text(
              value,
              style: AppTypography.labelLarge.copyWith(
                color: isDark
                    ? AppColor.darkTextPrimary
                    : AppColor.lightTextPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
