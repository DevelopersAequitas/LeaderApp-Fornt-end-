import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../teams/model/teams_model.dart';
import 'circle_category_theme_config.dart';

/// About Circle Card matching Peers Global Unity's `CircleDetailAbout`.
/// 100% Pure StatelessWidget utilizing [ExpandableText].
class CircleAboutCard extends StatelessWidget {
  final CircleTeamModel circle;

  const CircleAboutCard({super.key, required this.circle});

  @override
  Widget build(BuildContext context) {
    final config = CircleCategoryThemeConfig.fromCircle(
      circle.category,
      circle.name,
    );
    final defaultAbout =
        'The ${circle.name} brings together professionals, leaders, and service providers on one platform. It creates opportunities to build trusted connections, exchange knowledge, generate referrals, and explore business collaborations.';
    final text = (circle.description != null &&
            circle.description!.trim().isNotEmpty)
        ? circle.description!.trim()
        : defaultAbout;

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
                  icon: Icons.info_outline_rounded,
                  boxSize: 28,
                  iconSize: 15,
                  borderRadius: 8,
                ),
                const SizedBox(width: 8),
                Text(
                  'About Circle',
                  style: AppTypography.titleSmall.copyWith(
                    fontSize: 14.5,
                    color: AppColor.lightTextPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ExpandableText(
              text: text,
              maxLines: 4,
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 12.5,
                color: AppColor.lightTextMuted,
                height: 1.5,
              ),
              toggleStyle: AppTypography.labelSmall.copyWith(
                fontSize: 11.5,
                color: AppColor.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

