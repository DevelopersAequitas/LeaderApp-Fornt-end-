import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../teams/model/teams_model.dart';
import '../../model/circle_sub_industry_model.dart';

/// Category Availability Card matching Peers Global Unity's `CircleDetailCategoryStatus`.
class CircleCategoryStatusCard extends StatelessWidget {
  final CircleTeamModel circle;
  final CircleSubIndustriesResponse? subIndustries;
  final bool isLoading;

  const CircleCategoryStatusCard({
    super.key,
    required this.circle,
    required this.subIndustries,
    required this.isLoading,
  });

  void _openSubIndustries(BuildContext context, {int initialTabIndex = 0}) {
    Navigator.of(context).pushNamed(
      AppRoutes.circleSubIndustries,
      arguments: {
        'circle': circle,
        'initialTabIndex': initialTabIndex,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final openCount = subIndustries?.openSubIndustries.length ?? 0;
    final closedCount = subIndustries?.activeSubIndustries.length ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SquareRoundedGradientIcon(
                        icon: Icons.category_outlined,
                        boxSize: 28,
                        iconSize: 15,
                        borderRadius: 8,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Category Availability',
                          style: AppTypography.titleSmall.copyWith(
                            fontSize: 14,
                            color: AppColor.lightTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _openSubIndustries(context, initialTabIndex: 0),
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
                          'View all',
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 11,
                            color: AppColor.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: AppColor.primaryBlue,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLoading && subIndustries == null)
              SizedBox(
                height: 58,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: AppColor.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Checking categories...',
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColor.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _buildCategoryCard(
                      title: 'Open Categories',
                      count: openCount,
                      subtitle: 'Available to join',
                      icon: Icons.lock_open_rounded,
                      accentColor: AppColor.primaryBlue,
                      bgColor: AppColor.badgeBlueBg,
                      borderColor: AppColor.infoBorder,
                      onTap: () =>
                          _openSubIndustries(context, initialTabIndex: 0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCategoryCard(
                      title: 'Closed Categories',
                      count: closedCount,
                      subtitle: 'Occupied by peers',
                      icon: Icons.lock_outline_rounded,
                      accentColor: AppColor.warningDark,
                      bgColor: AppColor.warningBg,
                      borderColor: AppColor.warningBorder,
                      onTap: () =>
                          _openSubIndustries(context, initialTabIndex: 1),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required int count,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColor.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 13, color: accentColor),
                      const SizedBox(width: 5),
                      ThreeDNumberDisplay(
                        value: '$count',
                        digitHeight: 17,
                        spacing: -1,
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: AppColor.lightTextDisabled,
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 11,
                  color: AppColor.lightTextPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 9.5,
                  color: AppColor.lightTextSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
