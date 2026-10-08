import 'package:flutter/material.dart';
import '../../../../core/widgets/widgets.dart';

/// Animated shimmer skeleton placeholder for Profile screen.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            // Profile Hero Card Skeleton
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: const [
                  ShimmerBox(width: 80, height: 80, borderRadius: 40),
                  SizedBox(height: 14),
                  ShimmerBox(width: 150, height: 18),
                  SizedBox(height: 6),
                  ShimmerBox(width: 190, height: 12),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShimmerBox(width: 90, height: 24, borderRadius: 12),
                      SizedBox(width: 8),
                      ShimmerBox(width: 80, height: 24, borderRadius: 12),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Assigned circles card skeleton
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerBox(width: 130, height: 14),
                  SizedBox(height: 12),
                  ShimmerBox(
                    width: double.infinity,
                    height: 40,
                    borderRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Settings menu cards skeleton
            ...List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: const [
                    ShimmerBox(width: 24, height: 24, borderRadius: 6),
                    SizedBox(width: 14),
                    Expanded(child: ShimmerBox(width: 120, height: 14)),
                    ShimmerBox(width: 16, height: 16, borderRadius: 8),
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
