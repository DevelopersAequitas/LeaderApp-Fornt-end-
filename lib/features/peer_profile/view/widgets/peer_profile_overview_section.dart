import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_page_route.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_video_player.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../peers/model/peer_model.dart';
import '../../bloc/peer_profile_bloc.dart';
import '../../bloc/peer_profile_event.dart';
import '../../model/peer_profile_model.dart';
import '../../model/peer_profile_sections_model.dart';
import '../../presenter/peer_profile_presenter.dart';
import '../peer_business_deals_screen.dart';
import '../peer_business_referrals_screen.dart';
import '../peer_coins_screen.dart';
import '../peer_events_attendance_screen.dart';
import '../peer_introduced_by_screen.dart';
import '../peer_membership_screen.dart';
import '../peer_testimonials_screen.dart';
import 'peer_post_card.dart';

/// Founder-level Overview & Compliance section for Peer Profile.
class PeerProfileOverviewSection extends StatelessWidget {
  final PeerModel peer;
  final PeerProfileDetailModel details;
  final ValueChanged<PeerProfileSection>? onSelectSection;
  final VoidCallback? onRefreshProfile;

  const PeerProfileOverviewSection({
    super.key,
    required this.peer,
    required this.details,
    this.onSelectSection,
    this.onRefreshProfile,
  });

  String _formatCompactNumber(int value) {
    if (value >= 1000000) {
      final inM = value / 1000000.0;
      return '${inM.toStringAsFixed(inM.truncateToDouble() == inM ? 0 : 1)}M';
    }
    if (value >= 1000) {
      final inK = value / 1000.0;
      return '${inK.toStringAsFixed(inK.truncateToDouble() == inK ? 0 : 1)}k';
    }
    return '$value';
  }

  EnterpriseStatusTone _toneForStatus(String? status) {
    final s = (status ?? '').toLowerCase().trim();
    if (s == 'active' || s == 'approved' || s == 'current') {
      return EnterpriseStatusTone.active;
    }
    if (s == 'rejected' || s == 'expired' || s == 'suspended' || s == 'inactive') {
      return EnterpriseStatusTone.rejected;
    }
    if (s == 'pending' || s == 'expiring_soon' || s == 'at_risk') {
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

    final bio = (details.business?.shortBio.isNotEmpty == true
            ? details.business!.shortBio
            : (details.bio.isNotEmpty ? details.bio : (peer.bio ?? '')))
        .trim();
    final birthday = (details.birthday.isNotEmpty
            ? details.birthday
            : (peer.birthday ?? ''))
        .trim();
    final anniversary = (details.anniversary.isNotEmpty
            ? details.anniversary
            : (peer.anniversary ?? ''))
        .trim();
    final joinedDate = (details.organization?.joiningDate.isNotEmpty == true
            ? details.organization!.joiningDate
            : (details.joinedDate.isNotEmpty
                ? details.joinedDate
                : (peer.joinedDate ?? '')))
        .trim();

    final tags = details.business?.industryTags.isNotEmpty == true
        ? details.business!.industryTags
        : (details.tags.isNotEmpty
            ? details.tags
            : (peer.tags.trim().isNotEmpty
                ? peer.tags
                    .split('·')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList()
                : const <String>[]));

    final lifeImpact = details.lifeImpact;
    final pendingImpacts = lifeImpact?.pendingCount ?? 0;
    final showPendingImpactBanner =
        pendingImpacts > 0 && (lifeImpact?.canModerateImpacts == true);

    final compliance = details.compliance;
    final showCompliance = compliance != null && compliance.isVisible;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showPendingImpactBanner) ...[
            _PendingImpactCallout(
              pendingCount: pendingImpacts,
              onReviewTap: () {
                context
                    .read<PeerProfileBloc>()
                    .add(const FilterPeerProfileImpacts('pending'));
                onSelectSection?.call(PeerProfileSection.lifeImpact);
              },
            ),
            const SizedBox(height: 10),
          ],

          if (peer.introVideoUrl != null &&
              peer.introVideoUrl!.trim().isNotEmpty &&
              peer.introVideoUrl!.trim().startsWith('http')) ...[
            _buildIntroVideoCard(context, peer.introVideoUrl!.trim(), textMuted),
            const SizedBox(height: 10),
          ],

          _buildExecutiveMetricsGrid(context, textMuted),
          const SizedBox(height: 10),

          _buildQuickJumpCard(context, textMuted, isDark),

          if (bio.isNotEmpty || tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            EnterpriseSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXECUTIVE BIO & FOCUS AREAS',
                    style: AppTypography.labelSmall.copyWith(color: textMuted),
                  ),
                  if (bio.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ExpandableText(
                      text: bio,
                      maxLines: 3,
                      style: AppTypography.bodyMedium.copyWith(
                        color: textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColor.darkSurfaceElevated
                                    : AppColor.surfaceContainer,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusPill,
                                ),
                              ),
                              child: Text(
                                tag,
                                style: AppTypography.labelSmall.copyWith(
                                  color: textPrimary,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],

          if (birthday.isNotEmpty ||
              anniversary.isNotEmpty ||
              joinedDate.isNotEmpty) ...[
            const SizedBox(height: 10),
            EnterpriseSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MILESTONES & KEY DATES',
                    style: AppTypography.labelSmall.copyWith(color: textMuted),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      if (joinedDate.isNotEmpty)
                        _MilestoneChip(
                          icon: Icons.verified_user_outlined,
                          label: 'Joined',
                          value: joinedDate,
                        ),
                      if (birthday.isNotEmpty)
                        _MilestoneChip(
                          icon: Icons.cake_outlined,
                          label: 'Birthday',
                          value: birthday,
                        ),
                      if (anniversary.isNotEmpty)
                        _MilestoneChip(
                          icon: Icons.favorite_outline_rounded,
                          label: 'Anniversary',
                          value: anniversary,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          if (showCompliance) ...[
            const SizedBox(height: 10),
            _buildComplianceCard(
              context,
              compliance,
              textPrimary,
              textSecondary,
              textMuted,
            ),
          ],

          if (details.posts.isNotEmpty) ...[
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.feed_outlined,
                    size: 18,
                    color: AppColor.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Posts & Creatives (${details.posts.length})',
                    style: AppTypography.titleSmall.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            for (final post in details.posts)
              PeerPostCard(
                post: post,
                peerName: peer.name,
                peerAvatarUrl: peer.avatarUrl,
                peerDesignation: peer.designation,
                peerCompany: peer.company,
                peerCategory: (peer.level4Category != null &&
                        peer.level4Category!.isNotEmpty)
                    ? peer.level4Category!
                    : peer.circle,
                onDelete: () => _confirmDeletePost(context, post),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildIntroVideoCard(
    BuildContext context,
    String videoUrl,
    Color textMuted,
  ) {
    return EnterpriseSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INTRO VIDEO PITCH',
            style: AppTypography.labelSmall.copyWith(color: textMuted),
          ),
          const SizedBox(height: 10),
          InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  insetPadding: const EdgeInsets.all(16),
                  backgroundColor: Colors.black,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: AppVideoPlayer(
                      videoUrl: videoUrl,
                      autoPlay: true,
                    ),
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Container(
                height: 132,
                color: const Color(0xFF0F172A),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_circle_fill_rounded,
                        size: 44,
                        color: Colors.white,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Tap to play intro pitch',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveMetricsGrid(BuildContext context, Color textMuted) {
    final collab = details.collaborationsInfo;
    final perf = details.performance;
    final life = details.lifeImpact;

    final dealsDisplay = (collab?.dealsTotalValueFormatted.isNotEmpty == true)
        ? collab!.dealsTotalValueFormatted
        : (details.dealsClosed.trim().isNotEmpty ? details.dealsClosed : '—');
    final totalRef = collab != null
        ? collab.referralsGivenCount + collab.referralsReceivedCount
        : details.referralsGiven + details.referralsReceived;
    final lifeDisplay = life != null
        ? '${life.approvedCount}'
        : '${details.impactCount}';
    final p2pCount = perf?.p2pMeetingsCount ?? details.p2pSessions;
    final attDisplay = perf?.attendanceRatePercent != null
        ? '${perf!.attendanceRatePercent!.toStringAsFixed(perf.attendanceRatePercent!.truncateToDouble() == perf.attendanceRatePercent ? 0 : 1)}%'
        : (details.attendanceRate.trim().isNotEmpty
            ? details.attendanceRate
            : null);

    return EnterpriseSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EXECUTIVE OVERVIEW METRICS',
            style: AppTypography.labelSmall.copyWith(color: textMuted),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = (constraints.maxWidth - 8) / 2;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _OverviewKpiTile(
                    width: tileWidth,
                    icon: Icons.monetization_on_outlined,
                    label: 'Business Deals',
                    value: dealsDisplay,
                    onTap: () => Navigator.of(context).push(
                      AppPageRoute(
                        builder: (_) => PeerBusinessDealsScreen(
                          peer: peer,
                          details: details,
                        ),
                      ),
                    ),
                  ),
                  _OverviewKpiTile(
                    width: tileWidth,
                    icon: Icons.campaign_outlined,
                    label: 'Business Referrals',
                    value: '$totalRef',
                    onTap: () => Navigator.of(context).push(
                      AppPageRoute(
                        builder: (_) => PeerBusinessReferralsScreen(
                          peer: peer,
                          details: details,
                        ),
                      ),
                    ),
                  ),
                  _OverviewKpiTile(
                    width: tileWidth,
                    icon: Icons.volunteer_activism_outlined,
                    label: 'Approved Impacts',
                    value: lifeDisplay,
                    onTap: onSelectSection != null
                        ? () => onSelectSection!(PeerProfileSection.lifeImpact)
                        : null,
                  ),
                  _OverviewKpiTile(
                    width: tileWidth,
                    icon: Icons.stars_rounded,
                    label: 'Coins Earned',
                    value: _formatCompactNumber(details.coinsEarned),
                    onTap: () => Navigator.of(context).push(
                      AppPageRoute(
                        builder: (_) => PeerCoinsScreen(
                          peer: peer,
                          details: details,
                        ),
                      ),
                    ),
                  ),
                  _OverviewKpiTile(
                    width: tileWidth,
                    icon: Icons.people_outline_rounded,
                    label: 'P2P Meetings',
                    value: '$p2pCount',
                    onTap: onSelectSection != null
                        ? () => onSelectSection!(PeerProfileSection.performance)
                        : null,
                  ),
                  if (attDisplay != null)
                    _OverviewKpiTile(
                      width: tileWidth,
                      icon: Icons.event_available_outlined,
                      label: 'Circle Attendance',
                      value: attDisplay,
                      onTap: () => Navigator.of(context).push(
                        AppPageRoute(
                          builder: (_) =>
                              PeerEventsAttendanceScreen(peer: peer),
                        ),
                      ),
                    ),
                  _OverviewKpiTile(
                    width: tileWidth,
                    icon: Icons.format_quote_rounded,
                    label: 'Testimonials',
                    value: '${details.testimonials.length}',
                    onTap: () => Navigator.of(context).push(
                      AppPageRoute(
                        builder: (_) => PeerTestimonialsScreen(
                          peer: peer,
                          testimonials: details.testimonials,
                        ),
                      ),
                    ),
                  ),
                  _OverviewKpiTile(
                    width: tileWidth,
                    icon: Icons.person_add_alt_1_outlined,
                    label: 'Peers Introduced',
                    value: '${details.introducedPeersCount}',
                    onTap: () => Navigator.of(context).push(
                      AppPageRoute(
                        builder: (_) => PeerIntroducedByScreen(
                          peer: peer,
                          details: details,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickJumpCard(
    BuildContext context,
    Color textMuted,
    bool isDark,
  ) {
    final visibleSections =
        PeerProfilePresenter.resolveVisibleSections(peer, details)
            .where((s) => s != PeerProfileSection.overview)
            .toList();
    if (visibleSections.isEmpty || onSelectSection == null) {
      return const SizedBox.shrink();
    }

    return EnterpriseSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROFILE SECTIONS',
            style: AppTypography.labelSmall.copyWith(color: textMuted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: visibleSections
                .map(
                  (section) => InkWell(
                    onTap: () => onSelectSection!(section),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.primary
                            .withValues(alpha: isDark ? 0.16 : 0.07),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                        border: Border.all(
                          color: AppColor.primary.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            section.icon,
                            size: 15,
                            color: AppColor.primary,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              section.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelMedium.copyWith(
                                color: isDark
                                    ? const Color(0xFF93C5FD)
                                    : AppColor.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceCard(
    BuildContext context,
    PeerComplianceInfoModel compliance,
    Color textPrimary,
    Color textSecondary,
    Color textMuted,
  ) {
    return EnterpriseSurfaceCard(
      onTap: () {
        Navigator.of(context).push(
          AppPageRoute(
            builder: (_) => PeerMembershipScreen(
              peer: peer,
              details: details,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_user_outlined,
                size: 16,
                color: AppColor.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'ACCOUNT & COMPLIANCE',
                  style: AppTypography.labelSmall.copyWith(color: textMuted),
                ),
              ),
              EnterpriseStatusBadge(
                label: (compliance.renewalStatus?.isNotEmpty == true
                        ? compliance.renewalStatus!
                        : (compliance.accountStatus.isNotEmpty
                            ? compliance.accountStatus
                            : 'Active'))
                    .toUpperCase(),
                tone: _toneForStatus(
                  compliance.renewalStatus ?? compliance.accountStatus,
                ),
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (compliance.approvalStatus != null &&
              compliance.approvalStatus!.isNotEmpty)
            _ComplianceRow('Approval Status', compliance.approvalStatus!),
          if (compliance.membershipStatus != null &&
              compliance.membershipStatus!.isNotEmpty)
            _ComplianceRow('Circle Status', compliance.membershipStatus!),
          if (compliance.planName != null && compliance.planName!.isNotEmpty)
            _ComplianceRow(
              'Active Plan',
              compliance.planPrice != null && compliance.planPrice!.isNotEmpty
                  ? '${compliance.planName} (${compliance.planPrice})'
                  : compliance.planName!,
            ),
          if (compliance.expiresAt != null && compliance.expiresAt!.isNotEmpty)
            _ComplianceRow('Valid Until', compliance.expiresAt!),
          if (compliance.daysRemaining != null)
            _ComplianceRow(
              'Days Remaining',
              '${compliance.daysRemaining} days',
            ),
          if (compliance.adminRemarks != null &&
              compliance.adminRemarks!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Admin Remarks: ${compliance.adminRemarks!}',
              style: AppTypography.bodySmall.copyWith(color: textSecondary),
            ),
          ],
          if (compliance.pendingActions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: compliance.pendingActions
                  .map(
                    (act) => EnterpriseStatusBadge(
                      label: act,
                      tone: EnterpriseStatusTone.pending,
                      compact: true,
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'View Subscriptions & Renewal History',
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
    );
  }

  void _confirmDeletePost(BuildContext context, PeerPostModel post) {
    final peerId = peer.id.trim();
    if (peerId.isEmpty || post.id.isEmpty) return;

    final isCreative = post.isCreative;
    final itemType = isCreative ? 'creative' : 'post';

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete ${isCreative ? 'Creative' : 'Post'}'),
        content: Text(
          'Are you sure you want to delete this $itemType? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              final bloc = context.read<PeerProfileBloc>();
              if (isCreative) {
                bloc.add(
                  DeletePeerCreative(memberId: peerId, creativeId: post.id),
                );
              } else {
                bloc.add(DeletePeerPost(memberId: peerId, postId: post.id));
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _PendingImpactCallout extends StatelessWidget {
  final int pendingCount;
  final VoidCallback onReviewTap;

  const _PendingImpactCallout({
    required this.pendingCount,
    required this.onReviewTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return EnterpriseSurfaceCard(
      backgroundColor:
          AppColor.warning.withValues(alpha: isDark ? 0.14 : 0.08),
      borderColor: AppColor.warning.withValues(alpha: 0.4),
      onTap: onReviewTap,
      child: Row(
        children: [
          const Icon(
            Icons.pending_actions_rounded,
            color: AppColor.warning,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$pendingCount Pending Life Impact Submission${pendingCount == 1 ? '' : 's'}',
                  style: AppTypography.labelLarge.copyWith(
                    color: isDark
                        ? AppColor.darkTextPrimary
                        : AppColor.lightTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Eligible for verification review',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColor.darkTextSecondary
                        : AppColor.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Review',
            style: AppTypography.labelLarge.copyWith(
              color: AppColor.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColor.primary,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _OverviewKpiTile extends StatelessWidget {
  final double width;
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _OverviewKpiTile({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? AppColor.darkSurfaceElevated : AppColor.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: isDark ? AppColor.darkBorder : AppColor.outline,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 15, color: AppColor.primary),
                  const Spacer(),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 15,
                      color: isDark
                          ? AppColor.darkTextTertiary
                          : AppColor.lightTextMuted,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleMedium.copyWith(
                  color: isDark
                      ? AppColor.darkTextPrimary
                      : AppColor.lightTextPrimary,
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
        ),
      ),
    );
  }
}

class _MilestoneChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MilestoneChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? AppColor.darkSurfaceElevated : AppColor.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: isDark ? AppColor.darkBorder : AppColor.outline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColor.primary),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: AppTypography.labelSmall.copyWith(
              color: isDark
                  ? AppColor.darkTextSecondary
                  : AppColor.lightTextSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelMedium.copyWith(
                color: isDark
                    ? AppColor.darkTextPrimary
                    : AppColor.lightTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplianceRow extends StatelessWidget {
  final String label;
  final String value;

  const _ComplianceRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColor.darkTextTertiary
                    : AppColor.lightTextMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColor.darkTextPrimary
                    : AppColor.lightTextPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
