import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../peers/model/peer_model.dart';
import '../../../peers/view/widgets/peer_card.dart';
import '../../../teams/model/teams_model.dart';

/// Circle Peers Preview Section matching Peers Global Unity's `CircleDetailPeersPreview`.
class CirclePeersPreviewSection extends StatelessWidget {
  final CircleTeamModel circle;
  final List<PeerModel> peers;
  final int totalPeersCount;
  final bool isLoading;

  const CirclePeersPreviewSection({
    super.key,
    required this.circle,
    required this.peers,
    required this.totalPeersCount,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final previewList = peers.take(4).toList();
    final count = peers.isNotEmpty ? totalPeersCount : circle.peersCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'Circle Peers',
                        style: AppTypography.titleSmall.copyWith(
                          fontSize: 13.5,
                          color: AppColor.lightTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.badgeBlueBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ThreeDNumberDisplay(
                        value: '$count',
                        digitHeight: 14,
                        spacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.circlePeers,
                    arguments: circle,
                  );
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'See more',
                        style: AppTypography.labelSmall.copyWith(
                          fontSize: 11.5,
                          color: AppColor.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: AppColor.primaryBlue,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (isLoading && previewList.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColor.primaryBlue,
                ),
              ),
            ),
          )
        else if (previewList.isNotEmpty)
          ...previewList.map(
            (peer) => PeerCard(
              peer: peer,
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.peerProfile,
                  arguments: peer,
                );
              },
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.lightBorder),
              ),
              child: Text(
                'No circle peers found yet.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColor.lightTextSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

