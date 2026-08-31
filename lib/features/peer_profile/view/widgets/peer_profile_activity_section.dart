import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/expandable_text.dart';
import '../../model/peer_profile_model.dart';

/// Renders the Activity tab list items for Peer Profile.
class PeerProfileActivitySection extends StatelessWidget {
  final List<PeerActivityModel> activities;

  const PeerProfileActivitySection({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            'No recent activity recorded.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

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
              'RECENT ACTIVITY',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...activities.map((act) => _buildActivityRow(act, activities)),
        ],
      ),
    );
  }

  Widget _buildActivityRow(
    PeerActivityModel activity,
    List<PeerActivityModel> all,
  ) {
    IconData iconData = Icons.notifications_none_rounded;
    Color iconColor = const Color(0xFF2563EB);
    Color iconBg = const Color(0xFFEFF6FF);

    switch (activity.iconType) {
      case 'arrows':
        iconData = Icons.swap_horiz_rounded;
        iconColor = const Color(0xFFD97706);
        iconBg = const Color(0xFFFEF3C7);
        break;
      case 'speaker':
        iconData = Icons.campaign_outlined;
        iconColor = const Color(0xFF2563EB);
        iconBg = const Color(0xFFEFF6FF);
        break;
      case 'star':
        iconData = Icons.star_rounded;
        iconColor = const Color(0xFFEAB308);
        iconBg = const Color(0xFFFEF9C3);
        break;
      case 'trophy':
        iconData = Icons.emoji_events_outlined;
        iconColor = const Color(0xFF16A34A);
        iconBg = const Color(0xFFDCFCE7);
        break;
      case 'target':
        iconData = Icons.track_changes_outlined;
        iconColor = const Color(0xFF7C3AED);
        iconBg = const Color(0xFFF3E8FF);
        break;
    }

    final isLast = all.last == activity;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(iconData, color: iconColor, size: 17),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (activity.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      ExpandableText(
                        text: activity.subtitle,
                        maxLines: 2,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                activity.time,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}
