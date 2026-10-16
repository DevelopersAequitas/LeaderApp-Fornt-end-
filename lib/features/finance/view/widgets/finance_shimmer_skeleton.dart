// ==============================================================================
// File: lib/features/finance/view/widgets/finance_shimmer_skeleton.dart
// Description: Animated shimmer skeleton placeholder for the Finance screen
// Framework: Flutter | Architecture: MVP View Component
// ==============================================================================

import 'package:flutter/material.dart';
import '../../../../core/widgets/widgets.dart';

/// Animated shimmer skeleton placeholder matching the Finance portal screen layout.
class FinanceSkeleton extends StatelessWidget {
  const FinanceSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 48),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Metrics Grid (4 cards in 2x2 grid)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.45,
                children: List.generate(
                  4,
                  (index) => Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ShimmerBox(width: 32, height: 32, borderRadius: 10),
                            ShimmerBox(width: 44, height: 16, borderRadius: 8),
                          ],
                        ),
                        ShimmerBox(width: 80, height: 18, borderRadius: 4),
                        ShimmerBox(width: 65, height: 11, borderRadius: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 2. Finance Chart Card Skeleton
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerBox(width: 130, height: 16, borderRadius: 4),
                      ShimmerBox(width: 70, height: 22, borderRadius: 12),
                    ],
                  ),
                  SizedBox(height: 16),
                  ShimmerBox(
                    width: double.infinity,
                    height: 180,
                    borderRadius: 12,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 3. Commission Structure Card Skeleton
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: 150, height: 16, borderRadius: 4),
                  const SizedBox(height: 14),
                  ...List.generate(
                    3,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          ShimmerBox(width: 110, height: 14, borderRadius: 4),
                          ShimmerBox(width: 60, height: 14, borderRadius: 4),
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
