import 'package:flutter/material.dart';
import '../../../../core/widgets/widgets.dart';

/// Animated shimmer skeleton placeholder for Peer Profile screen.
class PeerProfileSkeleton extends StatelessWidget {
  const PeerProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            // Peer Hero Card Skeleton
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: const [
                  ShimmerBox(width: 76, height: 76, borderRadius: 38),
                  SizedBox(height: 12),
                  ShimmerBox(width: 140, height: 18),
                  SizedBox(height: 6),
                  ShimmerBox(width: 170, height: 12),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShimmerBox(width: 80, height: 24, borderRadius: 12),
                      SizedBox(width: 8),
                      ShimmerBox(width: 90, height: 24, borderRadius: 12),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Tab selector skeleton
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ShimmerBox(
                width: double.infinity,
                height: 42,
                borderRadius: 12,
              ),
            ),
            const SizedBox(height: 12),
            // 8 Metric Grid Skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.6,
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
                        ShimmerBox(width: 80, height: 12),
                        ShimmerBox(width: 100, height: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
