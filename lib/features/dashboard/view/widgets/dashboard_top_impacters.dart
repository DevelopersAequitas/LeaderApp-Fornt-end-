import 'package:flutter/material.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../peers/model/peer_model.dart';
import '../../model/dashboard_metrics_model.dart';
import '../../model/impacter_model.dart';
import 'dashboard_hero_card.dart';

/// Executive Leaderboard of Top Impact Leaders in the active scope.
///
/// Uses clean title-case names, subtle rank badges, company/location metadata,
/// and explicit unit labels (`Impacts`) inside a single bordered list container.
class DashboardTopImpacters extends StatelessWidget {
  final List<ImpacterModel> impacters;
  final DashboardMetricsModel? metrics;
  final String? selectedCircle;

  const DashboardTopImpacters({
    super.key,
    required this.impacters,
    this.metrics,
    this.selectedCircle,
  });

  void _openAllImpacters(BuildContext context) {
    Navigator.of(context).pushNamed(
      AppRoutes.leaderActivities,
      arguments: {
        'type': 'impacts',
        'circleId': ?selectedCircle,
      },
    );
  }

  static String _formatDisplayName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'Peer';
    // Only normalize when backend returned an all-uppercase name string.
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

  @override
  Widget build(BuildContext context) {
    if (impacters.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final textSecondary =
        isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;
    final dividerColor = isDark ? AppColor.darkDivider : AppColor.divider;

    final topList = impacters.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EnterpriseSectionHeader(
          title: 'Top Impact Leaders',
          actionLabel: 'View All',
          onActionTap: () => _openAllImpacters(context),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: AppSpacing.pageHorizontal,
          child: EnterpriseSurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < topList.length; i++) ...[
                  _buildImpacterRow(
                    context: context,
                    impacter: topList[i],
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    isFirst: i == 0,
                    isLast: i == topList.length - 1,
                  ),
                  if (i < topList.length - 1)
                    Divider(height: 1, thickness: 1, color: dividerColor),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImpacterRow({
    required BuildContext context,
    required ImpacterModel impacter,
    required Color textPrimary,
    required Color textSecondary,
    required bool isFirst,
    required bool isLast,
  }) {
    final displayName = _formatDisplayName(impacter.name);
    final rawDesig = impacter.designation != null &&
            impacter.designation!.trim().isNotEmpty
        ? impacter.designation!.trim()
        : '';
    final displayDesig = rawDesig.toLowerCase() == 'member' ? 'Peer' : rawDesig;
    final displayComp = impacter.company.trim();

    final subtitleParts = <String>[
      if (displayDesig.isNotEmpty && displayComp.isNotEmpty)
        '$displayDesig · $displayComp'
      else if (displayComp.isNotEmpty)
        displayComp
      else if (displayDesig.isNotEmpty)
        displayDesig,
      if (impacter.location.trim().isNotEmpty) impacter.location.trim(),
    ];

    final isTopThree = impacter.rank <= 3;

    return InkWell(
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(AppSpacing.radiusMd) : Radius.zero,
        bottom: isLast ? const Radius.circular(AppSpacing.radiusMd) : Radius.zero,
      ),
      onTap: () {
        final session = SessionManager().currentSession;
        final String rawCircleName = metrics?.circleName ?? '';
        final bool isPlaceholder =
            rawCircleName.toLowerCase().contains('enter ') ||
            rawCircleName.isEmpty;
        final String activeCircle = !isPlaceholder
            ? rawCircleName
            : (selectedCircle ??
                (session.managedCircles.isNotEmpty
                    ? session.managedCircles.first
                    : session.regionalScope));

        final peer = PeerModel(
          id: impacter.id,
          initials: impacter.initials,
          name: impacter.name,
          avatarUrl: impacter.avatarUrl,
          company: impacter.company,
          circle: impacter.circle.isNotEmpty ? impacter.circle : activeCircle,
          circleId: impacter.circleId,
          location: impacter.location,
          tags: impacter.tags,
          impactCount: impacter.lives,
          dealsFormatted: impacter.dealsFormatted,
          coins: impacter.coins,
          attendance: impacter.attendance,
          status: impacter.status.isNotEmpty ? impacter.status : 'Active',
          phone: impacter.phone,
          email: impacter.email,
          designation: impacter.designation,
          industry: impacter.industry,
          level4Category: impacter.level4Category,
          isVerified: impacter.isVerified,
          introVideoUrl: impacter.introVideoUrl,
        );
        Navigator.of(context).pushNamed(
          AppRoutes.peerProfile,
          arguments: peer,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                '#${impacter.rank}',
                style: AppTypography.labelMedium.copyWith(
                  color: isTopThree ? AppColor.primary : textSecondary,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            InitialsAvatar(
              name: displayName,
              imageUrl: impacter.avatarUrl,
              radius: 18,
              backgroundColor: AppColor.primaryContainer,
              textColor: AppColor.onPrimaryContainer,
              fontSize: 12,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      if (impacter.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          color: AppColor.primary,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                  if (subtitleParts.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitleParts.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DashboardHeroCard.formatReadableCount(impacter.lives),
                  style: AppTypography.metricSmall.copyWith(color: textPrimary),
                ),
                Text(
                  impacter.lives == 1 ? 'Impact' : 'Impacts',
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 11,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 17,
              color: textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
