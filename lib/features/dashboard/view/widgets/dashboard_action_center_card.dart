import 'package:flutter/material.dart';
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

class _ActionRequiredItem {
  final String title;
  final String reason;
  final String ownerContext;
  final String badgeLabel;
  final EnterpriseStatusTone tone;
  final String ctaLabel;
  final IconData icon;
  final VoidCallback onAction;

  const _ActionRequiredItem({
    required this.title,
    required this.reason,
    required this.ownerContext,
    required this.badgeLabel,
    required this.tone,
    required this.ctaLabel,
    required this.icon,
    required this.onAction,
  });
}

/// Concise Above-the-Fold Priority Action Module: "Action Required".
///
/// Displays at most the 3 highest-priority actionable items initially with
/// "View All" opening the full priority queue. Evaluates Circle escalations and
/// leadership vacancies strictly from verified backend fields — never inventing
/// numeric Circle health thresholds.
class DashboardActionCenterCard extends StatelessWidget {
  final DashboardMetricsModel metrics;
  final List<CircleTeamModel> circles;
  final String? selectedCircle;
  final VoidCallback onOpenTeamsTab;
  final VoidCallback? onOpenReportsTab;

  const DashboardActionCenterCard({
    super.key,
    required this.metrics,
    required this.circles,
    required this.selectedCircle,
    required this.onOpenTeamsTab,
    this.onOpenReportsTab,
  });

  List<_ActionRequiredItem> _buildActionItems(BuildContext context) {
    final session = SessionManager().currentSession;
    final perms = SessionManager().permissions;
    final isSuper = SessionManager().isSuperAdmin;
    final role = session.role;
    final items = <_ActionRequiredItem>[];

    // 1. Verified Backend Circle Escalations (ONLY explicit status/stage flags — never invented % thresholds)
    if (isSuper || perms.canAccessTeamsTab) {
      final flaggedCircles = circles
          .where(DashboardPresenter.isBackendFlaggedCircle)
          .toList();

      if (flaggedCircles.isNotEmpty) {
        final single = flaggedCircles.length == 1 ? flaggedCircles.first : null;
        final names = flaggedCircles.take(2).map((c) => c.name).join(', ');
        final more = flaggedCircles.length > 2
            ? ' +${flaggedCircles.length - 2} more'
            : '';
        items.add(
          _ActionRequiredItem(
            title: single != null
                ? '${single.name} requires operational review'
                : '${flaggedCircles.length} Circles flagged for review',
            reason: single != null
                ? 'Circle status marked "${single.status.trim()}" in governance records.'
                : 'Flagged in Circle directory ($names$more).',
            ownerContext:
                single != null && single.directorName.trim().isNotEmpty
                ? 'Director: ${single.directorName.trim()}'
                : 'Scope: Circle Governance',
            badgeLabel: 'Escalation',
            tone: EnterpriseStatusTone.critical,
            ctaLabel: single != null ? 'Inspect' : 'Circles',
            icon: Icons.warning_amber_rounded,
            onAction: () {
              if (single != null) {
                Navigator.of(
                  context,
                ).pushNamed(AppRoutes.circleDetails, arguments: single);
              } else {
                onOpenTeamsTab();
              }
            },
          ),
        );
      }
    }

    // 2. Pending Governance & Peer Approvals
    final canReviewPending =
        isSuper ||
        (role.canModeratePendingRequests && perms.canReviewPendingPeers);
    if (canReviewPending && metrics.pendingRequestsCount > 0) {
      final count = metrics.pendingRequestsCount;
      items.add(
        _ActionRequiredItem(
          title:
              '$count ${count == 1 ? 'Pending Approval' : 'Pending Approvals'}',
          reason:
              'Admission, event pass, and Peer verification requests awaiting decision.',
          ownerContext: isSuper
              ? 'Scope: Global Approval Queue'
              : 'Assigned to: ${role.label}',
          badgeLabel: count >= 10 ? 'High Priority' : 'Pending',
          tone: count >= 25
              ? EnterpriseStatusTone.critical
              : EnterpriseStatusTone.pending,
          ctaLabel: 'Review',
          icon: Icons.fact_check_outlined,
          onAction: () => Navigator.of(context).pushNamed(
            AppRoutes.leaderActivities,
            arguments: {
              'type': 'pending-requests',
              'circleId': ?selectedCircle,
            },
          ),
        ),
      );
    }

    // 3. Verified Leadership Vacancies (Active Circles missing Circle Director or Chairs)
    final isExecutiveOversight =
        isSuper ||
        role == UserRole.countryDirector ||
        role == UserRole.districtExecDirector;
    if (isExecutiveOversight && circles.isNotEmpty) {
      final missingDirectors = circles
          .where(DashboardPresenter.hasDirectorVacancy)
          .toList();
      final missingChairs = circles
          .where(DashboardPresenter.hasChairVacancy)
          .toList();

      if (missingDirectors.isNotEmpty) {
        final firstCircle = missingDirectors.first;
        items.add(
          _ActionRequiredItem(
            title: missingDirectors.length == 1
                ? '${firstCircle.name} has no assigned Director'
                : '${missingDirectors.length} Active Circles missing Director',
            reason:
                'Assigning Circle Director leadership ensures accountable governance.',
            ownerContext: 'Scope: Leadership Staffing',
            badgeLabel: 'Vacancy',
            tone: EnterpriseStatusTone.pending,
            ctaLabel: missingDirectors.length == 1 ? 'Open' : 'Assign',
            icon: Icons.manage_accounts_outlined,
            onAction: () {
              if (missingDirectors.length == 1) {
                Navigator.of(
                  context,
                ).pushNamed(AppRoutes.circleDetails, arguments: firstCircle);
              } else {
                onOpenTeamsTab();
              }
            },
          ),
        );
      } else if (missingChairs.isNotEmpty) {
        final firstCircle = missingChairs.first;
        items.add(
          _ActionRequiredItem(
            title: missingChairs.length == 1
                ? '${firstCircle.name} has open Chair seats'
                : '${missingChairs.length} Active Circles missing Chairs',
            reason:
                'Appointing Circle Chairs strengthens Peer engagement and execution.',
            ownerContext: 'Scope: Circle Leadership',
            badgeLabel: 'Vacancy',
            tone: EnterpriseStatusTone.info,
            ctaLabel: missingChairs.length == 1 ? 'Open' : 'Assign',
            icon: Icons.groups_3_outlined,
            onAction: () {
              if (missingChairs.length == 1) {
                Navigator.of(
                  context,
                ).pushNamed(AppRoutes.circleDetails, arguments: firstCircle);
              } else {
                onOpenTeamsTab();
              }
            },
          ),
        );
      }
    }

    // 4. Manual Coin Claim Proofs (Roles authorized to issue/verify coins)
    if ((isSuper || perms.canIssueCoins) && metrics.coinClaims > 0) {
      items.add(
        _ActionRequiredItem(
          title:
              '${metrics.coinClaims} ${metrics.coinClaims == 1 ? 'Coin Claim' : 'Coin Claims'} awaiting audit',
          reason:
              'Peers submitted activity proof documents for reward ledger credit.',
          ownerContext: 'Scope: Coin Ledger Verification',
          badgeLabel: 'Verification',
          tone: EnterpriseStatusTone.pending,
          ctaLabel: 'Verify',
          icon: Icons.toll_rounded,
          onAction: () => Navigator.of(context).pushNamed(
            AppRoutes.leaderActivities,
            arguments: {'type': 'pending-requests', 'circleId': ?selectedCircle},
          ),
        ),
      );
    }

    // 5. Leadership Role & Partnership Applications (Executive roles)
    if (isExecutiveOversight &&
        (metrics.leadershipInterests > 0 || metrics.partnerInquiries > 0)) {
      final hasLeaderApps = metrics.leadershipInterests > 0;
      final totalLeads = metrics.leadershipInterests + metrics.partnerInquiries;
      items.add(
        _ActionRequiredItem(
          title:
              '$totalLeads Board & Partner ${totalLeads == 1 ? 'Application' : 'Applications'}',
          reason: hasLeaderApps && metrics.partnerInquiries > 0
              ? '${metrics.leadershipInterests} leadership and ${metrics.partnerInquiries} partnership submissions awaiting triage.'
              : (hasLeaderApps
                    ? 'Peers applied for executive stewardship positions.'
                    : 'Organizations submitted strategic partnership proposals.'),
          ownerContext: 'Scope: Executive Board Review',
          badgeLabel: 'Review',
          tone: EnterpriseStatusTone.info,
          ctaLabel: 'Evaluate',
          icon: Icons.workspace_premium_outlined,
          onAction: () => Navigator.of(context).pushNamed(
            AppRoutes.leaderActivities,
            arguments: {
              'type': hasLeaderApps
                  ? 'leadership-interests'
                  : 'partner-inquiries',
              'circleId': ?selectedCircle,
            },
          ),
        ),
      );
    }

    // 6. Open Peer Asks Awaiting Matching
    if (metrics.openAsks > 0) {
      items.add(
        _ActionRequiredItem(
          title:
              '${metrics.openAsks} Open ${metrics.openAsks == 1 ? 'Ask' : 'Asks'} awaiting fulfillment',
          reason:
              'Active collaboration, referral, and help requests open for Peer introductions.',
          ownerContext: role == UserRole.industryDirector
              ? 'Scope: Industry Collaboration'
              : 'Scope: Commercial Growth',
          badgeLabel: 'Active Flow',
          tone: EnterpriseStatusTone.info,
          ctaLabel: 'Open',
          icon: Icons.handshake_outlined,
          onAction: () => Navigator.of(context).pushNamed(
            AppRoutes.leaderActivities,
            arguments: {'type': 'open-asks', 'circleId': ?selectedCircle},
          ),
        ),
      );
    }

    return items;
  }

  void _showAllActionsSheet(
    BuildContext parentContext,
    List<_ActionRequiredItem> allItems,
  ) {
    final isDark = Theme.of(parentContext).brightness == Brightness.dark;
    final sheetBg = isDark
        ? AppColor.darkSurfaceElevated
        : AppColor.lightSurface;
    final textPrimary = isDark
        ? AppColor.darkTextPrimary
        : AppColor.lightTextPrimary;
    final textSecondary = isDark
        ? AppColor.darkTextSecondary
        : AppColor.lightTextSecondary;
    final textMuted = isDark
        ? AppColor.darkTextTertiary
        : AppColor.lightTextMuted;
    final dividerColor = isDark ? AppColor.darkDivider : AppColor.divider;

    final canReviewPending =
        SessionManager().isSuperAdmin ||
        (SessionManager().currentRole.canModeratePendingRequests &&
            SessionManager().permissions.canReviewPendingPeers);

    showModalBottomSheet<void>(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetCtx).height * 0.80,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColor.darkBorder
                          : AppColor.outlineStrong,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Action Required',
                              style: AppTypography.titleLarge.copyWith(
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${allItems.length} priority ${allItems.length == 1 ? 'item' : 'items'} in your active leadership scope',
                              style: AppTypography.bodySmall.copyWith(
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(sheetCtx).pop(),
                        icon: Icon(Icons.close_rounded, color: textSecondary),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, thickness: 1, color: dividerColor),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: allItems.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, thickness: 1, color: dividerColor),
                    itemBuilder: (ctx, i) {
                      final raw = allItems[i];
                      final wrapped = _ActionRequiredItem(
                        title: raw.title,
                        reason: raw.reason,
                        ownerContext: raw.ownerContext,
                        badgeLabel: raw.badgeLabel,
                        tone: raw.tone,
                        ctaLabel: raw.ctaLabel,
                        icon: raw.icon,
                        onAction: () {
                          Navigator.of(sheetCtx).pop();
                          raw.onAction();
                        },
                      );
                      return _buildActionRow(
                        item: wrapped,
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        textMuted: textMuted,
                        isFirst: false,
                        isLast: false,
                        expandedReason: true,
                      );
                    },
                  ),
                ),
                if (canReviewPending) ...[
                  Divider(height: 1, thickness: 1, color: dividerColor),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(sheetCtx).pop();
                        Navigator.of(parentContext).pushNamed(
                          AppRoutes.leaderActivities,
                          arguments: {
                            'type': 'pending-requests',
                            'circleId': ?selectedCircle,
                          },
                        );
                      },
                      icon: const Icon(Icons.fact_check_outlined, size: 17),
                      label: const Text('Open Full Approval Queue'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allItems = _buildActionItems(context);
    // Founder Review Point 3: Display at most the 3 most important actionable items initially.
    final visibleItems = allItems.take(3).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColor.darkTextPrimary
        : AppColor.lightTextPrimary;
    final textSecondary = isDark
        ? AppColor.darkTextSecondary
        : AppColor.lightTextSecondary;
    final textMuted = isDark
        ? AppColor.darkTextTertiary
        : AppColor.lightTextMuted;
    final dividerColor = isDark ? AppColor.darkDivider : AppColor.divider;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EnterpriseSectionHeader(
          title: 'Action Required',
          countLabel: allItems.isEmpty ? null : '${allItems.length}',
          actionLabel: allItems.isNotEmpty ? 'View All' : null,
          onActionTap: allItems.isNotEmpty
              ? () => _showAllActionsSheet(context, allItems)
              : null,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: AppSpacing.pageHorizontal,
          child: visibleItems.isEmpty
              ? EnterpriseSurfaceCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  backgroundColor: isDark
                      ? AppColor.darkSurface
                      : AppColor.completedBg,
                  borderColor: AppColor.completedBorder,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 18,
                        color: AppColor.completed,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All operational queues are clear',
                              style: AppTypography.titleSmall.copyWith(
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'No pending approvals or Circle escalations require intervention.',
                              style: AppTypography.bodySmall.copyWith(
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : EnterpriseSurfaceCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (int i = 0; i < visibleItems.length; i++) ...[
                        _buildActionRow(
                          item: visibleItems[i],
                          isDark: isDark,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          textMuted: textMuted,
                          isFirst: i == 0,
                          isLast: i == visibleItems.length - 1,
                        ),
                        if (i < visibleItems.length - 1)
                          Divider(height: 1, thickness: 1, color: dividerColor),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildActionRow({
    required _ActionRequiredItem item,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required Color textMuted,
    required bool isFirst,
    required bool isLast,
    bool expandedReason = false,
  }) {
    final accent = switch (item.tone) {
      EnterpriseStatusTone.critical => AppColor.critical,
      EnterpriseStatusTone.pending => AppColor.pending,
      EnterpriseStatusTone.completed ||
      EnterpriseStatusTone.active => AppColor.completed,
      _ => AppColor.primary,
    };

    final ctaBg = isDark
        ? AppColor.primary.withValues(alpha: 0.18)
        : AppColor.primaryContainer;
    final ctaFg = isDark ? const Color(0xFF93C5FD) : AppColor.primary;

    return Semantics(
      button: true,
      label:
          '${item.badgeLabel}: ${item.title}. ${item.reason}. Action: ${item.ctaLabel}',
      child: InkWell(
        onTap: item.onAction,
        borderRadius: BorderRadius.vertical(
          top: isFirst
              ? const Radius.circular(AppSpacing.radiusMd)
              : Radius.zero,
          bottom: isLast
              ? const Radius.circular(AppSpacing.radiusMd)
              : Radius.zero,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: expandedReason ? 11 : 7.5,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textScale = MediaQuery.textScalerOf(context).scale(1.0);
              final stackCtaBelow =
                  constraints.maxWidth < 300 || textScale > 1.28;

              final ctaChip = Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ctaBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        item.ctaLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelMedium.copyWith(
                          color: ctaFg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.arrow_forward_rounded, size: 13, color: ctaFg),
                  ],
                ),
              );

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    alignment: Alignment.center,
                    child: Icon(item.icon, size: 15, color: accent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (expandedReason || stackCtaBelow)
                          Wrap(
                            spacing: 6,
                            runSpacing: 3,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                item.title,
                                style: AppTypography.titleSmall.copyWith(
                                  color: textPrimary,
                                  fontSize: 13.5,
                                ),
                              ),
                              EnterpriseStatusBadge(
                                label: item.badgeLabel,
                                tone: item.tone,
                                compact: true,
                              ),
                            ],
                          )
                        else
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.titleSmall.copyWith(
                              color: textPrimary,
                              fontSize: 13,
                            ),
                          ),
                        const SizedBox(height: 1.5),
                        Text(
                          expandedReason
                              ? '${item.reason} · ${item.ownerContext}'
                              : item.reason,
                          maxLines: expandedReason ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                        if (stackCtaBelow) ...[
                          const SizedBox(height: 6),
                          ctaChip,
                        ],
                      ],
                    ),
                  ),
                  if (!stackCtaBelow) ...[const SizedBox(width: 8), ctaChip],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
