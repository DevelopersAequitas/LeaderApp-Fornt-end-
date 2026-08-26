import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/referral_model.dart';

/// Renders a Material 3 executive referral performance card for peers.
class ReferralCard extends StatelessWidget {
  final ReferralModel referral;
  final VoidCallback? onTap;

  const ReferralCard({
    super.key,
    required this.referral,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Top rank badge colors
    Color badgeColor = const Color(0xFF64748B);
    if (referral.rank == 1) {
      badgeColor = const Color(0xFFD97706); // Gold / Amber
    } else if (referral.rank == 2) {
      badgeColor = const Color(0xFF2563EB); // Royal Blue
    } else if (referral.rank == 3) {
      badgeColor = const Color(0xFF16A34A); // Emerald Green
    }

    final isRank1 = referral.rank == 1;
    final referralsBoxBg =
        isRank1 ? const Color(0xFFFEF3C7) : const Color(0xFFEFF6FF);
    final referralsBoxBorder =
        isRank1 ? const Color(0xFFFDE68A) : const Color(0xFFBFDBFE);
    final referralsBoxTextColor =
        isRank1 ? const Color(0xFFB45309) : const Color(0xFF1E40AF);

    final isStatusActive = referral.status.toLowerCase() == 'active';
    final statusBg =
        isStatusActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
    final statusTextColor =
        isStatusActive ? const Color(0xFF166534) : const Color(0xFF991B1B);

    final isSourceDirect = referral.source.toLowerCase() == 'direct';
    final sourceBorder =
        isSourceDirect ? const Color(0xFF86EFAC) : const Color(0xFF93C5FD);
    final sourceTextColor =
        isSourceDirect ? const Color(0xFF15803D) : const Color(0xFF1D4ED8);

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Row: Avatar with Rank Badge + Name & Company + Referrals Count
                Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        InitialsAvatar(
                          name: referral.name,
                          radius: 20,
                          backgroundColor: const Color(0xFF1E3C72),
                          fontSize: 12,
                        ),
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: badgeColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${referral.rank}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            referral.name,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (referral.company.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            Text(
                              referral.company,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Referrals Count Box
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: referralsBoxBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: referralsBoxBorder, width: 1),
                      ),
                      child: Text(
                        '${referral.referralCount} refs',
                        style: TextStyle(
                          color: referralsBoxTextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Pill Tags Row (Safely wrapped with Flexible / Wrap)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        referral.status,
                        style: TextStyle(
                          color: statusTextColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: sourceBorder),
                      ),
                      child: Text(
                        referral.source,
                        style: TextStyle(
                          color: sourceTextColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (referral.category.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          referral.category,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 10),
                // 5-Metric Strip
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        'Attend',
                        referral.attendanceRate,
                      ),
                    ),
                    Expanded(
                      child: _buildMetricTile(
                        'P2P',
                        '${referral.p2pCount}',
                      ),
                    ),
                    Expanded(
                      child: _buildMetricTile(
                        'Refs',
                        '${referral.referralsCount}',
                      ),
                    ),
                    Expanded(
                      child: _buildMetricTile(
                        'Deals',
                        referral.dealsCount,
                      ),
                    ),
                    Expanded(
                      child: _buildMetricTile(
                        'Coins',
                        '${referral.coinsCount}',
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

  Widget _buildMetricTile(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
