import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/peer_model.dart';

/// Standard Material 3 Peer Card used across all peer listings in the app.
/// Prominently displays the 6 key peer information points:
/// 1. Peer Profile Name (+ Verified badge & Avatar photo/initials)
/// 2. City / Location
/// 3. Designation
/// 4. Company Name
/// 5. Category (Level 4 Category / Specialization)
/// 6. Lives Impacted Count
/// 
/// Fully clickable with ripple animation to navigate directly to the Peer Profile screen.
class PeerCard extends StatelessWidget {
  final PeerModel peer;
  final String? selectedSort;
  final VoidCallback? onTap;

  const PeerCard({
    super.key,
    required this.peer,
    this.selectedSort,
    this.onTap,
  });

  Color _getStatusBg(String status) {
    final s = status.toLowerCase();
    if (s.contains('active')) return const Color(0xFFDCFCE7);
    if (s.contains('risk')) return const Color(0xFFFEE2E2);
    if (s.contains('attention') || s.contains('pending')) return const Color(0xFFFEF3C7);
    return const Color(0xFFF3F4F6);
  }

  Color _getStatusText(String status) {
    final s = status.toLowerCase();
    if (s.contains('active')) return const Color(0xFF16A34A);
    if (s.contains('risk')) return const Color(0xFFDC2626);
    if (s.contains('attention') || s.contains('pending')) return const Color(0xFFD97706);
    return const Color(0xFF4B5563);
  }

  @override
  Widget build(BuildContext context) {
    final statusBg = _getStatusBg(peer.status);
    final statusText = _getStatusText(peer.status);

    // 1. Designation & Company Name
    final displayDesignation = peer.designation != null &&
            peer.designation!.trim().isNotEmpty
        ? peer.designation!.trim()
        : '';
    final displayCompany = peer.company.trim();

    String subtitle = '';
    if (displayDesignation.isNotEmpty && displayCompany.isNotEmpty) {
      subtitle = '$displayDesignation · $displayCompany';
    } else if (displayDesignation.isNotEmpty) {
      subtitle = displayDesignation;
    } else {
      subtitle = displayCompany;
    }

    // 2. Category / Level 4
    final displayCategory = peer.level4Category != null &&
            peer.level4Category!.trim().isNotEmpty
        ? peer.level4Category!.trim()
        : (peer.tags.isNotEmpty
            ? peer.tags
            : (peer.industry ?? ''));

    // Optional Sort Specific Metric Tag
    String? sortMetricText;
    Color sortMetricBg = const Color(0xFFEFF6FF);
    Color sortMetricTextCol = const Color(0xFF1D4ED8);

    if (selectedSort == 'Deals' && peer.dealsFormatted.isNotEmpty) {
      sortMetricText = 'Deals: ${peer.dealsFormatted}';
      sortMetricBg = const Color(0xFFDCFCE7);
      sortMetricTextCol = const Color(0xFF15803D);
    } else if (selectedSort == 'Coins' && peer.coins > 0) {
      sortMetricText = '${peer.coins} Coins';
      sortMetricBg = const Color(0xFFFEF3C7);
      sortMetricTextCol = const Color(0xFFB45309);
    } else if (selectedSort == 'Attendance' && peer.attendance.isNotEmpty) {
      sortMetricText = 'Attend: ${peer.attendance}';
      sortMetricBg = const Color(0xFFFAF5FF);
      sortMetricTextCol = const Color(0xFF7E22CE);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap ??
              () {
                Navigator.of(context).pushNamed(
                  AppRoutes.peerProfile,
                  arguments: peer,
                );
              },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Row: Avatar + Name & Designation/Company + Status Pill + Chevron
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. Avatar (Network photo with initials fallback)
                    InitialsAvatar(
                      name: peer.name,
                      imageUrl: peer.avatarUrl,
                      radius: 22,
                      backgroundColor: AppColors.primary,
                      fontSize: 13,
                    ),
                    const SizedBox(width: 10),
                    // 2. Name, Verified Badge & Designation/Company
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  peer.name,
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (peer.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 14,
                                ),
                              ],
                            ],
                          ),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Status Pill
                    if (peer.status.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          peer.status,
                          style: TextStyle(
                            color: statusText,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 8),
                // Mandatory Badges Row (The 6 key pieces of info)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // 1. Lives Impacted Count
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFDE68A),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 11,
                            color: Color(0xFFD97706),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${peer.impactCount} Lives Impacted',
                            style: const TextStyle(
                              color: Color(0xFFB45309),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 2. Category / Level 4
                    if (displayCategory.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.border,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.category_outlined,
                              size: 11,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 140),
                              child: Text(
                                displayCategory,
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // 3. City / Location
                    if (peer.location.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.border,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 11,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              peer.location,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // 4. Optional Sort-specific metric badge
                    if (sortMetricText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: sortMetricBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          sortMetricText,
                          style: TextStyle(
                            color: sortMetricTextCol,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
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
