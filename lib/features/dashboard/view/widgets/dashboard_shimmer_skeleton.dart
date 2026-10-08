import 'package:flutter/material.dart';
import '../../../../core/widgets/widgets.dart';

/// Animated shimmer skeleton placeholder matching Dashboard screen layout.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Dashboard Hero Banner Skeleton
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      ShimmerBox(width: 120, height: 14),
                      ShimmerBox(width: 80, height: 24, borderRadius: 12),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const ShimmerBox(width: 180, height: 26, borderRadius: 6),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Expanded(
                        child: ShimmerBox(
                          width: double.infinity,
                          height: 60,
                          borderRadius: 12,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ShimmerBox(
                          width: double.infinity,
                          height: 60,
                          borderRadius: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 2. Metrics Grid 4-Card Skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.45,
                children: List.generate(
                  4,
                  (index) => Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ShimmerBox(width: 32, height: 32, borderRadius: 16),
                            ShimmerBox(width: 45, height: 16, borderRadius: 8),
                          ],
                        ),
                        ShimmerBox(width: 90, height: 18),
                        ShimmerBox(width: 70, height: 11),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Top Impacters / Pending approvals skeleton card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: 150, height: 16),
                  const SizedBox(height: 14),
                  ...List.generate(
                    3,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: const [
                          ShimmerBox(width: 40, height: 40, borderRadius: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShimmerBox(width: 130, height: 14),
                                SizedBox(height: 4),
                                ShimmerBox(width: 90, height: 11),
                              ],
                            ),
                          ),
                          ShimmerBox(width: 60, height: 24, borderRadius: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
