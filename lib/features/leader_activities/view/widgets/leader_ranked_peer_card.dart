import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/leader_activity_item_model.dart';

/// Renders a single peer row in the top-to-bottom ranked peers list for any
/// activity section, matching the Peers Global Unity `PeerCard` layout and theme.
class LeaderRankedPeerCard extends StatelessWidget {
  final LeaderRankedPeerModel item;
  final IconData metricIcon;

  const LeaderRankedPeerCard({
    super.key,
    required this.item,
    this.metricIcon = Icons.person_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final peer = item.peer;
    final displayDesignation = peer.designation != null &&
            peer.designation!.trim().isNotEmpty
        ? peer.designation!.trim()
        : '';
    final displayCompany = peer.company.trim();

    String designationAndCompany = '';
    if (displayDesignation.isNotEmpty && displayCompany.isNotEmpty) {
      designationAndCompany = '$displayDesignation · $displayCompany';
    } else if (displayDesignation.isNotEmpty) {
      designationAndCompany = displayDesignation;
    } else {
      designationAndCompany = displayCompany;
    }

    final displayCategory = peer.level4Category != null &&
            peer.level4Category!.trim().isNotEmpty
        ? peer.level4Category!.trim()
        : (peer.tags.isNotEmpty ? peer.tags : (peer.industry ?? ''));

    final isTopRank = item.rank <= 3;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4.5),
      decoration: BoxDecoration(
        color: AppColor.lightSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.lightBorder),
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
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Navigator.of(context).pushNamed(
              AppRoutes.peerProfile,
              arguments: peer,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Avatar (38px matching Peers Global Unity)
                InitialsAvatar(
                  name: peer.name.toUpperCase(),
                  imageUrl: peer.avatarUrl,
                  radius: 19,
                  backgroundColor: AppColor.primaryBlue,
                  fontSize: 12,
                ),
                const SizedBox(width: 9),
                // 2. Center 4-Row Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Uppercase Name + Verified + Rank Pill
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              peer.name.toUpperCase(),
                              style: const TextStyle(
                                color: AppColor.lightTextPrimary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (peer.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              color: AppColor.primaryBlue,
                              size: 13,
                            ),
                          ],
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              gradient:
                                  isTopRank ? AppColor.brandGradient : null,
                              color:
                                  isTopRank ? null : AppColor.lightSurfaceMuted,
                              borderRadius: BorderRadius.circular(5),
                              border: isTopRank
                                  ? null
                                  : Border.all(color: AppColor.lightBorder),
                            ),
                            child: Text(
                              '#${item.rank}',
                              style: TextStyle(
                                color: isTopRank
                                    ? Colors.white
                                    : AppColor.lightTextSecondary,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Row 2: City / Location
                      if (peer.location.trim().isNotEmpty) ...[
                        const SizedBox(height: 1.5),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 10,
                              color: AppColor.lightTextSecondary,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                peer.location.trim(),
                                style: const TextStyle(
                                  color: AppColor.lightTextSecondary,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      // Row 3: Designation · Company
                      if (designationAndCompany.isNotEmpty) ...[
                        const SizedBox(height: 1.5),
                        Row(
                          children: [
                            const Icon(
                              Icons.business_center_rounded,
                              size: 10,
                              color: AppColor.lightTextSecondary,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                designationAndCompany,
                                style: const TextStyle(
                                  color: AppColor.lightTextSecondary,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      // Row 4: Brand Gradient Category Text
                      if (displayCategory.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColor.brandGradient.createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                          blendMode: BlendMode.srcIn,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.sell_outlined,
                                size: 9.0,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  displayCategory,
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 3. Right Column: Main Section Metric Count Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.lightSurfaceMuted,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColor.lightBorder.withValues(alpha: 0.8),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            metricIcon,
                            size: 13,
                            color: AppColor.primaryBlue,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            item.metricDisplay,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: AppColor.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.metricLabel,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        color: AppColor.lightTextSecondary,
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

