import 'package:flutter/material.dart';
import '../../../../core/widgets/widgets.dart';

/// Animated shimmer skeleton placeholder for Teams tab directory.
class TeamsListSkeleton extends StatelessWidget {
  const TeamsListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Skeleton
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerBox(width: 140, height: 14),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerBox(width: 80, height: 28, borderRadius: 8),
                      ShimmerBox(width: 80, height: 28, borderRadius: 8),
                      ShimmerBox(width: 80, height: 28, borderRadius: 8),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Chips row skeleton
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(
                  4,
                  (index) => const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: ShimmerBox(width: 100, height: 32, borderRadius: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Search Bar skeleton
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ShimmerBox(
                width: double.infinity,
                height: 42,
                borderRadius: 12,
              ),
            ),
            const SizedBox(height: 12),
            // Circle Cards List
            ...List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerBox(width: 160, height: 16),
                        ShimmerBox(width: 60, height: 20, borderRadius: 10),
                      ],
                    ),
                    SizedBox(height: 8),
                    ShimmerBox(width: 120, height: 12),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerBox(width: 70, height: 18, borderRadius: 6),
                        ShimmerBox(width: 70, height: 18, borderRadius: 6),
                        ShimmerBox(width: 70, height: 18, borderRadius: 6),
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
