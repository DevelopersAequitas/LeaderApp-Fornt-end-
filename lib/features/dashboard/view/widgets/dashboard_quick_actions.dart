import 'package:flutter/material.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/dashboard_metrics_model.dart';

class _QuickActionItem {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });
}

/// Curated, Role-Gated Executive Quick Actions Grid.
///
/// Surfaces only workflows permitted by `SessionManager().permissions` (capped
/// at 4–6 actions to eliminate shortcut overload).
class DashboardQuickActions extends StatelessWidget {
  final DashboardMetricsModel metrics;
  final String? selectedCircle;
  final VoidCallback onOpenPeersTab;
  final VoidCallback onOpenTeamsTab;
  final VoidCallback onOpenReportsTab;

  const DashboardQuickActions({
    super.key,
    required this.metrics,
    required this.selectedCircle,
    required this.onOpenPeersTab,
    required this.onOpenTeamsTab,
    required this.onOpenReportsTab,
  });

  @override
  Widget build(BuildContext context) {
    final session = SessionManager().currentSession;
    final perms = SessionManager().permissions;
    final isSuper = SessionManager().isSuperAdmin;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final textSecondary =
        isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;

    final actions = <_QuickActionItem>[];

    if (isSuper ||
        (session.role.canModeratePendingRequests &&
            perms.canReviewPendingPeers)) {
      actions.add(
        _QuickActionItem(
          label: 'Review Applications',
          subtitle: metrics.pendingRequestsCount > 0
              ? '${metrics.pendingRequestsCount} awaiting action'
              : 'Approval queue',
          icon: Icons.fact_check_outlined,
          accent: AppColor.pending,
          onTap: () => Navigator.of(context).pushNamed(
            AppRoutes.leaderActivities,
            arguments: {
              'type': 'pending-requests',
              'circleId': ?selectedCircle,
            },
          ),
        ),
      );
    }

    if (isSuper || perms.canAccessPeersTab) {
      actions.add(
        _QuickActionItem(
          label: 'View Peers',
          subtitle: '${metrics.totalPeers} in scope',
          icon: Icons.people_alt_outlined,
          accent: AppColor.primary,
          onTap: onOpenPeersTab,
        ),
      );
    }

    if (isSuper || perms.canAccessTeamsTab) {
      actions.add(
        _QuickActionItem(
          label: 'Manage Circles',
          subtitle: 'Teams & categories',
          icon: Icons.hub_outlined,
          accent: AppColor.tertiary,
          onTap: onOpenTeamsTab,
        ),
      );
    }

    if (isSuper || perms.canAccessRoleManagement) {
      actions.add(
        _QuickActionItem(
          label: 'Role Matrix',
          subtitle: 'RBAC & permissions',
          icon: Icons.admin_panel_settings_outlined,
          accent: const Color(0xFF4F46E5),
          onTap: () =>
              Navigator.of(context).pushNamed(AppRoutes.roleManagement),
        ),
      );
    }

    if (isSuper || perms.canAccessReportsTab) {
      actions.add(
        _QuickActionItem(
          label: 'View Reports',
          subtitle: 'Compliance & exports',
          icon: Icons.analytics_outlined,
          accent: const Color(0xFF0284C7),
          onTap: onOpenReportsTab,
        ),
      );
    }

    actions.add(
      _QuickActionItem(
        label: 'Official Circulars',
        subtitle: metrics.circulars > 0
            ? '${metrics.circulars} published'
            : 'Announcements',
        icon: Icons.campaign_outlined,
        accent: const Color(0xFF6D28D9),
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.circulars),
      ),
    );

    final visibleActions = actions.take(6).toList();
    if (visibleActions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EnterpriseSectionHeader(
          title: 'Quick Actions',
        ),
        const SizedBox(height: 10),
        Padding(
          padding: AppSpacing.pageHorizontal,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textScale = MediaQuery.textScalerOf(context).scale(1.0);
              final columns = constraints.maxWidth >= 640
                  ? 3
                  : ((constraints.maxWidth < 310 && textScale > 1.25) ? 1 : 2);
              final rows = <Widget>[];
              for (int i = 0; i < visibleActions.length; i += columns) {
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
                            child: (i + c < visibleActions.length)
                                ? _buildActionTile(
                                    action: visibleActions[i + c],
                                    textPrimary: textPrimary,
                                    textSecondary: textSecondary,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }
              return Column(children: rows);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required _QuickActionItem action,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return EnterpriseSurfaceCard(
      padding: const EdgeInsets.all(12),
      onTap: action.onTap,
      semanticLabel: '${action.label}, ${action.subtitle}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: action.accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                alignment: Alignment.center,
                child: Icon(action.icon, size: 16, color: action.accent),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            action.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelLarge.copyWith(color: textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            action.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmall.copyWith(
              fontSize: 11,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
