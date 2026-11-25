import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';

/// Restyled pending approvals banner preserved for component compatibility.
class DashboardPendingPeersCard extends StatelessWidget {
  final int count;
  final VoidCallback onReviewTap;

  const DashboardPendingPeersCard({
    super.key,
    required this.count,
    required this.onReviewTap,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenMargin,
        vertical: 6,
      ),
      child: EnterpriseSurfaceCard(
        padding: const EdgeInsets.all(14),
        borderColor: AppColor.pendingBorder,
        onTap: onReviewTap,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColor.pendingBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: AppColor.pendingBorder),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.fact_check_outlined,
                color: AppColor.pending,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$count pending ${count == 1 ? 'request' : 'requests'}',
                    style: AppTypography.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Awaiting executive review & approval',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColor.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            EnterpriseStatusBadge(
              label: 'Review',
              tone: EnterpriseStatusTone.pending,
              icon: Icons.arrow_forward_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
