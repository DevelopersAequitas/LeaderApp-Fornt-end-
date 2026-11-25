import 'package:flutter/material.dart';
import '../../../../core/notifications/notification_highlight_wrapper.dart';
import '../../../../core/notifications/notification_list_focus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../peers/model/peer_model.dart';
import '../../../teams/model/teams_model.dart';
import '../../model/circle_event_model.dart';
import '../circle_event_detail_screen.dart';

/// Renders the Events list with interactive gradient filter tabs, theme-consistent
/// assembly cards, and navigation to the dedicated event detail screen.
class CircleEventsSection extends StatefulWidget {
  final List<CircleEventModel> events;
  final List<CircleEventModel> allEvents;
  final bool isLoading;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final CircleTeamModel? circle;
  final List<PeerModel> peers;
  final String? focusEventId;

  const CircleEventsSection({
    super.key,
    required this.events,
    this.allEvents = const [],
    required this.isLoading,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.circle,
    this.peers = const [],
    this.focusEventId,
  });

  @override
  State<CircleEventsSection> createState() => _CircleEventsSectionState();
}

class _CircleEventsSectionState extends State<CircleEventsSection> {
  final NotificationListFocusController _focusController =
      NotificationListFocusController();
  final Map<String, GlobalKey> _eventKeys = <String, GlobalKey>{};

  @override
  void initState() {
    super.initState();
    final id = widget.focusEventId?.trim() ?? '';
    if (id.isNotEmpty) {
      _focusController.setTarget(
        NotificationListFocusRequest(targetId: id, targetType: 'event'),
      );
    }
  }

  @override
  void didUpdateWidget(covariant CircleEventsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusEventId != oldWidget.focusEventId) {
      final id = widget.focusEventId?.trim() ?? '';
      if (id.isNotEmpty) {
        _focusController.setTarget(
          NotificationListFocusRequest(targetId: id, targetType: 'event'),
        );
      }
    }
  }

  @override
  void dispose() {
    _focusController.dispose();
    super.dispose();
  }

  GlobalKey _keyFor(String id) =>
      _eventKeys.putIfAbsent(id, () => GlobalKey());

  @override
  Widget build(BuildContext context) {
    final events = widget.events;
    final allEvents = widget.allEvents;
    final isLoading = widget.isLoading;
    final selectedFilter = widget.selectedFilter;
    final onFilterChanged = widget.onFilterChanged;
    final circle = widget.circle;
    final peers = widget.peers;

    final sourceEvents = allEvents.isNotEmpty ? allEvents : events;
    final allCount = sourceEvents.length;
    final upcomingCount = sourceEvents.where((e) => e.isUpcoming).length;
    final completedCount = sourceEvents.where((e) => e.isCompleted).length;

    if (!isLoading && _focusController.pendingRequest != null) {
      final targetId = _focusController.pendingRequest!.targetId;
      final inFiltered = events.any((e) => e.id == targetId);
      final inAll = allEvents.any((e) => e.id == targetId);
      if (!inFiltered && inAll && selectedFilter != 'All') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) onFilterChanged('All');
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          await _focusController.resolveTarget<CircleEventModel>(
            items: events,
            idOf: (e) => e.id,
            hasMore: () => false,
            loadMore: () async {},
            keyLookup: (id) => _eventKeys[id],
          );
          if (mounted &&
              _focusController.notFound &&
              _focusController.statusMessage != null) {
            ScaffoldMessenger.of(this.context).showSnackBar(
              SnackBar(content: Text(_focusController.statusMessage!)),
            );
          }
        });
      }
    }

    final filterItems = [
      {'label': 'All', 'count': allCount},
      {'label': 'Upcoming', 'count': upcomingCount},
      {'label': 'Completed', 'count': completedCount},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Recurring Conclave Schedule Banner
        if (circle?.cadence != null && circle!.cadence!.hasSchedule)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_repeat_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recurring Circle Cadence',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          circle!.effectiveCadenceText,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

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
            child: ListShimmerSkeleton(),
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
            child: ListenableBuilder(
              listenable: _focusController,
              builder: (context, _) {
                final activeId = _focusController.highlightedId;
                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: events.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemBuilder: (context, idx) {
              final ev = events[idx];
              final isUpcoming = ev.isUpcoming;
              final schedule = ev.formattedSchedule();

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

              return NotificationHighlightWrapper(
                key: _keyFor(ev.id),
                itemId: ev.id,
                activeTargetId: activeId,
                onHighlightCompleted: () =>
                    _focusController.markHighlightCompleted(ev.id),
                borderRadius: BorderRadius.circular(16),
                child: Container(
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

                          // Date & Time Row with timezone-aware formatting
                          Row(
                            children: [
                              const GradientIcon(
                                icon: Icons.calendar_today_rounded,
                                size: 13,
                                gradient: AppColors.brandGradient,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  schedule.dateLabel,
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const GradientIcon(
                                icon: Icons.schedule_rounded,
                                size: 13,
                                gradient: AppColors.brandGradient,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  schedule.timeLabel.isNotEmpty
                                      ? schedule.timeLabel
                                      : 'Time TBD',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
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
              ),
              );
            },
          );
              },
            ),
        ),
      ],
    );
  }
}
