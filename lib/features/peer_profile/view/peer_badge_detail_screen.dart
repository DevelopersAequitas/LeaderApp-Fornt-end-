import 'package:flutter/material.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/widgets.dart';
import '../model/peer_profile_model.dart';

/// Full-screen white theme display view for a member badge matching the LeaderApp design system.
class PeerBadgeDetailScreen extends StatelessWidget {
  final PeerBadgeModel badge;
  final String peerName;

  const PeerBadgeDetailScreen({
    super.key,
    required this.badge,
    this.peerName = '',
  });

  static void open(
    BuildContext context, {
    required PeerBadgeModel badge,
    String peerName = '',
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PeerBadgeDetailScreen(
          badge: badge,
          peerName: peerName,
        ),
      ),
    );
  }

  String _formatEarnedDate(String rawDate) {
    if (rawDate.isEmpty) {
      return '';
    }
    try {
      final clean = rawDate.split('T').first;
      final parts = clean.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final monthInt = int.tryParse(parts[1]) ?? 1;
        final day = parts[2];
        const monthNames = [
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
        final monthStr = monthNames[(monthInt - 1).clamp(0, 11)];
        return '$monthStr $day, $year';
      }
      return clean;
    } catch (_) {
      return rawDate;
    }
  }

  Widget _buildFallbackBadgeIcon() {
    return Container(
      width: 150,
      height: 150,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        shape: BoxShape.circle,
      ),
      child: ShaderMask(
        shaderCallback: (bounds) => AppColor.brandGradient.createShader(bounds),
        child: const Icon(
          Icons.workspace_premium_rounded,
          color: Colors.white,
          size: 72,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double progress = badge.requiredCount > 0
        ? (badge.achievedCount / badge.requiredCount).clamp(0.0, 1.0)
        : 1.0;

    final earnedDateText = _formatEarnedDate(badge.earnedAt ?? '');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Badge Details',
        subtitle: peerName.isNotEmpty ? peerName : badge.badgeName,
        showBackButton: true,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              // 1. Centered Badge Showcase Header
              Center(
                child: Column(
                  children: [
                    if (badge.badgeImage.isNotEmpty) ...[
                      Hero(
                        tag: 'badge_img_${badge.id}_${badge.badgeId}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            badge.badgeImage,
                            width: 180,
                            height: 180,
                            fit: BoxFit.contain,
                            errorBuilder: (
                              BuildContext errCtx,
                              Object err,
                              StackTrace? st,
                            ) {
                              return _buildFallbackBadgeIcon();
                            },
                          ),
                        ),
                      ),
                    ] else ...[
                      _buildFallbackBadgeIcon(),
                    ],
                    const SizedBox(height: 18),

                    // Badge Name
                    Text(
                      badge.badgeName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                        letterSpacing: 0.1,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // Badge Type Pill
                    if (badge.badgeType.isNotEmpty ||
                        badge.milestoneType.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColor.brandGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          (badge.badgeType.isNotEmpty
                                  ? badge.badgeType
                                  : badge.milestoneType)
                              .replaceAll('_', ' ')
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 2. Description Section
              if (badge.badgeDescription.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColor.brandGradient.createShader(bounds),
                            child: const Icon(
                              Icons.format_quote_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'DESCRIPTION & INSIGHT',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        badge.badgeDescription,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 3. Milestone Progress Section
              if (badge.requiredCount > 0) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColor.brandGradient.createShader(bounds),
                            child: const Icon(
                              Icons.military_tech_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'MILESTONE PROGRESS',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Achieved vs Target',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColor.brandGradient.createShader(bounds),
                            child: Text(
                              '${badge.achievedCount} / ${badge.requiredCount}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Gradient Progress Bar
                      Container(
                        height: 9,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppColor.brandGradient,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 4. Earned Date Status Banner
              if (earnedDateText.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Color(0xFF16A34A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Badge Earned & Verified',
                              style: TextStyle(
                                color: Color(0xFF15803D),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Earned on $earnedDateText',
                              style: const TextStyle(
                                color: Color(0xFF166534),
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
