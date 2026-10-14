import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../peers/model/peer_model.dart';
import '../../../teams/model/teams_model.dart';
import '../../model/circle_event_model.dart';
import '../circle_event_detail_screen.dart';

/// Renders the Events list with interactive gradient filter tabs, theme-consistent
/// assembly cards, and navigation to the dedicated event detail screen.
class CircleEventsSection extends StatelessWidget {
  final List<CircleEventModel> events;
  final List<CircleEventModel> allEvents;
  final bool isLoading;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final CircleTeamModel? circle;
  final List<PeerModel> peers;

  const CircleEventsSection({
    super.key,
    required this.events,
    this.allEvents = const [],
    required this.isLoading,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.circle,
    this.peers = const [],
  });

  static Map<String, String> _formatDateTimeParts(
    String rawDate,
    String rawTime,
  ) {
    final trimmedDate = rawDate.trim();
    final trimmedTime = rawTime.trim();

    if (trimmedDate.isEmpty && trimmedTime.isEmpty) {
      return {'date': 'Date TBD', 'time': ''};
    }

    final dt = DateTime.tryParse(trimmedDate);
    if (dt != null) {
      final local = dt.toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final dateStr =
          '${local.day.toString().padLeft(2, '0')} ${months[local.month - 1]} ${local.year}';

      String timeStr = trimmedTime;
      if (timeStr.isEmpty &&
          (trimmedDate.contains('T') || trimmedDate.contains(':'))) {
        final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
        final minuteStr = local.minute.toString().padLeft(2, '0');
        final period = local.hour >= 12 ? 'PM' : 'AM';
        timeStr = '$hour12:$minuteStr $period';
      }
      return {'date': dateStr, 'time': timeStr};
    }

    return {
      'date': trimmedDate.isNotEmpty ? trimmedDate : 'Date TBD',
      'time': trimmedTime,
    };
  }

  @override
  Widget build(BuildContext context) {
    final sourceEvents = allEvents.isNotEmpty ? allEvents : events;
    final allCount = sourceEvents.length;
    final upcomingCount = sourceEvents.where((e) => e.isUpcoming).length;
    final completedCount = sourceEvents.where((e) => e.isCompleted).length;

    final filterItems = [
      {'label': 'All', 'count': allCount},
      {'label': 'Upcoming', 'count': upcomingCount},
      {'label': 'Completed', 'count': completedCount},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Gradient Filter Tabs Segmented Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.secondaryBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: filterItems.map((item) {
                final label = item['label'] as String;
                final count = item['count'] as int;
                final isSelected =
                    selectedFilter.toLowerCase() == label.toLowerCase();

                return Expanded(
                  child: InkWell(
                    onTap: () => onFilterChanged(label),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.brandGradient : null,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.28),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                          if (count > 0) ...[
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),

        if (isLoading)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (events.isEmpty)
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SquareRoundedGradientIcon(
                        icon: Icons.event_busy_rounded,
                        boxSize: 56,
                        iconSize: 28,
                        borderRadius: 16,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'No events or assemblies found',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Events for this circle will appear here when scheduled.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: events.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemBuilder: (context, idx) {
              final ev = events[idx];
              final isUpcoming = ev.isUpcoming;
              final dtParts = _formatDateTimeParts(ev.date, ev.time);

              IconData icon = Icons.event_available_rounded;
              if (ev.title.contains('Summit') || ev.title.contains('Assembly')) {
                icon = Icons.groups_rounded;
              } else if (ev.title.contains('Workshop') ||
                  ev.title.contains('AI') ||
                  ev.title.contains('Mastermind')) {
                icon = Icons.psychology_rounded;
              } else if (ev.title.contains('Meet') ||
                  ev.title.contains('Networking')) {
                icon = Icons.handshake_rounded;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      // Navigate to its dedicated screen instead of opening bottom sheet
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CircleEventDetailScreen(
                            event: ev,
                            circle: circle,
                            attendingPeers: peers,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: SquareRoundedGradientIcon + Mode Pill + Status Badge
                          Row(
                            children: [
                              SquareRoundedGradientIcon(
                                icon: icon,
                                boxSize: 38,
                                iconSize: 19,
                                borderRadius: 10,
                              ),
                              const SizedBox(width: 10),
                              // Mode Pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3.5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GradientIcon(
                                      icon: ev.mode
                                              .toLowerCase()
                                              .contains('online')
                                          ? Icons.videocam_rounded
                                          : Icons.domain_rounded,
                                      size: 12,
                                      gradient: AppColors.brandGradient,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      ev.mode.toUpperCase(),
                                      style: const TextStyle(
                                        color: AppColors.text,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              // Status Badge with Gradient
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 3.5,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isUpcoming
                                      ? AppColors.brandGradient
                                      : const LinearGradient(
                                          colors: [
                                            Color(0xFF64748B),
                                            Color(0xFF475569),
                                          ],
                                        ),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isUpcoming
                                              ? AppColors.primary
                                              : const Color(0xFF64748B))
                                          .withValues(alpha: 0.25),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1.5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isUpcoming
                                          ? Icons.schedule_rounded
                                          : Icons.task_alt_rounded,
                                      size: 11,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 3.5),
                                    Text(
                                      ev.status.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Event Title
                          Text(
                            ev.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.5,
                              color: AppColors.text,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Date & Time Row with Gradient Icons
                          Row(
                            children: [
                              const GradientIcon(
                                icon: Icons.calendar_today_rounded,
                                size: 13,
                                gradient: AppColors.brandGradient,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                dtParts['date']!,
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (dtParts['time']!.isNotEmpty) ...[
                                const SizedBox(width: 10),
                                const GradientIcon(
                                  icon: Icons.schedule_rounded,
                                  size: 13,
                                  gradient: AppColors.brandGradient,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  dtParts['time']!,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          // Location Row with Gradient Icon
                          if (ev.location.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 1.5),
                                  child: GradientIcon(
                                    icon: Icons.location_on_rounded,
                                    size: 14,
                                    gradient: AppColors.brandGradient,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    ev.location,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 10),
                          const Divider(height: 1, color: AppColors.border),
                          const SizedBox(height: 8),

                          // Bottom Row: Attendees Count & View Details Hint
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const GradientIcon(
                                    icon: Icons.groups_rounded,
                                    size: 15,
                                    gradient: AppColors.brandGradient,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    ev.attendeesCount > 0
                                        ? '${ev.attendeesCount} Registered Attendees'
                                        : 'Open for Registration',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View Details',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  GradientIcon(
                                    icon: Icons.arrow_forward_ios_rounded,
                                    size: 10,
                                    gradient: AppColors.brandGradient,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
