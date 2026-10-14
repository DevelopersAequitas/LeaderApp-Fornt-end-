import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../peers/model/peer_model.dart';
import '../../../peers/view/widgets/peer_card.dart';
import '../../../teams/model/teams_model.dart';
import '../../model/circle_event_model.dart';

import '../circle_event_detail_screen.dart';

/// Modal bottom sheet presenting comprehensive details and registered peers for a Circle Event.
/// Adheres strictly to the Peers Tab standard for peer list display and navigation.
class EventDetailsBottomSheet extends StatelessWidget {
  final CircleEventModel event;
  final CircleTeamModel? circle;
  final List<PeerModel> attendingPeers;

  const EventDetailsBottomSheet({
    super.key,
    required this.event,
    this.circle,
    this.attendingPeers = const [],
  });

  static Future<void> show(
    BuildContext context, {
    required CircleEventModel event,
    CircleTeamModel? circle,
    List<PeerModel> attendingPeers = const [],
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CircleEventDetailScreen(
          event: event,
          circle: circle,
          attendingPeers: attendingPeers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUpcoming = event.isUpcoming;
    final totalAttendees = event.attendeesCount > 0
        ? event.attendeesCount
        : (attendingPeers.isNotEmpty ? attendingPeers.length : 0);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle & top bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        circle?.name.isNotEmpty == true
                            ? circle!.name
                            : 'Circle Assembly & Gathering',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Event Overview & Attendees',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.text),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 14),

                  // Event Info Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status & Mode pills
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isUpcoming
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                event.status.toUpperCase(),
                                style: TextStyle(
                                  color: isUpcoming
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFF64748B),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                event.mode.toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF1D4ED8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Title
                        Text(
                          event.title,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1, color: AppColors.border),
                        const SizedBox(height: 12),

                        // Date & Time
                        _buildInfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'DATE & TIME',
                          value: '${event.date} · ${event.time}',
                        ),
                        const SizedBox(height: 10),

                        // Location
                        if (event.location.isNotEmpty) ...[
                          _buildInfoRow(
                            icon: Icons.location_on_outlined,
                            label: 'LOCATION & VENUE',
                            value: event.location,
                          ),
                          const SizedBox(height: 10),
                        ],

                        // Attendees Count
                        _buildInfoRow(
                          icon: Icons.groups_outlined,
                          label: 'REGISTERED PEERS',
                          value: totalAttendees > 0
                              ? '$totalAttendees Peers Attending'
                              : 'Registration Open',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Attending Peers Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Participating Circle Peers',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (totalAttendees > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$totalAttendees Peers',
                              style: const TextStyle(
                                color: Color(0xFFB45309),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Display peers following standard PeerCard style
                  if (attendingPeers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.people_outline_rounded,
                              size: 38,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Circle members will appear here as they register.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...attendingPeers.map(
                      (peer) => PeerCard(
                        peer: peer,
                        selectedSort: 'Impact',
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.peerProfile,
                            arguments: peer,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
