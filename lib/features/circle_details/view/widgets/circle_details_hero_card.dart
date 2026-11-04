import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../teams/model/teams_model.dart';
import 'circle_category_theme_config.dart';

/// Renders the Circle Detail Header matching Peers Global Unity's `CircleDetailHeader`.
class CircleDetailsHeroCard extends StatelessWidget {
  final CircleTeamModel circle;
  final int? totalPeersCount;

  const CircleDetailsHeroCard({
    super.key,
    required this.circle,
    this.totalPeersCount,
  });

  @override
  Widget build(BuildContext context) {
    final config = CircleCategoryThemeConfig.fromCircle(
      circle.category,
      circle.name,
    );
    final coverUrl = circle.effectiveCoverUrl;
    final hasCustomCover = coverUrl != null && coverUrl.isNotEmpty;
    final logoUrl = circle.effectiveLogoUrl;
    final effectivePeersCount = totalPeersCount != null && totalPeersCount! > 0
        ? totalPeersCount!
        : circle.peersCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      config.tintColor.withValues(alpha: 0.85),
                      config.tintColor.withValues(alpha: 0.6),
                      config.bgTint,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: hasCustomCover
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              coverUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _buildFallbackBanner(),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColor.black.withValues(alpha: 0.4),
                                    AppColor.transparent,
                                    AppColor.black.withValues(alpha: 0.2),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ],
                        )
                      : _buildFallbackBanner(),
                ),
              ),
            ),
            Positioned(
              left: 28,
              bottom: -24,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColor.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Container(
                    color: config.bgTint,
                    child: (logoUrl != null && logoUrl.isNotEmpty)
                        ? Image.network(
                            logoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Center(
                              child: Icon(
                                config.icon,
                                size: 28,
                                color: config.tintColor,
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              config.icon,
                              size: 28,
                              color: config.tintColor,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      circle.name,
                      style: AppTypography.titleLarge.copyWith(
                        fontSize: 18,
                        color: AppColor.lightTextPrimary,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(circle.status),
                ],
              ),
              if (circle.category.trim().isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  circle.category,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColor.lightTextSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              _buildMetaRow(effectivePeersCount),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Together for\na Better Tomorrow',
            style: AppTypography.labelMedium.copyWith(
              color: AppColor.white,
              fontSize: 13,
              height: 1.2,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 4),
          Text(
            'Connect • Collaborate • Create Impact',
            style: AppTypography.bodySmall.copyWith(
              color: AppColor.white.withValues(alpha: 0.85),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isPending = status.toLowerCase().contains('pending');
    final bg = isPending ? AppColor.warningBg : AppColor.successBg;
    final text = isPending ? AppColor.warningDark : AppColor.successDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.isNotEmpty ? status : 'Active',
        style: AppTypography.labelSmall.copyWith(
          fontSize: 10.5,
          color: text,
        ),
      ),
    );
  }

  Widget _buildMetaRow(int effectivePeersCount) {
    final location = circle.location.trim();
    final stage = (circle.stage != null && circle.stage!.trim().isNotEmpty)
        ? circle.stage!.trim()
        : 'Active Circle';

    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        if (location.isNotEmpty)
          _buildMetaItem(
            icon: Icons.location_on_outlined,
            iconColor: AppColor.lightTextSecondary,
            label: location,
          ),
        _buildMetaItem(
          icon: Icons.stars_rounded,
          iconColor: AppColor.primaryBlue,
          label: stage,
        ),
        _buildMetaItem(
          icon: Icons.people_outline_rounded,
          iconColor: AppColor.primaryBlue,
          label: '$effectivePeersCount Peers',
        ),
        if (circle.revenue.trim().isNotEmpty && circle.revenue != '₹0.0')
          _buildMetaItem(
            icon: Icons.military_tech_outlined,
            iconColor: AppColor.warning,
            label: circle.revenue,
          ),
      ],
    );
  }

  Widget _buildMetaItem({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: iconColor),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            fontSize: 11,
            color: AppColor.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}
