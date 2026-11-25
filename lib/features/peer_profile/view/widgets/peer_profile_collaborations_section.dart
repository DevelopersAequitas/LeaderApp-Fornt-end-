import 'package:flutter/material.dart';
import '../../../../core/routes/app_page_route.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../peers/model/peer_model.dart';
import '../../model/peer_profile_model.dart';
import '../../model/peer_profile_sections_model.dart';
import '../peer_business_deals_screen.dart';
import '../peer_business_referrals_screen.dart';
import '../peer_collaboration_screen.dart';
import '../peer_help_screen.dart';
import '../peer_introduced_by_screen.dart';
import '../peer_referral_screen.dart';

/// Section E: Collaborations, Referrals, Asks & Business Growth.
/// Strictly separates Closed/Logged Business Deals from Submitted Asks.
class PeerProfileCollaborationsSection extends StatelessWidget {
  final PeerModel peer;
  final PeerProfileDetailModel details;
  final PeerCollaborationGrowthModel collaborations;

  const PeerProfileCollaborationsSection({
    super.key,
    required this.peer,
    required this.details,
    required this.collaborations,
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

  EnterpriseStatusTone _toneForAsk(String status) {
    final s = status.toLowerCase().trim();
    if (s == 'closed' || s == 'completed' || s == 'fulfilled' || s == 'approved') {
      return EnterpriseStatusTone.completed;
    }
    if (s == 'open' || s == 'active' || s == 'in_progress') {
      return EnterpriseStatusTone.active;
    }
    if (s == 'rejected' || s == 'cancelled') {
      return EnterpriseStatusTone.rejected;
    }
    return EnterpriseStatusTone.pending;
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
    final dividerColor = isDark ? AppColor.darkBorder : AppColor.outline;

    final hasDeals = collaborations.dealsLoggedCount > 0 ||
        collaborations.recentDeals.isNotEmpty;
    final hasAsks = collaborations.totalAsksCount > 0 ||
        collaborations.recentAsks.isNotEmpty;
    final hasReferralsOrIntros = collaborations.referralsGivenCount > 0 ||
        collaborations.referralsReceivedCount > 0 ||
        collaborations.introducedPeersCount > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasDeals) ...[
            EnterpriseSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'BUSINESS DEALS (CLOSED VALUE)',
                          style: AppTypography.labelSmall
                              .copyWith(color: textMuted),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            AppPageRoute(
                              builder: (_) => PeerBusinessDealsScreen(
                                peer: peer,
                                details: details,
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 28),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'View All',
                          style: AppTypography.labelMedium
                              .copyWith(color: AppColor.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      _MetricPill(
                        label: 'Deals Given (${collaborations.dealsGivenCount})',
                        value: collaborations.dealsGivenValueFormatted.isNotEmpty
                            ? collaborations.dealsGivenValueFormatted
                            : '${collaborations.dealsGivenCount}',
                        color: AppColor.primary,
                      ),
                      _MetricPill(
                        label:
                            'Deals Received (${collaborations.dealsReceivedCount})',
                        value:
                            collaborations.dealsReceivedValueFormatted.isNotEmpty
                                ? collaborations.dealsReceivedValueFormatted
                                : '${collaborations.dealsReceivedCount}',
                        color: AppColor.success,
                      ),
                      if (collaborations.dealsTotalValueFormatted.isNotEmpty)
                        _MetricPill(
                          label:
                              'Total Logged (${collaborations.dealsLoggedCount})',
                          value: collaborations.dealsTotalValueFormatted,
                          color: textPrimary,
                        ),
                      if (collaborations.crossCircleDealsCount > 0)
                        _MetricPill(
                          label: 'Cross-Circle',
                          value: '${collaborations.crossCircleDealsCount}',
                          color: AppColor.info,
                        ),
                    ],
                  ),
                  if (collaborations.recentDeals.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Divider(height: 1, color: dividerColor),
                    const SizedBox(height: 10),
                    for (final deal in collaborations.recentDeals)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              deal.direction == 'received'
                                  ? Icons.call_received_rounded
                                  : Icons.call_made_rounded,
                              size: 16,
                              color: deal.direction == 'received'
                                  ? AppColor.success
                                  : AppColor.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${deal.direction == 'received' ? 'From' : 'To'} ${deal.counterpartName}',
                                    style: AppTypography.labelLarge
                                        .copyWith(color: textPrimary),
                                  ),
                                  if (deal.businessType.isNotEmpty ||
                                      deal.dealDate.isNotEmpty)
                                    Text(
                                      [
                                        if (deal.businessType.isNotEmpty)
                                          deal.businessType,
                                        if (deal.dealDate.isNotEmpty)
                                          _formatDate(deal.dealDate),
                                      ].join(' · '),
                                      style: AppTypography.bodySmall
                                          .copyWith(color: textSecondary),
                                    ),
                                  if (deal.notes.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        deal.notes,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.bodySmall
                                            .copyWith(color: textMuted),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (deal.amountFormatted.isNotEmpty)
                              Text(
                                deal.amountFormatted,
                                style: AppTypography.labelLarge.copyWith(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          if (hasReferralsOrIntros) ...[
            EnterpriseSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REFERRALS & PEER INTRODUCTIONS',
                    style: AppTypography.labelSmall.copyWith(color: textMuted),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _NavCountTile(
                          label: 'Referrals Given',
                          value: '${collaborations.referralsGivenCount}',
                          icon: Icons.outbound_outlined,
                          onTap: () => Navigator.of(context).push(
                            AppPageRoute(
                              builder: (_) => PeerBusinessReferralsScreen(
                                peer: peer,
                                details: details,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _NavCountTile(
                          label: 'Referrals Received',
                          value: '${collaborations.referralsReceivedCount}',
                          icon: Icons.inbox_outlined,
                          onTap: () => Navigator.of(context).push(
                            AppPageRoute(
                              builder: (_) => PeerBusinessReferralsScreen(
                                peer: peer,
                                details: details,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _NavCountTile(
                          label: 'Peers Introduced',
                          value: '${collaborations.introducedPeersCount}',
                          icon: Icons.person_add_alt_1_outlined,
                          onTap: () => Navigator.of(context).push(
                            AppPageRoute(
                              builder: (_) => PeerIntroducedByScreen(
                                peer: peer,
                                details: details,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          if (hasAsks) ...[
            EnterpriseSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BUSINESS ASKS & SUPPORT REQUESTS',
                    style: AppTypography.labelSmall.copyWith(color: textMuted),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _AskRouteButton(
                        icon: Icons.handshake_outlined,
                        label:
                            'Collaborations (${collaborations.collaborationAsksCount})',
                        onTap: () => Navigator.of(context).push(
                          AppPageRoute(
                            builder: (_) => PeerCollaborationScreen(
                              peer: peer,
                              details: details,
                            ),
                          ),
                        ),
                      ),
                      _AskRouteButton(
                        icon: Icons.swap_horiz_rounded,
                        label:
                            'Referral Asks (${collaborations.referralAsksCount})',
                        onTap: () => Navigator.of(context).push(
                          AppPageRoute(
                            builder: (_) => PeerReferralScreen(
                              peer: peer,
                              details: details,
                            ),
                          ),
                        ),
                      ),
                      _AskRouteButton(
                        icon: Icons.support_agent_outlined,
                        label: 'Need Help (${collaborations.helpAsksCount})',
                        onTap: () => Navigator.of(context).push(
                          AppPageRoute(
                            builder: (_) => PeerHelpScreen(
                              peer: peer,
                              details: details,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (collaborations.recentAsks.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Divider(height: 1, color: dividerColor),
                    const SizedBox(height: 10),
                    for (final ask in collaborations.recentAsks)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ask.title,
                                    style: AppTypography.labelLarge
                                        .copyWith(color: textPrimary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    [
                                      if (ask.flowName.isNotEmpty) ask.flowName,
                                      if (ask.createdAt != null &&
                                          ask.createdAt!.isNotEmpty)
                                        _formatDate(ask.createdAt!),
                                    ].join(' · '),
                                    style: AppTypography.bodySmall
                                        .copyWith(color: textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            if (ask.status.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              EnterpriseStatusBadge(
                                label: ask.status.toUpperCase(),
                                tone: _toneForAsk(ask.status),
                                compact: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],

          if (!hasDeals && !hasAsks && !hasReferralsOrIntros)
            EnterpriseSurfaceCard(
              child: Text(
                'No deals, asks, or referrals recorded for this Peer yet.',
                style: AppTypography.bodyMedium.copyWith(color: textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isDark
                  ? AppColor.darkTextSecondary
                  : AppColor.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.titleSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavCountTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _NavCountTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
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
            Icon(icon, size: 16, color: AppColor.primary),
            const SizedBox(height: 6),
            Text(
              value,
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
              maxLines: 2,
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
    );
  }
}

class _AskRouteButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AskRouteButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppColor.primary.withValues(alpha: isDark ? 0.16 : 0.08),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: AppColor.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColor.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isDark ? const Color(0xFF93C5FD) : AppColor.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: isDark ? const Color(0xFF93C5FD) : AppColor.primary,
            ),
          ],
        ),
      ),
    );
  }
}
