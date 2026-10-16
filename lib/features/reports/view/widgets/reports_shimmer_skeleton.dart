// ==============================================================================
// File: lib/features/reports/view/widgets/reports_shimmer_skeleton.dart
// Description: Animated shimmer skeleton placeholder for the Reports screen
// Framework: Flutter | Architecture: MVP View Component
// ==============================================================================

import 'package:flutter/material.dart';
import '../../../../core/widgets/widgets.dart';

/// Animated shimmer skeleton placeholder matching the Reports screen layout.
class ReportsSkeleton extends StatelessWidget {
  const ReportsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Tab Selector Skeleton
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Expanded(
                    child: ShimmerBox(
                      width: double.infinity,
                      height: 38,
                      borderRadius: 10,
                    ),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: ShimmerBox(
                      width: double.infinity,
                      height: 38,
                      borderRadius: 10,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Trend Chart Card Skeleton
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                      ShimmerBox(width: 80, height: 22, borderRadius: 10),
                    ],
                  ),
                  SizedBox(height: 14),
                  ShimmerBox(
                    width: double.infinity,
                    height: 140,
                    borderRadius: 10,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 3. Report History Cards
            ...List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        ShimmerBox(width: 140, height: 16, borderRadius: 4),
                        ShimmerBox(width: 65, height: 20, borderRadius: 8),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const ShimmerBox(
                      width: double.infinity,
                      height: 12,
                      borderRadius: 4,
                    ),
                    const SizedBox(height: 6),
                    const ShimmerBox(width: 180, height: 12, borderRadius: 4),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        ShimmerBox(width: 90, height: 11, borderRadius: 4),
                        ShimmerBox(width: 70, height: 24, borderRadius: 6),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
