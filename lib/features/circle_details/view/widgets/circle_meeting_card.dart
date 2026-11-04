import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../teams/model/teams_model.dart';
import '../../model/circle_event_model.dart';
import '../circle_event_detail_screen.dart';
import 'circle_category_theme_config.dart';

/// Meetings & Events section with outside header (`Meetings & Events` + `View all >`)
/// and the event card rendered cleanly below it.
class CircleMeetingCard extends StatelessWidget {
  final CircleTeamModel circle;
  final List<CircleEventModel> events;
  final bool isLoading;

  const CircleMeetingCard({
    super.key,
    required this.circle,
    required this.events,
    required this.isLoading,
  });

  void _openEventsScreen(BuildContext context) {
    Navigator.of(context).pushNamed(
      AppRoutes.circleEvents,
      arguments: circle,
    );
  }

  void _openEventDetail(BuildContext context, CircleEventModel? event) {
    if (event != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CircleEventDetailScreen(
            event: event,
            circle: circle,
          ),
        ),
      );
    } else {
      _openEventsScreen(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = CircleCategoryThemeConfig.fromCircle(
      circle.category,
      circle.name,
    );

    CircleEventModel? nextEvent;
    for (final e in events) {
      if (e.isUpcoming) {
        nextEvent = e;
        break;
      }
    }
    nextEvent ??= events.isNotEmpty ? events.first : null;

    final hasUpcomingRealEvent = nextEvent != null && nextEvent.isUpcoming;
    final nextDate = hasUpcomingRealEvent
        ? [
            if (nextEvent.date.isNotEmpty) nextEvent.date,
            if (nextEvent.time.isNotEmpty) nextEvent.time,
          ].join(' · ')
        : (circle.cadence?.upcomingDisplay?.isNotEmpty == true
            ? circle.cadence!.upcomingDisplay!
            : (circle.cadence?.hasSchedule == true
                ? '${circle.effectiveCadenceSummary} · ${circle.effectiveMeetingTimeRange}'
                : 'Scheduled ${circle.meetingFrequency}'));

    final nextTitle = nextEvent?.title.isNotEmpty == true
        ? nextEvent!.title
        : '${circle.effectiveCadenceSummary} Conclave';
    final location = (nextEvent != null && nextEvent.location.trim().isNotEmpty)
        ? nextEvent.location.trim()
        : (circle.location.isNotEmpty ? circle.location : 'Ahmedabad');
    final mode = nextEvent?.mode ?? circle.meetingMode;
    final isOffline = !mode.toLowerCase().contains('online');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Outside Section Header (matching Circle Peers section header)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'Meetings & Events',
                        style: AppTypography.titleSmall.copyWith(
                          fontSize: 13.5,
                          color: AppColor.lightTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (events.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.badgeBlueBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ThreeDNumberDisplay(
                          value: '${events.length}',
                          digitHeight: 14,
                          spacing: -1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _openEventsScreen(context),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View all',
                        style: AppTypography.labelSmall.copyWith(
                          fontSize: 11.5,
                          color: AppColor.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: AppColor.primaryBlue,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Event Card below the outside header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            onTap: () => _openEventDetail(context, nextEvent),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: config.tintColor.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Top Row: Icon + Title/Date/Location + Mode Pill
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          config.bgTint,
                          AppColor.lightSurfaceMuted,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: config.tintColor.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SquareRoundedGradientIcon(
                          icon: Icons.calendar_month_rounded,
                          boxSize: 40,
                          iconSize: 20,
                          borderRadius: 10,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      nextTitle,
                                      style: AppTypography.labelMedium.copyWith(
                                        fontSize: 13,
                                        color: AppColor.lightTextPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isOffline
                                          ? AppColor.successBg
                                          : AppColor.badgeBlueBg,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isOffline
                                              ? Icons.location_on_outlined
                                              : Icons.videocam_outlined,
                                          size: 10,
                                          color: isOffline
                                              ? AppColor.successDark
                                              : AppColor.primaryBlue,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          mode,
                                          style:
                                              AppTypography.labelSmall.copyWith(
                                            fontSize: 9.5,
                                            color: isOffline
                                                ? AppColor.successDark
                                                : AppColor.primaryBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                nextDate,
                                style: AppTypography.labelSmall.copyWith(
                                  fontSize: 11.5,
                                  color: config.tintColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.pin_drop_outlined,
                                    size: 11,
                                    color: AppColor.lightTextSecondary,
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      location,
                                      style: AppTypography.bodySmall.copyWith(
                                        fontSize: 10.5,
                                        color: AppColor.lightTextSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Recurring Schedule Cadence Callout Banner (matching Web Admin Step 4)
                  if (circle.cadence?.hasSchedule == true || circle.effectiveMeetingTimeRange.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: AppColor.badgeBlueBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColor.primaryBlue.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.event_repeat_rounded,
                            size: 16,
                            color: AppColor.primaryBlue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: AppTypography.bodySmall.copyWith(
                                  fontSize: 11,
                                  color: AppColor.lightTextPrimary,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Recurring Cadence: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.lightTextSecondary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: circle.effectiveCadenceText,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Cadence, Timing, Format & Stage Tiles Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.update_rounded,
                          label: 'Cadence',
                          value: circle.effectiveCadenceSummary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.access_time_rounded,
                          label: 'Timing',
                          value: circle.effectiveMeetingTimeRange.isNotEmpty
                              ? circle.effectiveMeetingTimeRange
                              : (circle.cadence?.startTime.isNotEmpty == true
                                  ? circle.cadence!.startTime
                                  : '02:00 - 03:00'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoTile(
                          icon: isOffline
                              ? Icons.location_on_outlined
                              : Icons.videocam_outlined,
                          label: 'Format',
                          value: circle.cadence?.mode ?? circle.meetingMode,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.stars_outlined,
                          label: 'Stage',
                          value: circle.stage ?? 'Active Circle',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.lightSurfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.lightBorder),
      ),
      child: Row(
        children: [
          GradientIcon(icon: icon, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 9.5,
                    color: AppColor.lightTextDisabled,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 11.5,
                    color: AppColor.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
