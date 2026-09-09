import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/p2p_meeting_model.dart';

class P2PMeetingCard extends StatelessWidget {
  final P2PMeetingModel meeting;
  final VoidCallback? onTap;

  const P2PMeetingCard({
    super.key,
    required this.meeting,
    this.onTap,
  });

  void _navigateToPeer(BuildContext context) {
    Navigator.of(context).pushNamed(
      AppRoutes.peerProfile,
      arguments: meeting.toPeerModel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = meeting.status.toLowerCase() == 'completed';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap ?? () => _navigateToPeer(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Peer Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InitialsAvatar(
                      name: meeting.peerName,
                      imageUrl: meeting.profileImage.isNotEmpty ? meeting.profileImage : null,
                      radius: 20,
                      backgroundColor: const Color(0xFF0284C7),
                      fontSize: 11,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  meeting.peerName,
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? const Color(0xFFF0FDF4)
                                      : const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isCompleted
                                        ? const Color(0xFFBBF7D0)
                                        : const Color(0xFFDBEAFE),
                                  ),
                                ),
                                child: Text(
                                  meeting.status.toUpperCase(),
                                  style: TextStyle(
                                    color: isCompleted
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFF2563EB),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            [
                              if (meeting.businessName.isNotEmpty) meeting.businessName,
                              if (meeting.city.isNotEmpty) meeting.city,
                              if (meeting.categoryLevel4.isNotEmpty) meeting.categoryLevel4,
                            ].join(' · '),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Location & Schedule
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        meeting.mode.toLowerCase() == 'online'
                            ? Icons.videocam_outlined
                            : Icons.place_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          meeting.location.isNotEmpty ? meeting.location : meeting.mode.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (meeting.scheduledAt.isNotEmpty) ...[
                        const Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          meeting.scheduledAt,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (meeting.notes.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    meeting.notes,
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.9),
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'View Peer Profile',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
