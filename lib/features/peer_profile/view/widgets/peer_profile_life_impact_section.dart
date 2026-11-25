import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../impacts/model/life_impact_detail_model.dart';
import '../../model/peer_profile_sections_model.dart';

/// Section F: Life Impact summary, status filters & submissions navigating to Detail/Review.
class PeerProfileLifeImpactSection extends StatelessWidget {
  final PeerLifeImpactSummaryModel lifeImpact;
  final String? activeFilter;
  final ValueChanged<String?> onFilterChanged;
  final VoidCallback? onRefreshProfile;

  const PeerProfileLifeImpactSection({
    super.key,
    required this.lifeImpact,
    required this.activeFilter,
    required this.onFilterChanged,
    this.onRefreshProfile,
  });

  String _formatDate(String raw) {
    if (raw.trim().isEmpty) return '';
    final dt = DateTimeUtils.parseUtc(raw);
    if (dt == null) return raw;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  EnterpriseStatusTone _toneForStatus(String status) {
    switch (status.toLowerCase().trim()) {
      case 'approved':
        return EnterpriseStatusTone.active;
      case 'rejected':
        return EnterpriseStatusTone.rejected;
      default:
        return EnterpriseStatusTone.pending;
    }
  }

  Future<void> _openDetail(
    BuildContext context,
    LifeImpactDetailModel item,
  ) async {
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.lifeImpactDetail,
      arguments: {
        'id': item.id,
        'initialDetail': item,
      },
    );
    if (result == true) {
      onRefreshProfile?.call();
    }
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

    final normalizedFilter = activeFilter?.toLowerCase().trim();
    final filtered = lifeImpact.submissions.where((s) {
      if (normalizedFilter == null || normalizedFilter.isEmpty) return true;
      return s.status.toLowerCase().trim() == normalizedFilter;
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EnterpriseSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LIFE IMPACT SUMMARY',
                  style: AppTypography.labelSmall.copyWith(color: textMuted),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _ImpactCountBox(
                        label: 'Approved',
                        value: '${lifeImpact.approvedCount}',
                        color: AppColor.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ImpactCountBox(
                        label: 'Pending',
                        value: '${lifeImpact.pendingCount}',
                        color: AppColor.warning,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ImpactCountBox(
                        label: 'Rejected',
                        value: '${lifeImpact.rejectedCount}',
                        color: AppColor.danger,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ImpactCountBox(
                        label: 'Lives',
                        value: '${lifeImpact.totalLivesImpacted}',
                        color: AppColor.primary,
                      ),
                    ),
                  ],
                ),
                if (lifeImpact.categories.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: lifeImpact.categories
                        .map(
                          (cat) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColor.darkSurfaceElevated
                                  : AppColor.surfaceContainer,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusPill),
                            ),
                            child: Text(
                              '${cat.category} (${cat.count})',
                              style: AppTypography.labelSmall
                                  .copyWith(color: textSecondary),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterPill(
                  label: 'All (${lifeImpact.submissions.length})',
                  selected: normalizedFilter == null || normalizedFilter.isEmpty,
                  onTap: () => onFilterChanged(null),
                ),
                const SizedBox(width: 6),
                _FilterPill(
                  label: 'Pending (${lifeImpact.pendingCount})',
                  selected: normalizedFilter == 'pending',
                  onTap: () => onFilterChanged('pending'),
                ),
                const SizedBox(width: 6),
                _FilterPill(
                  label: 'Approved (${lifeImpact.approvedCount})',
                  selected: normalizedFilter == 'approved',
                  onTap: () => onFilterChanged('approved'),
                ),
                const SizedBox(width: 6),
                _FilterPill(
                  label: 'Rejected (${lifeImpact.rejectedCount})',
                  selected: normalizedFilter == 'rejected',
                  onTap: () => onFilterChanged('rejected'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          if (filtered.isEmpty)
            EnterpriseSurfaceCard(
              child: Text(
                'No Life Impact submissions match this filter.',
                style: AppTypography.bodyMedium.copyWith(color: textSecondary),
              ),
            )
          else
            for (final item in filtered) ...[
              EnterpriseSurfaceCard(
                onTap: () => _openDetail(context, item),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title.isNotEmpty
                                    ? item.title
                                    : (item.impactCategory.isNotEmpty
                                        ? item.impactCategory
                                        : 'Life Impact Submission'),
                                style: AppTypography.titleSmall.copyWith(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (item.impactCategory.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    item.impactCategory,
                                    style: AppTypography.labelSmall
                                        .copyWith(color: AppColor.primary),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        EnterpriseStatusBadge(
                          label: item.statusLabel.isNotEmpty
                              ? item.statusLabel
                              : item.status.toUpperCase(),
                          tone: _toneForStatus(item.status),
                          compact: true,
                        ),
                      ],
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall
                            .copyWith(color: textSecondary),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (item.impactDate.isNotEmpty ||
                            item.submittedAt.isNotEmpty)
                          Expanded(
                            child: Text(
                              _formatDate(
                                item.impactDate.isNotEmpty
                                    ? item.impactDate
                                    : item.submittedAt,
                              ),
                              style: AppTypography.labelSmall
                                  .copyWith(color: textMuted),
                            ),
                          )
                        else
                          const Spacer(),
                        if (item.livesImpacted > 0)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Text(
                              '${item.livesImpacted} ${item.livesImpacted == 1 ? 'life' : 'lives'}',
                              style: AppTypography.labelSmall
                                  .copyWith(color: textSecondary),
                            ),
                          ),
                        Text(
                          (item.isPending && lifeImpact.canModerateImpacts)
                              ? 'Review'
                              : 'View Details',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColor.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: AppColor.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class _ImpactCountBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ImpactCountBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColor.darkSurfaceElevated : AppColor.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: isDark ? AppColor.darkBorder : AppColor.outline,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmall.copyWith(
              color: isDark
                  ? AppColor.darkTextSecondary
                  : AppColor.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      labelStyle: AppTypography.labelMedium.copyWith(
        color: selected
            ? Colors.white
            : (isDark
                ? AppColor.darkTextSecondary
                : AppColor.lightTextSecondary),
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
      selectedColor: AppColor.primary,
      backgroundColor: isDark ? AppColor.darkSurface : AppColor.lightSurface,
      side: BorderSide(
        color: selected
            ? AppColor.primary
            : (isDark ? AppColor.darkBorder : AppColor.outline),
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}
