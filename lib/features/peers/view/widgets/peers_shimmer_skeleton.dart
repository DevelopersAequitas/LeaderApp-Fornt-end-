import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/widgets/widgets.dart';

/// Renders a list of animated shimmer skeleton cards while Peers data is loading.
class PeersListSkeleton extends StatelessWidget {
  final int itemCount;

  const PeersListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: itemCount,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) => const PeerCardSkeleton(),
      ),
    );
  }
}

/// Single skeleton card item mirroring the visual structure of PeerCard.
class PeerCardSkeleton extends StatelessWidget {
  const PeerCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Circle
              const ShimmerBox(width: 44, height: 44, borderRadius: 22),
              const SizedBox(width: 10),
              // Main Info Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        // Name line
                        ShimmerBox(width: 120, height: 14, borderRadius: 4),
                        // Status pill
                        ShimmerBox(width: 50, height: 16, borderRadius: 8),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Designation / Company line
                    const ShimmerBox(width: 160, height: 11, borderRadius: 4),
                    const SizedBox(height: 6),
                    // Location line
                    const ShimmerBox(width: 90, height: 10, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),
          // Footer Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              ShimmerBox(width: 80, height: 18, borderRadius: 6),
              ShimmerBox(width: 60, height: 18, borderRadius: 6),
              ShimmerBox(width: 75, height: 18, borderRadius: 6),
            ],
          ),
        ],
      ),
    );
  }
}
