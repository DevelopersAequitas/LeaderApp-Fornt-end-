import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../peers/model/peer_model.dart';
import '../../model/coin_balance_model.dart';

/// Renders a Material 3 executive coin balance card for ranked circle peers.
class PeerCoinCard extends StatelessWidget {
  final CoinBalanceModel peer;
  final VoidCallback? onTap;

  const PeerCoinCard({
    super.key,
    required this.peer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Top rank badge colors
    Color badgeColor = const Color(0xFF64748B);
    if (peer.rank == 1) {
      badgeColor = const Color(0xFFD97706); // Gold / Amber
    } else if (peer.rank == 2) {
      badgeColor = const Color(0xFF2563EB); // Royal Blue
    } else if (peer.rank == 3) {
      badgeColor = const Color(0xFF16A34A); // Emerald Green
    }

    final isRank1 = peer.rank == 1;
    final coinsBoxBg =
        isRank1 ? const Color(0xFFFEF3C7) : const Color(0xFFEFF6FF);
    final coinsBoxBorder =
        isRank1 ? const Color(0xFFFDE68A) : const Color(0xFFBFDBFE);
    final coinsBoxTextColor =
        isRank1 ? const Color(0xFFB45309) : const Color(0xFF1E40AF);

    final isStatusActive = peer.status.toLowerCase() == 'active';
    final statusBg =
        isStatusActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
    final statusTextColor =
        isStatusActive ? const Color(0xFF166534) : const Color(0xFF991B1B);

    final isSourceDirect = peer.source.toLowerCase() == 'direct';
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
          onTap: onTap ??
              () {
                final p = PeerModel(
                  id: peer.id,
                  initials: peer.name.isNotEmpty
                      ? (peer.name.split(' ').length > 1
                          ? '${peer.name.split(' ')[0][0]}${peer.name.split(' ')[1][0]}'
                          : peer.name.substring(0, 1))
                      : 'P',
                  name: peer.name,
                  company: peer.company,
                  circle: peer.circle,
                  location: '',
                  tags: peer.category,
                  impactCount: peer.p2pCount,
                  dealsFormatted: peer.dealsCount,
                  coins: peer.coins,
                  attendance: peer.attendanceRate,
                  status: peer.status,
                );
                Navigator.of(context).pushNamed(
                  AppRoutes.peerProfile,
                  arguments: p,
                );
              },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Row: Avatar with Rank Badge + Name & Company + Coins Box
                Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        InitialsAvatar(
                          name: peer.name,
                          radius: 20,
                          backgroundColor: AppColors.primary,
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
                              '${peer.rank}',
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
                            peer.name,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (peer.company.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            Text(
                              peer.company,
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
                    // Coins Counter Box
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: coinsBoxBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: coinsBoxBorder, width: 1),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${peer.coins}',
                            style: TextStyle(
                              color: coinsBoxTextColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'COINS',
                            style: TextStyle(
                              color: coinsBoxTextColor.withValues(alpha: 0.75),
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Pill Tags Row (Safely wrapped with Wrap)
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
                        peer.status,
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
                        peer.source,
                        style: TextStyle(
                          color: sourceTextColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (peer.category.isNotEmpty)
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
                          peer.category,
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
                // 5-Metric Performance Row
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile('Attend', peer.attendanceRate),
                    ),
                    Expanded(
                      child: _buildMetricTile('P2P', '${peer.p2pCount}'),
                    ),
                    Expanded(
                      child:
                          _buildMetricTile('Refs', '${peer.referralsCount}'),
                    ),
                    Expanded(
                      child: _buildMetricTile('Deals', peer.dealsCount),
                    ),
                    Expanded(
                      child:
                          _buildMetricTile('Coins', '${peer.coinsCount}'),
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
