import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';

/// Shimmer skeleton mirroring the redesigned Executive Command Center layout:
/// Identity Header -> Action Required -> 2x3 KPI Overview -> Performance Card.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColor.darkSurface : AppColor.lightSurface;
    final borderColor = isDark ? AppColor.darkBorder : AppColor.outline;

    return AppShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Identity & Scope Header Skeleton
            Container(
              padding: const EdgeInsets.all(AppSpacing.screenMargin),
              decoration: BoxDecoration(
                color: cardColor,
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerBox(width: 90, height: 12, borderRadius: 4),
                      ShimmerBox(width: 84, height: 12, borderRadius: 4),
                    ],
                  ),
                  SizedBox(height: 6),
                  ShimmerBox(width: 170, height: 22, borderRadius: 6),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      ShimmerBox(width: 96, height: 22, borderRadius: 6),
                      SizedBox(width: 8),
                      ShimmerBox(width: 160, height: 16, borderRadius: 4),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),

            // 2. Action Required Skeleton
            Padding(
              padding: AppSpacing.pageHorizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: 130, height: 16, borderRadius: 4),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: borderColor),
                    ),
                    child: const Row(
                      children: [
                        ShimmerBox(width: 34, height: 34, borderRadius: 8),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerBox(width: 150, height: 14, borderRadius: 4),
                              SizedBox(height: 6),
                              ShimmerBox(
                                width: double.infinity,
                                height: 12,
                                borderRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        ShimmerBox(width: 68, height: 28, borderRadius: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),

            // 3. 2x3 KPI Overview Grid Skeleton
            Padding(
              padding: AppSpacing.pageHorizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: 165, height: 16, borderRadius: 4),
                  const SizedBox(height: 10),
                  for (int r = 0; r < 3; r++) ...[
                    if (r > 0) const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildKpiSkeletonTile(cardColor, borderColor),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildKpiSkeletonTile(cardColor, borderColor),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),

            // 4. Organizational Performance Skeleton
            Padding(
              padding: AppSpacing.pageHorizontal,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        ShimmerBox(width: 72, height: 26, borderRadius: 8),
                        SizedBox(width: 6),
                        ShimmerBox(width: 78, height: 26, borderRadius: 8),
                        SizedBox(width: 6),
                        ShimmerBox(width: 72, height: 26, borderRadius: 8),
                      ],
                    ),
                    const SizedBox(height: 14),
                    for (int i = 0; i < 4; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ShimmerBox(width: 120, height: 13, borderRadius: 4),
                          ShimmerBox(width: 54, height: 13, borderRadius: 4),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const ShimmerBox(
                        width: double.infinity,
                        height: 6,
                        borderRadius: 4,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiSkeletonTile(Color cardColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: borderColor),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 30, height: 30, borderRadius: 8),
              ShimmerBox(width: 14, height: 14, borderRadius: 4),
            ],
          ),
          SizedBox(height: 12),
          ShimmerBox(width: 84, height: 20, borderRadius: 4),
          SizedBox(height: 6),
          ShimmerBox(width: 96, height: 12, borderRadius: 4),
        ],
      ),
    );
  }
}
