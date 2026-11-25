import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/dashboard_metrics_model.dart';
import 'dashboard_hero_card.dart';

class _DomainStreamItem {
  final String label;
  final String description;
  final int? count;
  final String? badgeOverride;
  final IconData icon;
  final VoidCallback onTap;

  const _DomainStreamItem({
    required this.label,
    required this.description,
    this.count,
    this.badgeOverride,
    required this.icon,
    required this.onTap,
  });
}

class _OperationalDomainConfig {
  final String id;
  final String title;
  final String subtitle;
  final String summaryLabel;
  final IconData icon;
  final Color accent;
  final List<_DomainStreamItem> items;

  const _OperationalDomainConfig({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.summaryLabel,
    required this.icon,
    required this.accent,
    required this.items,
  });
}

/// Executive 4-Domain Information Architecture Hub (`Activity`, `Asks`, `Community`, `Leadership`).
///
/// Replaces the 32-counter consumer visual grid on the main Dashboard with four
/// clean domain cards while retaining 100% of the underlying 32 drill-down
/// streams via [DashboardDomainDrilldownSheet].
class DashboardDomainsSection extends StatelessWidget {
  final DashboardMetricsModel metrics;
  final String? selectedCircle;
  final VoidCallback onPeersTap;

  const DashboardDomainsSection({
    super.key,
    required this.metrics,
    required this.selectedCircle,
    required this.onPeersTap,
  });

  static void _openLeaderActivity(
    BuildContext context,
    String type,
    String? selectedCircle,
  ) {
    Navigator.of(context).pushNamed(
      AppRoutes.leaderActivities,
      arguments: {
        'type': type,
        'circleId': ?selectedCircle,
      },
    );
  }

  static List<_OperationalDomainConfig> _buildDomains({
    required BuildContext context,
    required DashboardMetricsModel m,
    required String? selectedCircle,
    required VoidCallback onPeersTap,
  }) {
    final isSuper = SessionManager().isSuperAdmin;
    final perms = SessionManager().permissions;
    final role = SessionManager().currentRole;
    final canAccessPeers = isSuper || perms.canAccessPeersTab;
    final canReviewPending = isSuper ||
        (role.canModeratePendingRequests && perms.canReviewPendingPeers);

    final entreCerts = m.entrepreneurCertifications > 0
        ? m.entrepreneurCertifications
        : m.certifications;

    return [
      // 1. Activity (8 streams)
      _OperationalDomainConfig(
        id: 'activity',
        title: 'Activity',
        subtitle: 'P2P sessions, referrals & Peer engagement',
        summaryLabel:
            '${DashboardHeroCard.formatReadableCount(m.p2pMeetings)} P2Ps · ${DashboardHeroCard.formatReadableCount(m.referrals)} Referrals',
        icon: Icons.bolt_rounded,
        accent: AppColor.primary,
        items: [
          _DomainStreamItem(
            label: 'Peers Directory',
            description: 'Active Peers registered in scope',
            count: m.totalPeers,
            icon: Icons.groups_2_outlined,
            onTap: canAccessPeers
                ? onPeersTap
                : () => _openLeaderActivity(context, 'peers', selectedCircle),
          ),
          _DomainStreamItem(
            label: 'P2P Meetings',
            description: '1-on-1 discovery & business sessions',
            count: m.p2pMeetings,
            icon: Icons.people_outline_rounded,
            onTap: () =>
                _openLeaderActivity(context, 'p2p-meetings', selectedCircle),
          ),
          _DomainStreamItem(
            label: 'Referrals',
            description: 'Qualified business introductions passed',
            count: m.referrals,
            icon: Icons.swap_horiz_rounded,
            onTap: () =>
                _openLeaderActivity(context, 'referrals', selectedCircle),
          ),
          _DomainStreamItem(
            label: 'Endorsements',
            description: 'Verified Peer testimonials & reviews',
            count: m.testimonials,
            icon: Icons.verified_outlined,
            onTap: () =>
                _openLeaderActivity(context, 'testimonials', selectedCircle),
          ),
          _DomainStreamItem(
            label: 'Visitor Registrations',
            description: 'Prospective guests invited to conclaves',
            count: m.visitorRegistrations,
            icon: Icons.person_add_alt_1_outlined,
            onTap: () => _openLeaderActivity(
              context,
              'visitor-registrations',
              selectedCircle,
            ),
          ),
          _DomainStreamItem(
            label: 'Peer Recommendations',
            description: 'Candidates nominated by existing Peers',
            count: m.peerRecommendations,
            icon: Icons.thumb_up_alt_outlined,
            onTap: () => _openLeaderActivity(
              context,
              'peer-recommendations',
              selectedCircle,
            ),
          ),
          _DomainStreamItem(
            label: 'Peers Introduced',
            description: 'New Peers successfully inducted',
            count: m.introducedPeers,
            icon: Icons.how_to_reg_outlined,
            onTap: () => _openLeaderActivity(
              context,
              'introduced-peers',
              selectedCircle,
            ),
          ),
          if (canReviewPending)
            _DomainStreamItem(
              label: 'Pending Approvals',
              description: 'Governance & admission requests awaiting action',
              count: m.pendingRequestsCount,
              icon: Icons.fact_check_outlined,
              onTap: () => _openLeaderActivity(
                context,
                'pending-requests',
                selectedCircle,
              ),
            )
          else
            _DomainStreamItem(
              label: 'Business Deals',
              description: 'Closed commercial transactions recorded',
              count: m.dealsCount,
              icon: Icons.handshake_outlined,
              onTap: () => _openLeaderActivity(
                context,
                'business-deals',
                selectedCircle,
              ),
            ),
        ],
      ),

      // 2. Asks (8 streams)
      _OperationalDomainConfig(
        id: 'asks',
        title: 'Asks',
        subtitle: 'Collaboration, referral & commercial asks',
        summaryLabel:
            '${DashboardHeroCard.formatReadableCount(m.openAsks)} Open · ${DashboardHeroCard.formatReadableCount(m.fulfilledAsks)} Fulfilled',
        icon: Icons.handshake_outlined,
        accent: AppColor.tertiary,
        items: [
          _DomainStreamItem(
            label: 'Collaboration Asks',
            description: 'Joint ventures & strategic partnership requests',
            count: m.collaborationAsks,
            icon: Icons.hub_outlined,
            onTap: () => _openLeaderActivity(
              context,
              'collaboration-asks',
              selectedCircle,
            ),
          ),
          _DomainStreamItem(
            label: 'Referral Asks',
            description: 'Warm decision-maker introduction requests',
            count: m.referralAsks,
            icon: Icons.share_arrival_time_outlined,
            onTap: () =>
                _openLeaderActivity(context, 'referral-asks', selectedCircle),
          ),
          _DomainStreamItem(
            label: 'Help Asks',
            description: 'Advisory & operational problem-solving requests',
            count: m.helpAsks,
            icon: Icons.support_agent_outlined,
            onTap: () =>
                _openLeaderActivity(context, 'help-asks', selectedCircle),
          ),
          _DomainStreamItem(
            label: 'Requirements',
            description: 'Direct procurement & vendor opportunities',
            count: m.requirements,
            icon: Icons.assignment_outlined,
            onTap: () =>
                _openLeaderActivity(context, 'requirements', selectedCircle),
          ),
          _DomainStreamItem(
            label: 'All Asks',
            description: 'Complete cross-category Ask registry',
            count: m.allAsks,
            icon: Icons.dynamic_feed_rounded,
            onTap: () =>
                _openLeaderActivity(context, 'all-asks', selectedCircle),
          ),
          _DomainStreamItem(
            label: 'Open Asks',
            description: 'Unmatched requests awaiting Peer connections',
            count: m.openAsks,
            icon: Icons.pending_actions_outlined,
            onTap: () =>
                _openLeaderActivity(context, 'open-asks', selectedCircle),
          ),
          _DomainStreamItem(
            label: 'In Progress Asks',
            description: 'Active discussions underway between Peers',
            count: m.inProgressAsks,
            icon: Icons.sync_rounded,
            onTap: () => _openLeaderActivity(
              context,
              'in-progress-asks',
              selectedCircle,
            ),
          ),
          _DomainStreamItem(
            label: 'Fulfilled Asks',
            description: 'Completed & resolved Peer Ask outcomes',
            count: m.fulfilledAsks,
            icon: Icons.task_alt_rounded,
            onTap: () =>
                _openLeaderActivity(context, 'fulfilled-asks', selectedCircle),
          ),
        ],
      ),

      // 3. Community (8 streams — Coins, Claims, Content, Certifications, Circulars)
      _OperationalDomainConfig(
        id: 'community',
        title: 'Community',
        subtitle: 'Coins, claims, stories, credentials & circulars',
        summaryLabel:
            '${DashboardHeroCard.formatReadableCount(m.coins)} Coins · ${DashboardHeroCard.formatReadableCount(m.circulars)} Notices',
        icon: Icons.stars_outlined,
        accent: const Color(0xFF4F46E5),
        items: [
          _DomainStreamItem(
            label: 'Total Coins',
            description: 'Ecosystem reward coin ledger (non-monetary)',
            count: m.coins,
            icon: Icons.stars_outlined,
            onTap: () => _openLeaderActivity(context, 'coins', selectedCircle),
          ),
          _DomainStreamItem(
            label: 'Coin Claims',
            description: 'Submitted reward claim proofs for verification',
            count: m.coinClaims,
            icon: Icons.toll_rounded,
            onTap: () =>
                _openLeaderActivity(context, 'coin-claims', selectedCircle),
          ),
          _DomainStreamItem(
            label: 'Timeline Posts',
            description: 'Updates & announcements shared by Peers',
            count: m.posts,
            icon: Icons.article_outlined,
            onTap: () => _openLeaderActivity(context, 'posts', selectedCircle),
          ),
          _DomainStreamItem(
            label: 'Activity Creatives',
            description: 'Published visual banners & recognition cards',
            count: m.creatives,
            icon: Icons.palette_outlined,
            onTap: () =>
                _openLeaderActivity(context, 'creatives', selectedCircle),
          ),
          _DomainStreamItem(
            label: 'Business Stories',
            description: 'Featured founder & enterprise growth stories',
            count: m.stories,
            icon: Icons.auto_stories_outlined,
            onTap: () =>
                _openLeaderActivity(context, 'stories', selectedCircle),
          ),
          _DomainStreamItem(
            label: 'Entrepreneur Certifications',
            description: 'Enterprise accreditation filings',
            count: entreCerts,
            icon: Icons.military_tech_outlined,
            onTap: () => _openLeaderActivity(
              context,
              'entrepreneur-certifications',
              selectedCircle,
            ),
          ),
          _DomainStreamItem(
            label: 'Leadership Certifications',
            description: 'Completed leadership governance credentials',
            count: m.leadershipCertifications,
            icon: Icons.workspace_premium_outlined,
            onTap: () => _openLeaderActivity(
              context,
              'leadership-certifications',
              selectedCircle,
            ),
          ),
          _DomainStreamItem(
            label: 'Official Circulars',
            description: 'Formal leadership directives & policy notices',
            count: m.circulars,
            icon: Icons.campaign_outlined,
            onTap: () =>
                _openLeaderActivity(context, 'circulars', selectedCircle),
          ),
        ],
      ),

      // 4. Leadership (8 streams — Events, Applications, Partners & Leaderboards)
      _OperationalDomainConfig(
        id: 'leadership',
        title: 'Leadership',
        subtitle: 'Events, board applications & leaderboards',
        summaryLabel:
            '${DashboardHeroCard.formatReadableCount(m.eventRegistrations)} Regs · ${DashboardHeroCard.formatReadableCount(m.leadershipInterests + m.partnerInquiries)} Inquiries',
        icon: Icons.workspace_premium_outlined,
        accent: AppColor.success,
        items: [
          _DomainStreamItem(
            label: 'Event Registrations',
            description: 'Confirmed Peer & guest event bookings',
            count: m.eventRegistrations,
            icon: Icons.event_available_outlined,
            onTap: () => _openLeaderActivity(
              context,
              'event-registrations',
              selectedCircle,
            ),
          ),
          _DomainStreamItem(
            label: 'Event Attendance',
            description: 'Verified check-ins across conclaves & summits',
            count: m.eventAttendance,
            icon: Icons.fact_check_outlined,
            onTap: () => _openLeaderActivity(
              context,
              'event-attendance',
              selectedCircle,
            ),
          ),
          _DomainStreamItem(
            label: 'Leadership Interest',
            description: 'Candidates applying for Circle & regional roles',
            count: m.leadershipInterests,
            icon: Icons.badge_outlined,
            onTap: () => _openLeaderActivity(
              context,
              'leadership-interests',
              selectedCircle,
            ),
          ),
          _DomainStreamItem(
            label: 'Mentor Applications',
            description: 'Experienced founders offering advisory mentorship',
            count: m.mentorApplications,
            icon: Icons.school_outlined,
            onTap: () => _openLeaderActivity(
              context,
              'mentor-applications',
              selectedCircle,
            ),
          ),
          _DomainStreamItem(
            label: 'Speaker Applications',
            description: 'Keynote & session speaker submissions',
            count: m.speakerApplications,
            icon: Icons.record_voice_over_outlined,
            onTap: () => _openLeaderActivity(
              context,
              'speaker-applications',
              selectedCircle,
            ),
          ),
          _DomainStreamItem(
            label: 'Partner Inquiries',
            description: 'Institutional & strategic alliance proposals',
            count: m.partnerInquiries,
            icon: Icons.business_outlined,
            onTap: () => _openLeaderActivity(
              context,
              'partner-inquiries',
              selectedCircle,
            ),
          ),
          _DomainStreamItem(
            label: 'Top Contributors',
            description: 'Ranked Peers by verified ecosystem participation',
            badgeOverride: 'Ranking',
            icon: Icons.leaderboard_outlined,
            onTap: () => _openLeaderActivity(
              context,
              'top-contributors',
              selectedCircle,
            ),
          ),
          _DomainStreamItem(
            label: 'Highest Givers',
            description: 'Ranked Peers by referrals & Peer support',
            badgeOverride: 'Ranking',
            icon: Icons.volunteer_activism_outlined,
            onTap: () =>
                _openLeaderActivity(context, 'highest-givers', selectedCircle),
          ),
        ],
      ),
    ];
  }

  void _openDomainSheet(BuildContext context, int initialTab) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColor.darkSurfaceElevated
          : AppColor.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (sheetCtx) => _DashboardDomainDrilldownSheet(
        parentContext: context,
        metrics: metrics,
        selectedCircle: selectedCircle,
        onPeersTap: onPeersTap,
        initialTab: initialTab,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final domains = _buildDomains(
      context: context,
      m: metrics,
      selectedCircle: selectedCircle,
      onPeersTap: onPeersTap,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final textSecondary =
        isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EnterpriseSectionHeader(
          title: 'Operational Domains',
          actionLabel: 'Explore All',
          onActionTap: () => _openDomainSheet(context, 0),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: AppSpacing.pageHorizontal,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 680 ? 4 : 2;
              final rows = <Widget>[];
              for (int i = 0; i < domains.length; i += columns) {
                if (rows.isNotEmpty) rows.add(const SizedBox(height: 8));
                rows.add(
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int c = 0; c < columns; c++) ...[
                          if (c > 0) const SizedBox(width: 8),
                          Expanded(
                            child: (i + c < domains.length)
                                ? _buildDomainCard(
                                    domain: domains[i + c],
                                    index: i + c,
                                    context: context,
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: rows,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDomainCard({
    required _OperationalDomainConfig domain,
    required int index,
    required BuildContext context,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Semantics(
      button: true,
      label: '${domain.title} domain: ${domain.summaryLabel}. Tap to explore.',
      child: EnterpriseSurfaceCard(
        padding: const EdgeInsets.all(12),
        onTap: () => _openDomainSheet(context, index),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: domain.accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  alignment: Alignment.center,
                  child: Icon(domain.icon, size: 16, color: domain.accent),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    domain.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleSmall.copyWith(
                      color: textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 17,
                  color: textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              domain.summaryLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelMedium.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              domain.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 11,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardDomainDrilldownSheet extends StatefulWidget {
  final BuildContext parentContext;
  final DashboardMetricsModel metrics;
  final String? selectedCircle;
  final VoidCallback onPeersTap;
  final int initialTab;

  const _DashboardDomainDrilldownSheet({
    required this.parentContext,
    required this.metrics,
    required this.selectedCircle,
    required this.onPeersTap,
    required this.initialTab,
  });

  @override
  State<_DashboardDomainDrilldownSheet> createState() =>
      _DashboardDomainDrilldownSheetState();
}

class _DashboardDomainDrilldownSheetState
    extends State<_DashboardDomainDrilldownSheet> {
  late int _activeTab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final domains = DashboardDomainsSection._buildDomains(
      context: widget.parentContext,
      m: widget.metrics,
      selectedCircle: widget.selectedCircle,
      onPeersTap: widget.onPeersTap,
    );
    final safeIdx = _activeTab.clamp(0, domains.length - 1);
    final domain = domains[safeIdx];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final textSecondary =
        isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;
    final dividerColor = isDark ? AppColor.darkDivider : AppColor.divider;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.84,
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
                  color: isDark ? AppColor.darkBorder : AppColor.outlineStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${domain.title} Streams',
                          style: AppTypography.titleLarge.copyWith(
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          domain.subtitle,
                          style: AppTypography.bodySmall.copyWith(
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: textSecondary),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColor.darkSurfaceSubtle
                      : AppColor.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  children: [
                    for (int i = 0; i < domains.length; i++)
                      Expanded(
                        child: _buildTabPill(
                          label: domains[i].title,
                          isSelected: i == safeIdx,
                          isDark: isDark,
                          onTap: () {
                            if (_activeTab != i) {
                              HapticFeedback.selectionClick();
                              setState(() => _activeTab = i);
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, thickness: 1, color: dividerColor),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: domain.items.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, thickness: 1, color: dividerColor),
                itemBuilder: (ctx, i) {
                  final item = domain.items[i];
                  final badgeText = item.badgeOverride ??
                      DashboardHeroCard.formatReadableCount(item.count ?? 0);
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      item.onTap();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 11,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: domain.accent.withValues(alpha: 0.10),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              item.icon,
                              size: 17,
                              color: domain.accent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.titleSmall.copyWith(
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColor.darkSurfaceSubtle
                                  : AppColor.surfaceContainerLow,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusXs),
                              border: Border.all(
                                color: isDark
                                    ? AppColor.darkBorder
                                    : AppColor.outline,
                              ),
                            ),
                            child: Text(
                              badgeText,
                              style: AppTypography.metricSmall.copyWith(
                                color: textPrimary,
                                fontSize:
                                    item.badgeOverride != null ? 11.5 : 13.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: textSecondary,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill({
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

    return InkWell(
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
    );
  }
}
