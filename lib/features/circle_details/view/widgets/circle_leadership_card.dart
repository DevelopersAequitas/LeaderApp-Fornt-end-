import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../peers/model/peer_model.dart';
import '../../../peers/view/widgets/peer_card.dart';
import '../../../teams/model/teams_model.dart';

/// Renders the Circle Leadership sections (`Circle Leaders` & `Regional Leaders`)
/// with outside section titles (matching `Circle Peers` & `Meetings & Events`)
/// and each leader rendered in a [PeerCard] with a role badge pill above it.
class CircleLeadershipCard extends StatelessWidget {
  final CircleTeamModel circle;
  final List<PeerModel> circlePeers;

  const CircleLeadershipCard({
    super.key,
    required this.circle,
    this.circlePeers = const [],
  });

  @override
  Widget build(BuildContext context) {
    final peerById = <String, PeerModel>{};
    final peerByName = <String, PeerModel>{};
    for (final p in circlePeers) {
      if (p.id.trim().isNotEmpty) peerById[p.id.trim()] = p;
      if (p.name.trim().isNotEmpty) {
        peerByName[p.name.trim().toLowerCase()] = p;
      }
    }

    final circleLeaders = <CircleLeaderModel>[
      if (circle.chairs.isNotEmpty)
        ...circle.chairs
      else if (circle.chairName.trim().isNotEmpty &&
          circle.chairName != 'Unassigned')
        CircleLeaderModel(
          name: circle.chairName.trim(),
          role: 'Circle Chair',
          designation: 'Chairperson',
        ),
    ];

    final regionalLeaders = <CircleLeaderModel>[
      if (circle.founders.isNotEmpty)
        ...circle.founders
      else if (circle.founderName.trim().isNotEmpty &&
          circle.founderName != 'Unassigned')
        CircleLeaderModel(
          name: circle.founderName.trim(),
          role: 'Circle Founder',
          designation: 'Founder & CEO',
        ),
      if (circle.directors.isNotEmpty)
        ...circle.directors
      else if (circle.directorName.trim().isNotEmpty &&
          circle.directorName != 'Unassigned')
        CircleLeaderModel(
          name: circle.directorName.trim(),
          role: 'Circle Director',
          designation: 'Managing Director',
        ),
    ];

    if (circleLeaders.isEmpty && regionalLeaders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (circleLeaders.isNotEmpty) ...[
          _buildLeadershipSection(
            context: context,
            title: 'Circle Leaders',
            leaders: circleLeaders,
            isRegional: false,
            peerById: peerById,
            peerByName: peerByName,
          ),
          if (regionalLeaders.isNotEmpty) const SizedBox(height: 14),
        ],
        if (regionalLeaders.isNotEmpty)
          _buildLeadershipSection(
            context: context,
            title: 'Regional Leaders',
            leaders: regionalLeaders,
            isRegional: true,
            peerById: peerById,
            peerByName: peerByName,
          ),
      ],
    );
  }

  Widget _buildLeadershipSection({
    required BuildContext context,
    required String title,
    required List<CircleLeaderModel> leaders,
    required bool isRegional,
    required Map<String, PeerModel> peerById,
    required Map<String, PeerModel> peerByName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Outside Section Header (matching Circle Peers & Meetings & Events)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  title,
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
                  value: '${leaders.length}',
                  digitHeight: 14,
                  spacing: -1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Leader PeerCards below the outside header
        ...leaders.map(
          (leader) => _buildLeaderPeerCard(
            context: context,
            leader: leader,
            isRegional: isRegional,
            peerById: peerById,
            peerByName: peerByName,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderPeerCard({
    required BuildContext context,
    required CircleLeaderModel leader,
    required bool isRegional,
    required Map<String, PeerModel> peerById,
    required Map<String, PeerModel> peerByName,
  }) {
    final matched = (leader.id.trim().isNotEmpty
            ? peerById[leader.id.trim()]
            : null) ??
        peerByName[leader.name.trim().toLowerCase()];

    final initials = leader.name.trim().isNotEmpty
        ? leader.name
            .trim()
            .split(RegExp(r'\s+'))
            .where((n) => n.isNotEmpty)
            .map((n) => n[0])
            .take(2)
            .join()
            .toUpperCase()
        : 'PR';

    final peer = PeerModel(
      id: leader.id.trim().isNotEmpty ? leader.id.trim() : (matched?.id ?? ''),
      initials: initials,
      name: leader.name,
      avatarUrl: leader.avatarUrl ?? matched?.avatarUrl,
      company: (leader.company != null && leader.company!.trim().isNotEmpty)
          ? leader.company!.trim()
          : (matched != null && matched.company.trim().isNotEmpty
              ? matched.company.trim()
              : circle.name),
      circle: circle.name,
      circleId: circle.id,
      location: (leader.city != null && leader.city!.trim().isNotEmpty)
          ? leader.city!.trim()
          : (matched != null && matched.location.trim().isNotEmpty
              ? matched.location.trim()
              : (circle.location.isNotEmpty ? circle.location : 'Ahmedabad')),
      tags: (leader.category != null && leader.category!.trim().isNotEmpty)
          ? leader.category!.trim()
          : (matched?.level4Category ??
              (matched != null && matched.tags.isNotEmpty
                  ? matched.tags
                  : circle.category)),
      level4Category:
          (leader.category != null && leader.category!.trim().isNotEmpty)
              ? leader.category!.trim()
              : (matched?.level4Category ?? circle.category),
      impactCount: leader.impactCount > 0
          ? leader.impactCount
          : (matched?.impactCount ?? 0),
      dealsFormatted: matched?.dealsFormatted ?? '₹0',
      coins: matched?.coins ?? 0,
      attendance: matched?.attendance ?? '90%',
      status: 'Active',
      isVerified: leader.isVerified || (matched?.isVerified ?? false),
      phone: leader.phone ?? matched?.phone,
      email: leader.email ?? matched?.email,
      designation:
          (leader.designation != null && leader.designation!.trim().isNotEmpty)
              ? leader.designation!.trim()
              : (matched?.designation ?? leader.role),
    );

    final roleColor = isRegional ? AppColor.warningDark : AppColor.primaryBlue;
    final roleBg = isRegional ? AppColor.warningBg : AppColor.badgeBlueBg;
    final roleBorder =
        isRegional ? AppColor.warningBorder : AppColor.infoBorder;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.lightBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              top: 8,
              right: 12,
              bottom: 2,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
              decoration: BoxDecoration(
                color: roleBg,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: roleBorder, width: 0.6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isRegional ? Icons.public_rounded : Icons.stars_rounded,
                    size: 11,
                    color: roleColor,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      leader.role.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 10,
                        color: roleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          PeerCard(
            peer: peer,
            showBorder: false,
            margin: EdgeInsets.zero,
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRoutes.peerProfile,
                arguments: peer,
              );
            },
          ),
        ],
      ),
    );
  }
}
