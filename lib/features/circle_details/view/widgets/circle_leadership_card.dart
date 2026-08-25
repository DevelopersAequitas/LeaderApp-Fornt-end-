import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../teams/model/teams_model.dart';

/// Renders the comprehensive Circle Leadership section in Material 3 style.
class CircleLeadershipCard extends StatelessWidget {
  final CircleTeamModel circle;

  const CircleLeadershipCard({super.key, required this.circle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Circle Leadership Team',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Core Office',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLeaderRow(
            roleTitle: 'Circle Founder',
            name: circle.founderName,
            roleBadge: 'Founder 🔒',
            badgeBg: const Color(0xFFFEF3C7),
            badgeFg: const Color(0xFFD97706),
            avatarBg: const Color(0xFF1E3C72),
            responsibility: 'Vision, Founding Network & Core Strategy',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: AppColors.border),
          ),
          _buildLeaderRow(
            roleTitle: 'Circle Director',
            name: circle.directorName,
            roleBadge: 'Director',
            badgeBg: const Color(0xFFEBF3FB),
            badgeFg: const Color(0xFF1E3C72),
            avatarBg: const Color(0xFF2563EB),
            responsibility: 'Regional Growth, Alignment & Guidance',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: AppColors.border),
          ),
          _buildLeaderRow(
            roleTitle: 'Circle Chair',
            name: circle.chairName,
            roleBadge: 'Chair',
            badgeBg: const Color(0xFFDCFCE7),
            badgeFg: const Color(0xFF16A34A),
            avatarBg: const Color(0xFF16A34A),
            responsibility: 'Chapter Operations, Meetings & Attendance',
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderRow({
    required String roleTitle,
    required String name,
    required String roleBadge,
    required Color badgeBg,
    required Color badgeFg,
    required Color avatarBg,
    required String responsibility,
  }) {
    final bool isAssigned = name.trim().isNotEmpty && name != 'Unassigned';
    final displayName = isAssigned ? name : 'Unassigned';

    return Row(
      children: [
        InitialsAvatar(
          name: displayName,
          radius: 18,
          backgroundColor: isAssigned ? avatarBg : Colors.grey.shade400,
          textColor: Colors.white,
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
                      displayName,
                      style: TextStyle(
                        color: isAssigned ? AppColors.text : Colors.grey.shade500,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
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
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      roleBadge,
                      style: TextStyle(
                        color: badgeFg,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                responsibility,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
