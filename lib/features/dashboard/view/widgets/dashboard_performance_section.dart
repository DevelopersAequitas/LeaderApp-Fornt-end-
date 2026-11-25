import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../teams/model/teams_model.dart';
import '../../model/dashboard_metrics_model.dart';
import '../../presenter/dashboard_presenter.dart';

enum _PerfLens {
  regions('Regions'),
  industries('Industries'),
  circles('Circles'),
  execution('Asks');

  final String label;
  const _PerfLens(this.label);
}

class _PerfBarRowData {
  final String label;
  final String subtitle;
  final int primaryValue;
  final String formattedValue;
  final Color barColor;
  final VoidCallback? onTap;

  const _PerfBarRowData({
    required this.label,
    required this.subtitle,
    required this.primaryValue,
    required this.formattedValue,
    required this.barColor,
    this.onTap,
  });
}

/// Role-Aware Organizational Performance & Distribution Module.
///
/// Renders clean comparative horizontal bar visualizations strictly from real
/// backend data (`List<CircleTeamModel>` & `DashboardMetricsModel`) — never
/// fabricating trend percentages or synthetic curves.
class DashboardPerformanceSection extends StatefulWidget {
  final DashboardMetricsModel metrics;
  final List<CircleTeamModel> circles;
  final String? selectedCircle;
  final VoidCallback onOpenTeamsTab;

  const DashboardPerformanceSection({
    super.key,
    required this.metrics,
    required this.circles,
    required this.selectedCircle,
    required this.onOpenTeamsTab,
  });

  @override
  State<DashboardPerformanceSection> createState() =>
      _DashboardPerformanceSectionState();
}

class _DashboardPerformanceSectionState
    extends State<DashboardPerformanceSection> {
  int _selectedLensIndex = 0;

  List<_PerfLens> _lensesForRole(UserRole role) {
    final hasCircles = widget.circles.isNotEmpty;
    return switch (role) {
      UserRole.superAdmin ||
      UserRole.globalFounder ||
      UserRole.countryDirector => [
          if (hasCircles) _PerfLens.regions,
          if (hasCircles) _PerfLens.industries,
          if (hasCircles) _PerfLens.circles,
          _PerfLens.execution,
        ],
      UserRole.districtExecDirector => [
          if (hasCircles) _PerfLens.circles,
          if (hasCircles) _PerfLens.regions,
          _PerfLens.execution,
        ],
      UserRole.industryDirector => [
          if (hasCircles) _PerfLens.industries,
          if (hasCircles) _PerfLens.circles,
          _PerfLens.execution,
        ],
      _ => [
          _PerfLens.execution,
          if (hasCircles) _PerfLens.circles,
        ],
    };
  }

  List<_PerfBarRowData> _buildRows(BuildContext context, _PerfLens lens) {
    final palette = AppColor.dataSeries;

    switch (lens) {
      case _PerfLens.regions:
        final byLocation = <String, List<CircleTeamModel>>{};
        for (final c in widget.circles) {
          final loc = c.location.trim().isNotEmpty
              ? c.location.trim()
              : 'Unassigned Region';
          byLocation.putIfAbsent(loc, () => []).add(c);
        }
        final entries = byLocation.entries.toList()
          ..sort((a, b) {
            final peersA =
                a.value.fold<int>(0, (sum, item) => sum + item.peersCount);
            final peersB =
                b.value.fold<int>(0, (sum, item) => sum + item.peersCount);
            if (peersB != peersA) return peersB.compareTo(peersA);
            return b.value.length.compareTo(a.value.length);
          });

        return entries.take(6).indexed.map((entry) {
          final idx = entry.$1;
          final e = entry.$2;
          final circleCount = e.value.length;
          final peerSum =
              e.value.fold<int>(0, (sum, item) => sum + item.peersCount);
          final activeCount = e.value
              .where((c) => c.status.trim().toLowerCase() == 'active')
              .length;
          final metricVal = peerSum > 0 ? peerSum : circleCount;
          final subtitleParts = <String>[
            '$circleCount ${circleCount == 1 ? 'Circle' : 'Circles'}',
            if (activeCount > 0 && activeCount < circleCount)
              '$activeCount Active',
          ];
          return _PerfBarRowData(
            label: e.key,
            subtitle: subtitleParts.join(' · '),
            primaryValue: metricVal,
            formattedValue:
                peerSum > 0 ? '$peerSum Peers' : '$circleCount Circles',
            barColor: palette[idx % palette.length],
            onTap: widget.onOpenTeamsTab,
          );
        }).toList();

      case _PerfLens.industries:
        final byIndustry = <String, List<CircleTeamModel>>{};
        for (final c in widget.circles) {
          final cat = c.category.trim().isNotEmpty
              ? c.category.trim()
              : 'Multi-Industry';
          byIndustry.putIfAbsent(cat, () => []).add(c);
        }
        final entries = byIndustry.entries.toList()
          ..sort((a, b) {
            final peersA =
                a.value.fold<int>(0, (sum, item) => sum + item.peersCount);
            final peersB =
                b.value.fold<int>(0, (sum, item) => sum + item.peersCount);
            if (peersB != peersA) return peersB.compareTo(peersA);
            return b.value.length.compareTo(a.value.length);
          });

        return entries.take(6).indexed.map((entry) {
          final idx = entry.$1;
          final e = entry.$2;
          final circleCount = e.value.length;
          final peerSum =
              e.value.fold<int>(0, (sum, item) => sum + item.peersCount);
          final metricVal = peerSum > 0 ? peerSum : circleCount;
          return _PerfBarRowData(
            label: e.key,
            subtitle: '$circleCount ${circleCount == 1 ? 'Circle' : 'Circles'}',
            primaryValue: metricVal,
            formattedValue:
                peerSum > 0 ? '$peerSum Peers' : '$circleCount Circles',
            barColor: palette[idx % palette.length],
            onTap: widget.onOpenTeamsTab,
          );
        }).toList();

      case _PerfLens.circles:
        final sorted = List<CircleTeamModel>.from(widget.circles)
          ..sort((a, b) {
            if (b.peersCount != a.peersCount) {
              return b.peersCount.compareTo(a.peersCount);
            }
            return a.name.compareTo(b.name);
          });

        return sorted.take(6).indexed.map((entry) {
          final idx = entry.$1;
          final c = entry.$2;
          final isFlagged = DashboardPresenter.isBackendFlaggedCircle(c);
          final subParts = <String>[
            if (c.location.trim().isNotEmpty) c.location.trim(),
            if (c.category.trim().isNotEmpty) c.category.trim(),
            if (c.status.trim().isNotEmpty) c.status.trim(),
          ];
          return _PerfBarRowData(
            label: c.name,
            subtitle: subParts.isNotEmpty ? subParts.join(' · ') : 'Active',
            primaryValue: c.peersCount > 0 ? c.peersCount : 1,
            formattedValue: c.peersCount > 0
                ? '${c.peersCount} Peers'
                : (c.status.trim().isNotEmpty ? c.status.trim() : 'Active'),
            barColor: isFlagged
                ? AppColor.critical
                : palette[idx % palette.length],
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.circleDetails,
              arguments: c,
            ),
          );
        }).toList();

      case _PerfLens.execution:
        final m = widget.metrics;
        void openActivity(String type) {
          Navigator.of(context).pushNamed(
            AppRoutes.leaderActivities,
            arguments: {
              'type': type,
              'circleId': ?widget.selectedCircle,
            },
          );
        }

        return [
          _PerfBarRowData(
            label: 'Collaboration Asks',
            subtitle: 'Joint ventures & strategic alliances',
            primaryValue: m.collaborationAsks,
            formattedValue: '${m.collaborationAsks}',
            barColor: palette[0],
            onTap: () => openActivity('collaboration-asks'),
          ),
          _PerfBarRowData(
            label: 'Peer Requirements',
            subtitle: 'Commercial procurement & opportunities',
            primaryValue: m.requirements,
            formattedValue: '${m.requirements}',
            barColor: palette[1],
            onTap: () => openActivity('requirements'),
          ),
          _PerfBarRowData(
            label: 'Help & Advisory Asks',
            subtitle: 'Operational guidance & peer mentoring',
            primaryValue: m.helpAsks,
            formattedValue: '${m.helpAsks}',
            barColor: palette[2],
            onTap: () => openActivity('help-asks'),
          ),
          _PerfBarRowData(
            label: 'Referral Asks',
            subtitle: 'Warm decision-maker introductions',
            primaryValue: m.referralAsks,
            formattedValue: '${m.referralAsks}',
            barColor: palette[3],
            onTap: () => openActivity('referral-asks'),
          ),
          _PerfBarRowData(
            label: 'Fulfilled Outcomes',
            subtitle: '${m.inProgressAsks} currently in progress',
            primaryValue: m.fulfilledAsks,
            formattedValue: '${m.fulfilledAsks}',
            barColor: AppColor.success,
            onTap: () => openActivity('fulfilled-asks'),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = SessionManager().currentSession.role;
    final lenses = _lensesForRole(role);
    final safeIdx = _selectedLensIndex.clamp(0, lenses.length - 1);
    final activeLens = lenses[safeIdx];
    final rows = _buildRows(context, activeLens);
    final maxVal = rows.fold<int>(
      0,
      (prev, r) => r.primaryValue > prev ? r.primaryValue : prev,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final textSecondary =
        isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;
    final trackColor =
        isDark ? AppColor.darkSurfaceSubtle : AppColor.surfaceContainer;

    final chartSubtitle = switch (activeLens) {
      _PerfLens.regions => 'Peer & Circle concentration by geographic territory',
      _PerfLens.industries => 'Active Circle coverage across industry verticals',
      _PerfLens.circles => 'Top Circles ranked by active Peer strength',
      _PerfLens.execution => 'Demand breakdown across Peer Ask workflows',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EnterpriseSectionHeader(
          title: 'Organizational Performance',
          actionLabel: activeLens != _PerfLens.execution ? 'Directory' : 'All Asks',
          onActionTap: activeLens != _PerfLens.execution
              ? widget.onOpenTeamsTab
              : () => Navigator.of(context).pushNamed(
                    AppRoutes.leaderActivities,
                    arguments: {
                      'type': 'all-asks',
                      'circleId': ?widget.selectedCircle,
                    },
                  ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: AppSpacing.pageHorizontal,
          child: EnterpriseSurfaceCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (lenses.length > 1) ...[
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColor.darkSurfaceSubtle
                          : AppColor.surfaceContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Row(
                      children: [
                        for (int i = 0; i < lenses.length; i++)
                          Expanded(
                            child: _buildLensChip(
                              label: lenses[i].label,
                              isSelected: i == safeIdx,
                              isDark: isDark,
                              onTap: () {
                                if (safeIdx != i) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedLensIndex = i);
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  chartSubtitle,
                  style: AppTypography.bodySmall.copyWith(color: textSecondary),
                ),
                const SizedBox(height: 14),
                if (rows.isEmpty || (maxVal == 0 && activeLens != _PerfLens.execution))
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No distribution records recorded in this scope yet.',
                      style: AppTypography.bodySmall,
                    ),
                  )
                else
                  RepaintBoundary(
                    child: Column(
                      children: [
                        for (int i = 0; i < rows.length; i++) ...[
                          if (i > 0) const SizedBox(height: 12),
                          _buildBarItem(
                            row: rows[i],
                            fraction: maxVal > 0
                                ? (rows[i].primaryValue / maxVal).clamp(0.0, 1.0)
                                : 0.0,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            trackColor: trackColor,
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLensChip({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final bg = isSelected
        ? (isDark ? AppColor.darkSurfaceElevated : AppColor.lightSurface)
        : Colors.transparent;
    final fg = isSelected
        ? (isDark ? AppColor.darkTextPrimary : AppColor.primary)
        : (isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary);

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label performance view',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
            border: isSelected
                ? Border.all(
                    color: isDark ? AppColor.darkBorder : AppColor.outline,
                  )
                : null,
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: AppTypography.labelMedium.copyWith(
                color: fg,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarItem({
    required _PerfBarRowData row,
    required double fraction,
    required Color textPrimary,
    required Color textSecondary,
    required Color trackColor,
  }) {
    return Semantics(
      button: row.onTap != null,
      label: '${row.label}: ${row.formattedValue}, ${row.subtitle}',
      child: InkWell(
        onTap: row.onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: row.barColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      row.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelLarge.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    row.formattedValue,
                    style: AppTypography.metricSmall.copyWith(
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 6,
                  width: double.infinity,
                  child: ColoredBox(
                    color: trackColor,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: fraction == 0 ? 0.02 : fraction,
                        child: Container(
                          decoration: BoxDecoration(
                            color: fraction == 0
                                ? AppColor.outlineStrong
                                : row.barColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                row.subtitle,
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
