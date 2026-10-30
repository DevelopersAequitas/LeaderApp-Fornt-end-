import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../peers/view/widgets/peer_card.dart';
import '../../../teams/model/teams_model.dart';
import '../../model/circle_sub_industry_model.dart';
import 'refer_category_bottom_sheet.dart';

/// Card for an Open Category in a circle with a 'Refer ->' button
/// matching Peers Global Unity's `CircleCategoriesScreen`.
class CircleOpenCategoryCard extends StatelessWidget {
  final SubIndustryItemModel item;
  final CircleTeamModel circle;

  const CircleOpenCategoryCard({
    super.key,
    required this.item,
    required this.circle,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle =
        item.breadcrumb.isNotEmpty ? item.breadcrumb : circle.category;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColor.lightBorder, width: 0.9),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SquareRoundedGradientIcon(
            icon: Icons.work_outline_rounded,
            boxSize: 34,
            iconSize: 16,
            borderRadius: 9,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.name,
                  style: AppTypography.titleSmall.copyWith(
                    fontSize: 12.5,
                    color: AppColor.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.folder_open_rounded,
                        size: 11,
                        color: AppColor.lightTextSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          subtitle,
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 10.5,
                            color: AppColor.lightTextSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              ReferCategoryBottomSheet.show(
                context,
                circle: circle,
                category: item,
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColor.brandGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Refer',
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 10.5,
                      color: AppColor.white,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 11,
                    color: AppColor.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card for a Closed (Occupied) Category in a circle showing the category badge
/// and the occupying peer (`PeerCard`) matching Peers Global Unity.
class CircleClosedCategoryCard extends StatelessWidget {
  final SubIndustryItemModel item;
  final CircleTeamModel circle;

  const CircleClosedCategoryCard({
    super.key,
    required this.item,
    required this.circle,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = item.breadcrumb;
    final occupant = item.occupant;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColor.lightBorder, width: 0.9),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 7),
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.badgeBlueBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 11,
                          color: AppColor.primaryBlue,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            item.name,
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 10.5,
                              color: AppColor.primaryBlue,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 10,
                        color: AppColor.lightTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else
                  const Spacer(),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.warningBg,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: AppColor.warningBorder,
                      width: 0.7,
                    ),
                  ),
                  child: Text(
                    'OCCUPIED',
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 8.5,
                      color: AppColor.warningDark,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.6, color: AppColor.lightBorder),
          if (occupant != null)
            PeerCard(
              peer: occupant,
              margin: EdgeInsets.zero,
              showBorder: false,
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.people_outline_rounded,
                    size: 15,
                    color: AppColor.lightTextSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Occupied by ${item.peerCount} ${item.peerCount == 1 ? "peer" : "peers"} in ${circle.name}',
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 11.5,
                      color: AppColor.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
