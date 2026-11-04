import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/leader_activity_item_model.dart';

/// Renders a single user-input activity card with a Peers Global Unity-aligned
/// peer header and structured activity content.
class LeaderActivityItemCard extends StatelessWidget {
  final LeaderActivityItemModel item;
  final bool isProcessing;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const LeaderActivityItemCard({
    super.key,
    required this.item,
    this.isProcessing = false,
    this.onApprove,
    this.onReject,
  });

  String _formatStatusText(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'Active';
    return trimmed
        .split(RegExp(r'[_-]+'))
        .where((w) => w.isNotEmpty)
        .map((w) {
          final lower = w.toLowerCase();
          if (lower == 'cd' || lower == 'ded') return lower.toUpperCase();
          return '${w[0].toUpperCase()}${w.substring(1)}';
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final hasPeerProfile =
        item.peerId.trim().isNotEmpty || item.peerName.trim().isNotEmpty;
    final designationAndCompany = [
      if (item.designation.trim().isNotEmpty) item.designation.trim(),
      if (item.company.trim().isNotEmpty) item.company.trim(),
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: AppColor.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: hasPeerProfile
              ? () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.peerProfile,
                    arguments: item.toPeerModel(),
                  );
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Peer Header (Matching Peers Global Unity PeerCard style)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InitialsAvatar(
                      name: item.peerName.toUpperCase(),
                      imageUrl: item.avatarUrl,
                      radius: 19,
                      backgroundColor: AppColor.primaryBlue,
                      fontSize: 12,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.peerName.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColor.lightTextPrimary,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (item.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: AppColor.primaryBlue,
                                  size: 13,
                                ),
                              ],
                            ],
                          ),
                          if (item.city.trim().isNotEmpty) ...[
                            const SizedBox(height: 1.5),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 10,
                                  color: AppColor.lightTextSecondary,
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    item.city,
                                    style: const TextStyle(
                                      color: AppColor.lightTextSecondary,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (designationAndCompany.isNotEmpty) ...[
                            const SizedBox(height: 1.5),
                            Row(
                              children: [
                                const Icon(
                                  Icons.business_center_rounded,
                                  size: 10,
                                  color: AppColor.lightTextSecondary,
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    designationAndCompany,
                                    style: const TextStyle(
                                      color: AppColor.lightTextSecondary,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (item.category.trim().isNotEmpty) ...[
                            const SizedBox(height: 2),
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppColor.brandGradient.createShader(
                                Rect.fromLTWH(
                                  0,
                                  0,
                                  bounds.width,
                                  bounds.height,
                                ),
                              ),
                              blendMode: BlendMode.srcIn,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.sell_outlined,
                                    size: 9.5,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      item.category,
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Right Status / Date Column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.badgeBlueBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColor.primaryBlue.withValues(alpha: 0.18),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            item.amount != null && item.amount!.isNotEmpty
                                ? item.amount!
                                : _formatStatusText(item.status),
                            style: const TextStyle(
                              color: AppColor.primaryBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (item.date.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.formattedDate.isNotEmpty ? item.formattedDate : item.date,
                            style: const TextStyle(
                              color: AppColor.lightTextSecondary,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: AppColor.lightBorder),
                const SizedBox(height: 8),
                // 2. Activity Details Box
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.lightSurfaceSubtle,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColor.lightBorder.withValues(alpha: 0.8),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                color: AppColor.lightTextPrimary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.badgeLabel != null &&
                              item.badgeLabel!.trim().isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.lightSurfaceMuted,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: AppColor.lightBorder),
                              ),
                              child: Text(
                                item.badgeLabel!,
                                style: const TextStyle(
                                  color: AppColor.lightTextSecondary,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (item.subtitle.trim().isNotEmpty &&
                          item.subtitle.trim() != item.title.trim()) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          style: const TextStyle(
                            color: AppColor.primaryBlue,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (item.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: const TextStyle(
                            color: AppColor.lightTextSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (item.targetPeerName != null &&
                          item.targetPeerName!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 12,
                              color: AppColor.primaryBlue,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                item.targetPeerCompany != null &&
                                        item.targetPeerCompany!.isNotEmpty
                                    ? '${item.targetPeerName} (${item.targetPeerCompany})'
                                    : item.targetPeerName!,
                                style: const TextStyle(
                                  color: AppColor.lightTextPrimary,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (item.isActionablePending &&
                    (onApprove != null || onReject != null)) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (onReject != null)
                        Expanded(
                          child: SizedBox(
                            height: 36,
                            child: OutlinedButton.icon(
                              onPressed: isProcessing ? null : onReject,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.danger,
                                side: BorderSide(
                                  color: AppColors.danger
                                      .withValues(alpha: 0.35),
                                ),
                                backgroundColor:
                                    AppColors.danger.withValues(alpha: 0.04),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 15,
                                color: AppColors.danger,
                              ),
                              label: const Text(
                                'Reject',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.danger,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (onReject != null && onApprove != null)
                        const SizedBox(width: 10),
                      if (onApprove != null)
                        Expanded(
                          child: SizedBox(
                            height: 36,
                            child: ElevatedButton.icon(
                              onPressed: isProcessing ? null : onApprove,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: isProcessing
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.check_rounded,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                              label: Text(
                                isProcessing ? 'Processing...' : 'Accept',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

