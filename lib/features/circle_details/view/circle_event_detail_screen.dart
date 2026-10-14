import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../peers/model/peer_model.dart';
import '../../peers/view/widgets/peer_card.dart';
import '../../teams/model/teams_model.dart';
import '../model/circle_event_model.dart';

/// Dedicated standalone screen displaying comprehensive details for a Circle Event.
/// Completely separates Circle Members and Registered Visitors into distinct,
/// dedicated places with theme-consistent tabs and visitor cards.
class CircleEventDetailScreen extends StatefulWidget {
  final CircleEventModel event;
  final CircleTeamModel? circle;
  final List<PeerModel> attendingPeers;
  final List<PeerModel> visitors;

  const CircleEventDetailScreen({
    super.key,
    required this.event,
    this.circle,
    this.attendingPeers = const [],
    this.visitors = const [],
  });

  @override
  State<CircleEventDetailScreen> createState() =>
      _CircleEventDetailScreenState();
}

class _CircleEventDetailScreenState extends State<CircleEventDetailScreen> {
  // 0 = Circle Members, 1 = Registered Visitors & Guests
  int _selectedAttendeeTab = 0;

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
    final isUpcoming = widget.event.isUpcoming;

    // Combine all available peers and partition into members vs visitors
    final allPeers = <PeerModel>[
      ...widget.attendingPeers,
      ...widget.event.attendees,
      ...widget.visitors,
    ];
    final uniquePeers = <String, PeerModel>{};
    for (final p in allPeers) {
      final key = p.id.isNotEmpty ? p.id : '${p.name}_${p.company}';
      uniquePeers[key] = p;
    }
    final allUnique = uniquePeers.values.toList();

    // Separate lists: Members place vs Visitors place
    final members = allUnique.where((p) => !p.isVisitor).toList();
    final visitors = allUnique.where((p) => p.isVisitor).toList();

    final totalAttendees = widget.event.attendeesCount > 0
        ? widget.event.attendeesCount
        : allUnique.length;

    final dtParts =
        _formatDateTimeParts(widget.event.date, widget.event.time);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Event Details',
        subtitle: widget.circle?.name.isNotEmpty == true
            ? widget.circle!.name
            : 'Circle Assembly & Gathering',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Event Hero Information Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Badges Row: Mode & Gradient Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Mode Pill with Gradient Icon
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GradientIcon(
                                icon: widget.event.mode
                                        .toLowerCase()
                                        .contains('online')
                                    ? Icons.videocam_rounded
                                    : Icons.domain_rounded,
                                size: 13,
                                gradient: AppColors.brandGradient,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.event.mode.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Status Badge with Gradient
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
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
                            borderRadius: BorderRadius.circular(8),
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
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.event.status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Event Title
                    Text(
                      widget.event.title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 14),

                    // Date & Time Row with SquareRoundedGradientIcon
                    _buildDetailRow(
                      icon: Icons.calendar_month_rounded,
                      label: 'DATE & TIME',
                      value: dtParts['date']! +
                          (dtParts['time']!.isNotEmpty
                              ? '  ·  ${dtParts['time']!}'
                              : ''),
                    ),

                    // Location / Venue
                    if (widget.event.location.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        icon: Icons.location_on_rounded,
                        label: 'LOCATION & VENUE',
                        value: widget.event.location,
                      ),
                    ],

                    // Organizing Circle
                    if (widget.circle != null &&
                        widget.circle!.name.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        icon: Icons.groups_rounded,
                        label: 'ORGANIZING CIRCLE',
                        value: widget.circle!.name,
                      ),
                    ],

                    // Attendance Summary
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.how_to_reg_rounded,
                      label: 'ATTENDANCE SUMMARY',
                      value: totalAttendees > 0
                          ? '$totalAttendees Total Registered Attendees'
                          : 'Registration Open',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Separate Segmented Tabs for Members vs Visitors
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _buildAttendeeTabButton(
                      label: 'Circle Members',
                      count: members.length,
                      isSelected: _selectedAttendeeTab == 0,
                      onTap: () => setState(() => _selectedAttendeeTab = 0),
                    ),
                    _buildAttendeeTabButton(
                      label: 'Visitors & Guests',
                      count: visitors.length,
                      isSelected: _selectedAttendeeTab == 1,
                      onTap: () => setState(() => _selectedAttendeeTab = 1),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Dynamic Place Content: Separated Members Place vs Visitors Place
              if (_selectedAttendeeTab == 0)
                _buildMembersPlace(members)
              else
                _buildVisitorsPlace(visitors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendeeTabButton({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
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
                      color: AppColors.primary.withValues(alpha: 0.28),
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
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
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
  }

  // --- Place 1: Circle Members Place ---
  Widget _buildMembersPlace(List<PeerModel> members) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Registered Circle Members',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (members.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 1.5),
                    ),
                  ],
                ),
                child: Text(
                  '${members.length} Members',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (members.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SquareRoundedGradientIcon(
                    icon: Icons.people_outline_rounded,
                    boxSize: 52,
                    iconSize: 26,
                    borderRadius: 14,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No Circle Members Registered Yet',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Members of this circle will appear here when registered.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...members.map(
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
    );
  }

  // --- Place 2: Dedicated Visitors & Guests Place ---
  Widget _buildVisitorsPlace(List<PeerModel> visitors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Registered Visitors & Guests',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (visitors.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.28),
                      blurRadius: 4,
                      offset: const Offset(0, 1.5),
                    ),
                  ],
                ),
                child: Text(
                  '${visitors.length} Visitors',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (visitors.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SquareRoundedGradientIcon(
                    icon: Icons.person_add_alt_1_rounded,
                    boxSize: 52,
                    iconSize: 26,
                    borderRadius: 14,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No Visitors Registered',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Guests and external visitors registered for this gathering will appear in this dedicated section separate from members.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...visitors.map((visitor) => _buildVisitorCard(context, visitor)),
      ],
    );
  }

  // Dedicated Visitor Card
  Widget _buildVisitorCard(BuildContext context, PeerModel visitor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
          Row(
            children: [
              // Visitor Avatar / Initials
              InitialsAvatar(
                name: visitor.name,
                imageUrl: visitor.avatarUrl,
                radius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visitor.name,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      visitor.company.isNotEmpty
                          ? visitor.company
                          : (visitor.designation?.isNotEmpty == true
                              ? visitor.designation!
                              : 'External Guest'),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Dedicated Visitor Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 11,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'VISITOR',
                      style: TextStyle(
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

          if (visitor.tags.isNotEmpty || visitor.location.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 8),
            Row(
              children: [
                if (visitor.tags.isNotEmpty) ...[
                  const GradientIcon(
                    icon: Icons.business_center_outlined,
                    size: 13,
                    gradient: AppColors.brandGradient,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      visitor.tags,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                if (visitor.location.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  const GradientIcon(
                    icon: Icons.location_on_outlined,
                    size: 13,
                    gradient: AppColors.brandGradient,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    visitor.location,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SquareRoundedGradientIcon(
          icon: icon,
          boxSize: 36,
          iconSize: 18,
          borderRadius: 10,
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
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
