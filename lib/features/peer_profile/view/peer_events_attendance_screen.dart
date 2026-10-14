import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../peers/model/peer_model.dart';
import '../bloc/peer_events_bloc.dart';
import '../bloc/peer_events_event.dart';
import '../bloc/peer_events_state.dart';
import '../model/peer_event_models.dart';

/// Screen displaying Member 360° Events, Event QR Passes, and Meeting Attendance.
class PeerEventsAttendanceScreen extends StatelessWidget {
  final PeerModel peer;

  const PeerEventsAttendanceScreen({super.key, required this.peer});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PeerEventsBloc>(
      create: (context) =>
          PeerEventsBloc()..add(LoadPeerEventsData(memberId: peer.id)),
      child: _PeerEventsAttendanceContent(peer: peer),
    );
  }
}

class _PeerEventsAttendanceContent extends StatelessWidget {
  final PeerModel peer;

  const _PeerEventsAttendanceContent({required this.peer});

  static Map<String, String> _formatDateTimeParts(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return {'date': '', 'time': ''};
    final dt = DateTime.tryParse(trimmed);
    if (dt == null) {
      return {'date': trimmed, 'time': ''};
    }
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

    final hasTime = trimmed.contains('T') || trimmed.contains(':');
    if (!hasTime) {
      return {'date': dateStr, 'time': ''};
    }

    final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minuteStr = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour12:$minuteStr $period';
    return {'date': dateStr, 'time': timeStr};
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PeerEventsBloc, PeerEventsState>(
      builder: (context, state) {
        final bloc = context.read<PeerEventsBloc>();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: CustomAppBar(
            title: 'Events & Attendance',
            subtitle: peer.name,
            showBackButton: true,
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                bloc.add(LoadPeerEventsData(memberId: peer.id, isRefresh: true));
              },
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Tab selector with gradient design for active tab
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          _buildTabButton(
                            context: context,
                            label: 'Attendance',
                            count: state.attendanceRecords.length,
                            isSelected: state.activeTab == 0,
                            onTap: () => bloc.add(const ChangePeerEventsTab(0)),
                          ),
                          _buildTabButton(
                            context: context,
                            label: 'Events',
                            count: state.events.length,
                            isSelected: state.activeTab == 1,
                            onTap: () => bloc.add(const ChangePeerEventsTab(1)),
                          ),
                          _buildTabButton(
                            context: context,
                            label: 'Event QR',
                            count: state.registrations.length,
                            isSelected: state.activeTab == 2,
                            onTap: () => bloc.add(const ChangePeerEventsTab(2)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Body Content
                  Expanded(
                    child: state.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : _buildTabContent(context, state),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabButton({
    required BuildContext context,
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
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

  Widget _buildTabContent(BuildContext context, PeerEventsState state) {
    switch (state.activeTab) {
      case 0:
        return _buildAttendanceTab(state.attendanceRecords);
      case 1:
        return _buildEventsTab(state.events);
      case 2:
        return _buildPassesTab(context, state.registrations);
      default:
        return const SizedBox.shrink();
    }
  }

  // --- Tab 1: Attendance Records ---
  Widget _buildAttendanceTab(List<MemberAttendanceRecordModel> records) {
    if (records.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_available_outlined,
        title: 'No Attendance Records',
        message: 'No assembly or circle meeting attendance records found.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final item = records[index];
        final isPresent = item.isPresent;
        final rawDate = item.meetingDate.isNotEmpty ? item.meetingDate : item.date;
        final dtParts = _formatDateTimeParts(rawDate);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Meeting Title & Gradient Present/Absent Pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.text,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: isPresent
                          ? const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (isPresent
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF43F5E))
                              .withValues(alpha: 0.28),
                          blurRadius: 4,
                          offset: const Offset(0, 1.5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPresent
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.status.isNotEmpty
                              ? item.status
                              : (isPresent ? 'Present' : 'Absent'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Date & Time with Gradient Icons
              if (dtParts['date']!.isNotEmpty)
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

              // Circle / Chapter Info
              if (item.circleName.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const GradientIcon(
                      icon: Icons.groups_rounded,
                      size: 14,
                      gradient: AppColors.brandGradient,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.circleName,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Venue / Location
              if (item.venue.isNotEmpty) ...[
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
                        item.venue,
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

              // Notes / Agenda
              if (item.notes.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: GradientIcon(
                          icon: Icons.note_alt_outlined,
                          size: 13,
                          gradient: AppColors.brandGradient,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.notes,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 11.5,
                            fontStyle: FontStyle.italic,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // --- Tab 2: Events List ---
  Widget _buildEventsTab(List<MemberEventItemModel> events) {
    if (events.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_note_outlined,
        title: 'No Member Events',
        message: 'No summits or conclaves registered for this member.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final ev = events[index];
        final isUpcoming = ev.isUpcoming;
        final dtParts = _formatDateTimeParts(ev.startAt);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Badges Row: Mode Pill with Gradient Icon & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Mode Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFDBEAFE)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GradientIcon(
                          icon: ev.formattedMode == 'Online'
                              ? Icons.videocam_rounded
                              : Icons.domain_rounded,
                          size: 12,
                          gradient: AppColors.brandGradient,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ev.formattedMode.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status Badge with Gradient
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      gradient: isUpcoming
                          ? AppColors.brandGradient
                          : const LinearGradient(
                              colors: [Color(0xFF64748B), Color(0xFF475569)],
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
                              : Icons.check_circle_outline_rounded,
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
              const SizedBox(height: 10),

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

              // Date & Timing Row with Gradient Icons
              if (dtParts['date']!.isNotEmpty) ...[
                const SizedBox(height: 8),
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
              ],

              // Location Row with Gradient Icon
              if (ev.locationText.isNotEmpty) ...[
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
                        ev.locationText,
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

              // Bottom Footer: Registration Status & Ticket / Payment
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Status: ${ev.registrationStatus}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (ev.isPaid && ev.ticketPrice > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.25),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 10.5,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Paid: ₹${ev.ticketPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Free Entry',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Tab 3: Event QR Passes ---
  Widget _buildPassesTab(
    BuildContext context,
    List<MemberEventRegistrationModel> passes,
  ) {
    if (passes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.qr_code_2_rounded,
        title: 'No Event QR Passes',
        message: 'No event passes or QR codes generated yet.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: passes.length,
      itemBuilder: (context, index) {
        final p = passes[index];
        final statusLower = p.qrStatus.toLowerCase();
        final isActive = statusLower == 'active' || statusLower == 'generated';
        final isExpired = statusLower == 'expired';
        final dtParts = _formatDateTimeParts(p.eventDate);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Event Name & Status Gradient Pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      p.eventName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.5,
                        color: AppColors.text,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                            )
                          : isExpired
                              ? const LinearGradient(
                                  colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                                )
                              : const LinearGradient(
                                  colors: [Color(0xFF64748B), Color(0xFF475569)],
                                ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: (isActive
                                  ? const Color(0xFF10B981)
                                  : isExpired
                                      ? const Color(0xFFF43F5E)
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
                          isActive
                              ? Icons.verified_rounded
                              : isExpired
                                  ? Icons.cancel_rounded
                                  : Icons.info_outline_rounded,
                          size: 11,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 3.5),
                        Text(
                          p.qrStatus.toUpperCase(),
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
              const SizedBox(height: 8),

              // Date & Payment Info with Gradient Icons
              Row(
                children: [
                  const GradientIcon(
                    icon: Icons.calendar_today_rounded,
                    size: 13,
                    gradient: AppColors.brandGradient,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    dtParts['date']!.isNotEmpty
                        ? dtParts['date']!
                        : (p.eventDate.isNotEmpty ? p.eventDate : 'Upcoming'),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (dtParts['time']!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    const GradientIcon(
                      icon: Icons.schedule_rounded,
                      size: 13,
                      gradient: AppColors.brandGradient,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dtParts['time']!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (p.paymentAmount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Text(
                        '₹${p.paymentAmount.toStringAsFixed(0)} ${p.paymentStatus.toUpperCase()}',
                        style: const TextStyle(
                          color: Color(0xFF047857),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 12),

              // Standard Sized Centered QR Code Display (140x140)
              Center(
                child: InkWell(
                  onTap: () => _showEnlargedQrDialog(context, p),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            p.effectiveQrUrl,
                            width: 140,
                            height: 140,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const SizedBox(
                                width: 140,
                                height: 140,
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 140,
                                height: 140,
                                color: const Color(0xFFF8FAFC),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.qr_code_2_rounded,
                                      size: 48,
                                      color: AppColors.textSecondary,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'QR Code',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GradientIcon(
                              icon: Icons.zoom_in_rounded,
                              size: 14,
                              gradient: AppColors.brandGradient,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Tap to enlarge pass',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
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
          ),
        );
      },
    );
  }

  void _showEnlargedQrDialog(
    BuildContext context,
    MemberEventRegistrationModel p,
  ) {
    final dtParts = _formatDateTimeParts(p.eventDate);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Event QR Pass',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                p.eventName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),
              if (dtParts['date']!.isNotEmpty || p.eventDate.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  dtParts['date']!.isNotEmpty ? dtParts['date']! : p.eventDate,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Full size standard QR code (220x220)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    p.effectiveQrUrl,
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        width: 220,
                        height: 220,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const SizedBox(
                      width: 220,
                      height: 220,
                      child: Center(
                        child: Icon(
                          Icons.qr_code_2_rounded,
                          size: 72,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                'Show this QR pass at the entrance for instant check-in verification.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SquareRoundedGradientIcon(
                icon: icon,
                boxSize: 56,
                iconSize: 28,
                borderRadius: 16,
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                message,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
