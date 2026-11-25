import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/dashboard_metrics_model.dart';

/// Compact Above-the-Fold Executive KPI Overview.
///
/// Keeps Revenue, Coins, Business Deal Values, and Impact metrics strictly
/// semantically separate, never inventing zero values or cross-substituting
/// missing fields (`null` / blank -> `"Unavailable"`).
class DashboardHeroCard extends StatelessWidget {
  final DashboardMetricsModel metrics;
  final String? selectedCircle;
  final int? totalCirclesCount;
  final int? activeCirclesCount;
  final VoidCallback? onImpactTap;
  final VoidCallback? onCoinsTap;
  final VoidCallback? onDealsTap;
  final VoidCallback? onP2PTap;
  final VoidCallback? onRevenueTap;
  final VoidCallback? onPeersTap;
  final VoidCallback? onCirclesTap;
  final VoidCallback? onPendingTap;

  const DashboardHeroCard({
    super.key,
    required this.metrics,
    this.selectedCircle,
    this.totalCirclesCount,
    this.activeCirclesCount,
    this.onImpactTap,
    this.onCoinsTap,
    this.onDealsTap,
    this.onP2PTap,
    this.onRevenueTap,
    this.onPeersTap,
    this.onCirclesTap,
    this.onPendingTap,
  });

  static String formatReadableCount(int number) {
    if (number < 0) return '0';
    if (number < 10000) {
      return NumberFormat.decimalPattern('en').format(number);
    }
    if (number < 1000000) {
      final v = (number / 1000).toStringAsFixed(1);
      return '${v.endsWith('.0') ? v.substring(0, v.length - 2) : v}K';
    }
    if (number < 1000000000) {
      final v = (number / 1000000).toStringAsFixed(1);
      return '${v.endsWith('.0') ? v.substring(0, v.length - 2) : v}M';
    }
    if (number < 1000000000000) {
      final v = (number / 1000000000).toStringAsFixed(1);
      return '${v.endsWith('.0') ? v.substring(0, v.length - 2) : v}B';
    }
    return '999B+';
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionManager().currentSession;
    final perms = SessionManager().permissions;
    final isSuper = SessionManager().isSuperAdmin;
    final canViewRevenue = isSuper || perms.canViewOverallRevenue;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 1. Revenue: strictly separated from Business Deals (`null` -> "Unavailable").
    final overallRevenue = metrics.overallRevenue?.trim();
    final hasOverallRevenue = overallRevenue != null &&
        overallRevenue.isNotEmpty &&
        overallRevenue.toLowerCase() != 'null';
    final revenueDisplay = hasOverallRevenue ? overallRevenue : 'Unavailable';

    // 2. Business Deals: strictly separated from Revenue (`null` -> "Unavailable").
    final deals = metrics.deals?.trim();
    final hasDeals =
        deals != null && deals.isNotEmpty && deals.toLowerCase() != 'null';
    final dealsDisplay = hasDeals ? deals : 'Unavailable';

    final primaryTiles = <Widget>[
      canViewRevenue
          ? EnterpriseMetricTile(
              compact: true,
              label: 'Total Revenue',
              value: revenueDisplay,
              isUnavailable: !hasOverallRevenue,
              icon: Icons.account_balance_wallet_outlined,
              accentColor: AppColor.success,
              onTap: onRevenueTap ??
                  () => Navigator.of(context).pushNamed('/finance'),
            )
          : EnterpriseMetricTile(
              compact: true,
              label: 'Total Coins',
              value: formatReadableCount(metrics.coins),
              icon: Icons.stars_outlined,
              accentColor: AppColor.warning,
              onTap: onCoinsTap ??
                  () => Navigator.of(context).pushNamed(
                        AppRoutes.leaderActivities,
                        arguments: {
                          'type': 'coins',
                          'circleId': ?selectedCircle,
                        },
                      ),
            ),
      EnterpriseMetricTile(
        compact: true,
        label: 'Business Deals',
        value: dealsDisplay,
        isUnavailable: !hasDeals,
        icon: Icons.handshake_outlined,
        accentColor: AppColor.primary,
        contextNote: metrics.dealsCount > 0
            ? '(${formatReadableCount(metrics.dealsCount)})'
            : null,
        onTap: onDealsTap ??
            () => Navigator.of(context).pushNamed(
                  AppRoutes.leaderActivities,
                  arguments: {
                    'type': 'business-deals',
                    'circleId': ?selectedCircle,
                  },
                ),
      ),
      EnterpriseMetricTile(
        compact: true,
        label: 'Total Peers',
        value: formatReadableCount(metrics.totalPeers),
        icon: Icons.groups_2_outlined,
        accentColor: AppColor.tertiary,
        contextNote: metrics.totalPeersGrowth > 0
            ? '+${metrics.totalPeersGrowth}'
            : null,
        noteTone:
            metrics.totalPeersGrowth > 0 ? EnterpriseStatusTone.active : null,
        onTap: onPeersTap ??
            () => Navigator.of(context).pushNamed(
                  AppRoutes.leaderActivities,
                  arguments: {
                    'type': 'peers',
                    'circleId': ?selectedCircle,
                  },
                ),
      ),
      EnterpriseMetricTile(
        compact: true,
        label: 'Lives Impacted',
        value: formatReadableCount(metrics.impact),
        icon: Icons.volunteer_activism_outlined,
        accentColor: AppColor.secondary,
        onTap: onImpactTap ??
            () => Navigator.of(context).pushNamed(
                  AppRoutes.leaderActivities,
                  arguments: {
                    'type': 'impacts',
                    'circleId': ?selectedCircle,
                  },
                ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (totalCirclesCount != null) ...[
          const EnterpriseSectionHeader(
            title: 'Organizational Overview',
          ),
          const SizedBox(height: 8),
        ],
        Padding(
          padding: AppSpacing.pageHorizontal,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 680 ? 4 : 2;
              final rows = <Widget>[];
              for (int i = 0; i < primaryTiles.length; i += columns) {
                if (rows.isNotEmpty) {
                  rows.add(const SizedBox(height: 8));
                }
                rows.add(
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int c = 0; c < columns; c++) ...[
                          if (c > 0) const SizedBox(width: 8),
                          Expanded(
                            child: (i + c < primaryTiles.length)
                                ? primaryTiles[i + c]
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...rows,
                  if (totalCirclesCount != null) ...[
                    const SizedBox(height: 8),
                    _buildScopeSummaryStrip(
                      context: context,
                      role: session.role,
                      isSuper: isSuper,
                      canAccessTeams: perms.canAccessTeamsTab,
                      canReviewPending: isSuper ||
                          (session.role.canModeratePendingRequests &&
                              perms.canReviewPendingPeers),
                      isDark: isDark,
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScopeSummaryStrip({
    required BuildContext context,
    required UserRole role,
    required bool isSuper,
    required bool canAccessTeams,
    required bool canReviewPending,
    required bool isDark,
  }) {
    final totalC = totalCirclesCount ?? 0;
    final activeC = activeCirclesCount ?? totalC;
    final showCirclesStat = isSuper ||
        canAccessTeams ||
        role == UserRole.countryDirector ||
        role == UserRole.districtExecDirector ||
        role == UserRole.industryDirector;

    final dividerColor = isDark ? AppColor.darkDivider : AppColor.divider;

    return EnterpriseSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: showCirclesStat
                  ? _buildCompactStatItem(
                      label: 'Active Circles',
                      value: totalC > activeC
                          ? '$activeC / $totalC'
                          : formatReadableCount(activeC),
                      isDark: isDark,
                      onTap: onCirclesTap,
                    )
                  : _buildCompactStatItem(
                      label: '1-on-1 P2Ps',
                      value: formatReadableCount(metrics.p2pMeetings),
                      isDark: isDark,
                      onTap: onP2PTap ??
                          () => Navigator.of(context).pushNamed(
                                AppRoutes.leaderActivities,
                                arguments: {
                                  'type': 'p2p-meetings',
                                  'circleId': ?selectedCircle,
                                },
                              ),
                    ),
            ),
            VerticalDivider(width: 10, thickness: 1, color: dividerColor),
            Expanded(
              child: _buildCompactStatItem(
                label: 'Open Asks',
                value: formatReadableCount(metrics.openAsks),
                isDark: isDark,
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.leaderActivities,
                  arguments: {
                    'type': 'open-asks',
                    'circleId': ?selectedCircle,
                  },
                ),
              ),
            ),
            VerticalDivider(width: 10, thickness: 1, color: dividerColor),
            Expanded(
              child: canReviewPending
                  ? _buildCompactStatItem(
                      label: 'Approvals',
                      value: formatReadableCount(metrics.pendingRequestsCount),
                      valueColor: metrics.pendingRequestsCount > 0
                          ? AppColor.pending
                          : AppColor.success,
                      isDark: isDark,
                      onTap: onPendingTap ??
                          () => Navigator.of(context).pushNamed(
                                AppRoutes.leaderActivities,
                                arguments: {
                                  'type': 'pending-requests',
                                  'circleId': ?selectedCircle,
                                },
                              ),
                    )
                  : _buildCompactStatItem(
                      label: 'Referrals',
                      value: formatReadableCount(metrics.referrals),
                      isDark: isDark,
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.leaderActivities,
                        arguments: {
                          'type': 'referrals',
                          'circleId': ?selectedCircle,
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStatItem({
    required String label,
    required String value,
    required bool isDark,
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    final textPrimary =
        isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final textSecondary =
        isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;

    return Semantics(
      button: onTap != null,
      label: '$label: $value',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: AppTypography.metricSmall.copyWith(
                    color: valueColor ?? textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 11,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
