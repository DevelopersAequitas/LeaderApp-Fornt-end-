import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../peers/model/peer_model.dart';
import '../../model/peer_profile_model.dart';

/// Renders the Overview tab content for Peer Profile (Stats, Celebrations, Meetings).
class PeerProfileOverviewSection extends StatelessWidget {
  final PeerModel peer;
  final PeerProfileDetailModel details;

  const PeerProfileOverviewSection({
    super.key,
    required this.peer,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStatsCard(),
        if (details.birthday.isNotEmpty || details.anniversary.isNotEmpty)
          _buildCelebrationsCard(),
        if (details.meetings.isNotEmpty) _buildMeetingsCard(),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.secondaryBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: const Text(
              'PERFORMANCE STATS',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          _buildStatRow(
            icon: Icons.card_membership_outlined,
            title: 'Deals Closed',
            value: details.dealsClosed,
            valueColor: const Color(0xFF16A34A),
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildStatRow(
            icon: Icons.campaign_outlined,
            title: 'Referrals Given',
            value: details.referralsGiven.toString(),
            valueColor: const Color(0xFF1E3C72),
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildStatRow(
            icon: Icons.swap_horiz_rounded,
            title: 'P2P Sessions',
            value: details.p2pSessions.toString(),
            valueColor: const Color(0xFFD97706),
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildStatRow(
            icon: Icons.monetization_on_outlined,
            title: 'Coins Earned',
            value: details.coinsEarned.toString(),
            valueColor: const Color(0xFFEAB308),
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildStatRow(
            icon: Icons.calendar_today_outlined,
            title: 'Attendance Rate',
            value: details.attendanceRate,
            valueColor: const Color(0xFF16A34A),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1E3C72), size: 17),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrationsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.secondaryBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: const Text(
              'CELEBRATIONS',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                if (details.birthday.isNotEmpty)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFEBD5)),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.cake_outlined,
                            color: Color(0xFFD97706),
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Birthday',
                            style: TextStyle(
                              color: Color(0xFFB45309),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            details.birthday,
                            style: const TextStyle(
                              color: Color(0xFF78350F),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (details.birthday.isNotEmpty &&
                    details.anniversary.isNotEmpty)
                  const SizedBox(width: 10),
                if (details.anniversary.isNotEmpty)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFDCFCE7)),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.celebration_outlined,
                            color: Color(0xFF15803D),
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Anniversary',
                            style: TextStyle(
                              color: Color(0xFF15803D),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            details.anniversary,
                            style: const TextStyle(
                              color: Color(0xFF14532D),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.secondaryBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CIRCLE MEETINGS',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                if (peer.circle.isNotEmpty)
                  Text(
                    peer.circle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          ...details.meetings.map(
            (m) => Column(
              children: [
                _buildMeetingRow(m),
                if (m != details.meetings.last)
                  const Divider(height: 1, color: AppColors.border),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingRow(PeerMeetingModel meeting) {
    Color statusBg = Colors.grey.shade100;
    Color statusText = Colors.grey.shade600;

    if (meeting.status == 'Confirmed') {
      statusBg = const Color(0xFFDCFCE7);
      statusText = const Color(0xFF16A34A);
    } else if (meeting.status == 'Open') {
      statusBg = const Color(0xFFEFF6FF);
      statusText = const Color(0xFF2563EB);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3C72),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  meeting.day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  meeting.month,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meeting.title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meeting.timeLocation,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              meeting.status,
              style: TextStyle(
                color: statusText,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
