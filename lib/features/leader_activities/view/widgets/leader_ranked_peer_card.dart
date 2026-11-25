import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../model/leader_activity_item_model.dart';

/// Enterprise Peer list row displayed inside activity drill-down screens.
///
/// By default (`showContributionRank == false`), presents pure Peer identity
/// details (Title-Case Name, Verified badge, Location, Designation · Company,
/// and Category/Circle) with direct navigation to `PeerProfileView` — without
/// repeating aggregate counts.
///
/// When `showContributionRank == true` (on the **Top Contributors** tab), also
/// displays a subtle rank indicator (`#1`, `#2`, …) and verified contribution
/// total (`metricDisplay` + `metricLabel`).
class LeaderRankedPeerCard extends StatelessWidget {
  final LeaderRankedPeerModel item;
  final IconData metricIcon;
  final bool showContributionRank;
  final bool showRecency;

  const LeaderRankedPeerCard({
    super.key,
    required this.item,
    this.metricIcon = Icons.person_rounded,
    this.showContributionRank = false,
    this.showRecency = false,
  });

  static String _formatDisplayName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'Peer';
    final isAllUpper = trimmed == trimmed.toUpperCase() && trimmed.length > 2;
    final isAllLower = trimmed == trimmed.toLowerCase();
    if (isAllUpper || isAllLower) {
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

  static String _normalizeDesignation(String? raw) {
    final trimmed = (raw ?? '').trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.toLowerCase() == 'member') return 'Peer';
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final peer = item.peer;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final textSecondary =
        isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;
    final textMuted =
        isDark ? AppColor.darkTextTertiary : AppColor.lightTextMuted;

    final displayName = _formatDisplayName(peer.name);
    final displayDesignation = _normalizeDesignation(peer.designation);
    final displayCompany = peer.company.trim();

    final designationAndCompany = [
      if (displayDesignation.isNotEmpty) displayDesignation,
      if (displayCompany.isNotEmpty) displayCompany,
    ].join(' · ');

    final displayCategory = (peer.level4Category ?? '').trim().isNotEmpty
        ? peer.level4Category!.trim()
        : (peer.tags.trim().isNotEmpty
            ? peer.tags.trim()
            : (peer.industry ?? '').trim());

    final recencyText = showRecency && item.latestActivityAt != null
        ? DateTimeUtils.formatTimeAgo(item.latestActivityAt!.toIso8601String())
        : '';

    final metricChipLabel = item.metricDisplay.trim().isNotEmpty
        ? (item.metricLabel.trim().isNotEmpty &&
                !item.metricDisplay
                    .toLowerCase()
                    .contains(item.metricLabel.toLowerCase()) &&
                !item.metricDisplay.contains('₹')
            ? '${item.metricDisplay.trim()} ${item.metricLabel.trim()}'
            : item.metricDisplay.trim())
        : '';

    return Semantics(
      button: true,
      label: 'Open profile for $displayName',
      child: EnterpriseSurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.peerProfile,
            arguments: peer,
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showContributionRank) ...[
              Container(
                width: 28,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: item.rank <= 3
                      ? AppColor.primaryContainer
                      : (isDark
                          ? AppColor.darkSurfaceElevated
                          : AppColor.surfaceContainer),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                ),
                child: Text(
                  '#${item.rank}',
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: item.rank <= 3
                        ? (isDark
                            ? const Color(0xFF93C5FD)
                            : AppColor.primary)
                        : textSecondary,
                  ),
                ),
              ),
            ],
            InitialsAvatar(
              name: displayName,
              imageUrl: peer.avatarUrl,
              radius: 20,
              backgroundColor: AppColor.primaryContainer,
              textColor: AppColor.onPrimaryContainer,
              fontSize: 12.5,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleSmall.copyWith(
                            color: textPrimary,
                          ),
                        ),
                      ),
                      if (peer.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          color: AppColor.primary,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                  if (designationAndCompany.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      designationAndCompany,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: textSecondary,
                      ),
                    ),
                  ],
                  if (peer.location.trim().isNotEmpty ||
                      displayCategory.isNotEmpty ||
                      recencyText.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (peer.location.trim().isNotEmpty) ...[
                          Icon(
                            Icons.place_outlined,
                            size: 12,
                            color: textMuted,
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              peer.location.trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelSmall.copyWith(
                                fontSize: 11,
                                color: textMuted,
                              ),
                            ),
                          ),
                        ],
                        if (peer.location.trim().isNotEmpty &&
                            displayCategory.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              '·',
                              style: AppTypography.labelSmall.copyWith(
                                color: textMuted,
                              ),
                            ),
                          ),
                        if (displayCategory.isNotEmpty)
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColor.primary.withValues(alpha: 0.14)
                                    : AppColor.primaryContainer,
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusXs),
                              ),
                              child: Text(
                                displayCategory,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelSmall.copyWith(
                                  fontSize: 10.5,
                                  color: isDark
                                      ? const Color(0xFF93C5FD)
                                      : AppColor.onPrimaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        if (recencyText.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.schedule_rounded,
                            size: 11,
                            color: textMuted,
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              recencyText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelSmall.copyWith(
                                fontSize: 10.5,
                                color: textMuted,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (showContributionRank && metricChipLabel.isNotEmpty) ...[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 104),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColor.primary.withValues(alpha: 0.16)
                        : AppColor.primaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                  ),
                  child: Text(
                    metricChipLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: isDark
                          ? const Color(0xFF93C5FD)
                          : AppColor.primary,
                    ),
                  ),
                ),
              ),
            ] else
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: textMuted,
              ),
          ],
        ),
      ),
    );
  }
}
