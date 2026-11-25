import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/leader_activity_item_model.dart';

/// Enterprise card for actionable moderation requests (`pending-requests`) and
/// official bulletins (`circulars`), paired with direct navigation to the Peer
/// profile.
class LeaderActivityItemCard extends StatelessWidget {
  final LeaderActivityItemModel item;
  final bool isProcessing;
  final VoidCallback? onTapCard;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const LeaderActivityItemCard({
    super.key,
    required this.item,
    this.isProcessing = false,
    this.onTapCard,
    this.onApprove,
    this.onReject,
  });

  static String _formatDisplayName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'Peer';
    if (trimmed == trimmed.toUpperCase() && trimmed.length > 2) {
      return trimmed
          .split(RegExp(r'\s+'))
          .map((w) {
            if (w.isEmpty) return '';
            if (w.length == 1) return w.toUpperCase();
            return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
          })
          .join(' ');
    }
    return trimmed;
  }

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

  EnterpriseStatusTone _toneForStatus(String raw) {
    final s = raw.trim().toLowerCase();
    if (s.contains('reject') || s.contains('declin')) {
      return EnterpriseStatusTone.rejected;
    }
    if (s.contains('approv') ||
        s.contains('complet') ||
        s.contains('publish') ||
        s.contains('active')) {
      return EnterpriseStatusTone.active;
    }
    if (s.contains('pending') ||
        s.contains('await') ||
        s.contains('submit') ||
        s.contains('review')) {
      return EnterpriseStatusTone.pending;
    }
    return EnterpriseStatusTone.info;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final textSecondary =
        isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;
    final textMuted =
        isDark ? AppColor.darkTextTertiary : AppColor.lightTextMuted;
    final dividerColor = isDark ? AppColor.darkDivider : AppColor.divider;
    final detailBg =
        isDark ? AppColor.darkSurfaceSubtle : AppColor.surfaceContainerLow;
    final detailBorder = isDark ? AppColor.darkBorder : AppColor.outline;

    final hasPeerProfile =
        item.peerId.trim().isNotEmpty || item.peerName.trim().isNotEmpty;
    final displayName = _formatDisplayName(item.peerName);
    final designationAndCompany = [
      if (item.designation.trim().isNotEmpty) item.designation.trim(),
      if (item.company.trim().isNotEmpty) item.company.trim(),
    ].join(' · ');
    final statusLabel = _formatStatusText(item.status);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenMargin,
        vertical: 5,
      ),
      child: EnterpriseSurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        onTap: onTapCard ??
            (hasPeerProfile
                ? () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.peerProfile,
                      arguments: item.toPeerModel(),
                    );
                  }
                : null),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InitialsAvatar(
                  name: displayName,
                  imageUrl: item.avatarUrl,
                  radius: 19,
                  backgroundColor: AppColor.primaryContainer,
                  textColor: AppColor.onPrimaryContainer,
                  fontSize: 12,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              style: AppTypography.titleSmall.copyWith(
                                color: textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              color: AppColor.primary,
                              size: 13.5,
                            ),
                          ],
                        ],
                      ),
                      if (designationAndCompany.isNotEmpty) ...[
                        const SizedBox(height: 1.5),
                        Text(
                          designationAndCompany,
                          style: AppTypography.bodySmall.copyWith(
                            color: textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (item.city.trim().isNotEmpty ||
                          item.category.trim().isNotEmpty ||
                          (item.peerCode?.trim().isNotEmpty == true) ||
                          item.circleName.trim().isNotEmpty ||
                          (item.districtName?.trim().isNotEmpty == true)) ...[
                        const SizedBox(height: 2),
                        Text(
                          [
                            if (item.peerCode != null &&
                                item.peerCode!.trim().isNotEmpty)
                              item.peerCode!.trim(),
                            if (item.city.trim().isNotEmpty) item.city.trim(),
                            if (item.circleName.trim().isNotEmpty)
                              item.circleName.trim(),
                            if (item.districtName != null &&
                                item.districtName!.trim().isNotEmpty)
                              item.districtName!.trim(),
                            if (item.category.trim().isNotEmpty)
                              item.category.trim(),
                          ].join(' · '),
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 11,
                            color: textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    EnterpriseStatusBadge(
                      label: statusLabel,
                      tone: _toneForStatus(item.status),
                      compact: true,
                    ),
                    if (item.date.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.formattedDate.isNotEmpty
                            ? item.formattedDate
                            : item.date,
                        style: AppTypography.labelSmall.copyWith(
                          fontSize: 10.5,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 9),
            Divider(height: 1, color: dividerColor),
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: detailBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: detailBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTypography.labelLarge.copyWith(
                            color: textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.badgeLabel != null &&
                          item.badgeLabel!.trim().isNotEmpty) ...[
                        const SizedBox(width: 6),
                        EnterpriseStatusBadge(
                          label: item.badgeLabel!,
                          tone: EnterpriseStatusTone.info,
                          compact: true,
                        ),
                      ],
                    ],
                  ),
                  if (item.subtitle.trim().isNotEmpty &&
                      item.subtitle.trim() != item.title.trim()) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColor.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (item.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: textSecondary,
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
                          color: AppColor.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            item.targetPeerCompany != null &&
                                    item.targetPeerCompany!.isNotEmpty
                                ? '${item.targetPeerName} (${item.targetPeerCompany})'
                                : item.targetPeerName!,
                            style: AppTypography.labelMedium.copyWith(
                              color: textPrimary,
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
                        height: 38,
                        child: OutlinedButton.icon(
                          onPressed: isProcessing ? null : onReject,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColor.danger,
                            side: const BorderSide(
                              color: AppColor.rejectedBorder,
                            ),
                            backgroundColor: AppColor.rejectedBg,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                          ),
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 15,
                            color: AppColor.danger,
                          ),
                          label: Text(
                            'Reject',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColor.danger,
                              fontWeight: FontWeight.w600,
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
                        height: 38,
                        child: ElevatedButton.icon(
                          onPressed: isProcessing ? null : onApprove,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
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
                            style: AppTypography.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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
    );
  }
}
