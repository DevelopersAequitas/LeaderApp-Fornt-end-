import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../peers/model/peer_model.dart';
import '../../model/peer_profile_model.dart';
import '../../model/peer_profile_sections_model.dart';

/// Section I: Chronological Activity Timeline for Peer Profile.
class PeerProfileActivitySection extends StatelessWidget {
  final PeerModel? peer;
  final PeerProfileDetailModel? details;
  final List<PeerTimelineEventModel> timeline;
  final List<PeerActivityModel> activities;
  final VoidCallback? onRefreshProfile;

  const PeerProfileActivitySection({
    super.key,
    this.peer,
    this.details,
    this.timeline = const [],
    required this.activities,
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

  IconData _iconForEvent(String type) {
    final t = type.toLowerCase();
    if (t.contains('impact')) return Icons.volunteer_activism_outlined;
    if (t.contains('deal')) return Icons.monetization_on_outlined;
    if (t.contains('referral')) return Icons.swap_horiz_rounded;
    if (t.contains('p2p')) return Icons.people_outline_rounded;
    if (t.contains('report')) return Icons.assignment_turned_in_outlined;
    if (t.contains('event')) return Icons.event_available_outlined;
    if (t.contains('ask') || t.contains('collab')) {
      return Icons.handshake_outlined;
    }
    return Icons.timeline_rounded;
  }

  EnterpriseStatusTone _toneForStatus(String status) {
    final s = status.toLowerCase().trim();
    if (s == 'approved' || s == 'completed' || s == 'closed' || s == 'active') {
      return EnterpriseStatusTone.active;
    }
    if (s == 'rejected' || s == 'absent' || s == 'cancelled') {
      return EnterpriseStatusTone.rejected;
    }
    if (s == 'pending' || s == 'late') {
      return EnterpriseStatusTone.pending;
    }
    return EnterpriseStatusTone.info;
  }

  Future<void> _handleTap(
    BuildContext context,
    PeerTimelineEventModel event,
  ) async {
    final refType = (event.referenceType ?? '').toLowerCase();
    final refId = (event.referenceId ?? '').trim();
    if (refType == 'life_impact' && refId.isNotEmpty) {
      final result = await Navigator.of(context).pushNamed(
        AppRoutes.lifeImpactDetail,
        arguments: {'id': refId},
      );
      if (result == true) {
        onRefreshProfile?.call();
      }
      return;
    }
    if ((refType == 'collaboration' || refType == 'ask') && peer != null) {
      await Navigator.of(context).pushNamed(
        AppRoutes.peerCollaboration,
        arguments: {
          'peer': peer,
          'details': details,
          if (refId.isNotEmpty) 'ask_id': refId,
        },
      );
      return;
    }
    if (refType == 'business_deal' && refId.isNotEmpty) {
      await Navigator.of(context).pushNamed(
        AppRoutes.businessDeals,
        arguments: {'deal_id': refId},
      );
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
    final dividerColor = isDark ? AppColor.darkBorder : AppColor.outline;

    if (timeline.isEmpty && activities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
        child: EnterpriseSurfaceCard(
          child: Text(
            'No recent timeline activity recorded.',
            style: AppTypography.bodyMedium.copyWith(color: textSecondary),
          ),
        ),
      );
    }

    if (timeline.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
        child: EnterpriseSurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Text(
                  'CHRONOLOGICAL ACTIVITY TIMELINE (${timeline.length})',
                  style: AppTypography.labelSmall.copyWith(color: textMuted),
                ),
              ),
              Divider(height: 1, color: dividerColor),
              for (var i = 0; i < timeline.length; i++) ...[
                if (i > 0) Divider(height: 1, color: dividerColor),
                InkWell(
                  onTap: (timeline[i].referenceType != null &&
                          timeline[i].referenceId != null)
                      ? () => _handleTap(context, timeline[i])
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColor.primary.withValues(alpha: 0.10),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Icon(
                            _iconForEvent(timeline[i].eventType),
                            size: 18,
                            color: AppColor.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                timeline[i].title,
                                style: AppTypography.labelLarge
                                    .copyWith(color: textPrimary),
                              ),
                              if (timeline[i].subtitle.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                ExpandableText(
                                  text: timeline[i].subtitle,
                                  maxLines: 2,
                                  style: AppTypography.bodySmall
                                      .copyWith(color: textSecondary),
                                ),
                              ],
                              if (timeline[i].date.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(timeline[i].date),
                                  style: AppTypography.labelSmall
                                      .copyWith(color: textMuted),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (timeline[i].status.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          EnterpriseStatusBadge(
                            label: timeline[i].status.toUpperCase(),
                            tone: _toneForStatus(timeline[i].status),
                            compact: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
      child: EnterpriseSurfaceCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Text(
                'RECENT ACTIVITY (${activities.length})',
                style: AppTypography.labelSmall.copyWith(color: textMuted),
              ),
            ),
            Divider(height: 1, color: dividerColor),
            for (var i = 0; i < activities.length; i++) ...[
              if (i > 0) Divider(height: 1, color: dividerColor),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColor.primary.withValues(alpha: 0.10),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Icon(
                        _iconForEvent(activities[i].iconType),
                        size: 18,
                        color: AppColor.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activities[i].title,
                            style: AppTypography.labelLarge
                                .copyWith(color: textPrimary),
                          ),
                          if (activities[i].subtitle.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: ExpandableText(
                                text: activities[i].subtitle,
                                maxLines: 2,
                                style: AppTypography.bodySmall
                                    .copyWith(color: textSecondary),
                              ),
                            ),
                          if (activities[i].time.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                activities[i].time,
                                style: AppTypography.labelSmall
                                    .copyWith(color: textMuted),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
