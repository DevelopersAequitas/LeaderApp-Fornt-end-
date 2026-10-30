import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../teams/model/teams_model.dart';
import '../../model/circle_sub_industry_model.dart';
import 'circle_category_theme_config.dart';

/// Focus Areas & Industry Tags Card matching Peers Global Unity's `CircleDetailFocusAreas`.
class CircleFocusAreasCard extends StatelessWidget {
  final CircleTeamModel circle;
  final CircleSubIndustriesResponse? subIndustries;

  const CircleFocusAreasCard({
    super.key,
    required this.circle,
    this.subIndustries,
  });

  @override
  Widget build(BuildContext context) {
    final config = CircleCategoryThemeConfig.fromCircle(
      circle.category,
      circle.name,
    );

    final tagSet = <String>{};
    for (final t in circle.tags) {
      if (t.trim().isNotEmpty) tagSet.add(t.trim());
    }
    if (subIndustries != null) {
      for (final active in subIndustries!.activeSubIndustries.take(6)) {
        if (active.name.trim().isNotEmpty) tagSet.add(active.name.trim());
      }
    }
    if (tagSet.isEmpty && circle.category.trim().isNotEmpty) {
      tagSet.add(circle.category.trim());
    }
    final tags = tagSet.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: config.tintColor.withValues(alpha: 0.18),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SquareRoundedGradientIcon(
                  icon: Icons.hub_outlined,
                  boxSize: 28,
                  iconSize: 15,
                  borderRadius: 8,
                ),
                const SizedBox(width: 8),
                Text(
                  'Focus Areas & Industry Tags',
                  style: AppTypography.titleSmall.copyWith(
                    fontSize: 14.5,
                    color: AppColor.lightTextPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        config.bgTint,
                        AppColor.badgeBlueBg,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: config.tintColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 11,
                      color: config.tintColor,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

