import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/peer_profile_sections_model.dart';

/// Section D: Leadership & Organizational History.
/// Clearly distinguishes Current Assignments from Historical Assignments and
/// never presents ordinary circle membership as a leadership role.
class PeerProfileLeadershipSection extends StatelessWidget {
  final PeerLeadershipHistoryModel leadership;

  const PeerProfileLeadershipSection({
    super.key,
    required this.leadership,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final textSecondary =
        isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;
    final textMuted =
        isDark ? AppColor.darkTextTertiary : AppColor.lightTextMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (leadership.currentPositions.isNotEmpty) ...[
            EnterpriseSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT LEADERSHIP ASSIGNMENTS',
                    style: AppTypography.labelSmall.copyWith(color: textMuted),
                  ),
                  const SizedBox(height: 10),
                  for (final pos in leadership.currentPositions)
                    _PositionRow(
                      position: pos,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          if (leadership.historicalPositions.isNotEmpty) ...[
            EnterpriseSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HISTORICAL LEADERSHIP ASSIGNMENTS',
                    style: AppTypography.labelSmall.copyWith(color: textMuted),
                  ),
                  const SizedBox(height: 10),
                  for (final pos in leadership.historicalPositions)
                    _PositionRow(
                      position: pos,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          if (leadership.reportsSubmittedCount > 0 ||
              leadership.recentReports.isNotEmpty)
            EnterpriseSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LEADERSHIP REPORTING HISTORY',
                        style:
                            AppTypography.labelSmall.copyWith(color: textMuted),
                      ),
                      EnterpriseStatusBadge(
                        label: '${leadership.reportsSubmittedCount} Submitted',
                        tone: EnterpriseStatusTone.info,
                        compact: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final rep in leadership.recentReports)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.assignment_turned_in_outlined,
                            size: 16,
                            color: AppColor.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  [
                                    rep.reportType,
                                    if (rep.period.isNotEmpty) rep.period,
                                  ].join(' · '),
                                  style: AppTypography.bodySmall.copyWith(
                                    color: textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (rep.circleName.isNotEmpty ||
                                    rep.submittedAt != null)
                                  Text(
                                    [
                                      if (rep.circleName.isNotEmpty)
                                        rep.circleName,
                                      if (rep.submittedAt != null &&
                                          rep.submittedAt!.isNotEmpty)
                                        DateTimeUtils.formatDate(
                                          rep.submittedAt!,
                                        ),
                                    ].join(' · '),
                                    style: AppTypography.labelSmall
                                        .copyWith(color: textMuted),
                                  ),
                              ],
                            ),
                          ),
                          if (rep.status.isNotEmpty)
                            EnterpriseStatusBadge(
                              label: rep.status,
                              tone: EnterpriseStatusTone.active,
                              compact: true,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PositionRow extends StatelessWidget {
  final PeerLeadershipPositionItem position;
  final Color textPrimary;
  final Color textSecondary;

  const _PositionRow({
    required this.position,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final tenureParts = <String>[
      if (position.startedAt != null && position.startedAt!.isNotEmpty)
        'From ${DateTimeUtils.formatDate(position.startedAt!)}',
      if (position.endedAt != null && position.endedAt!.isNotEmpty)
        'To ${DateTimeUtils.formatDate(position.endedAt!)}'
      else if (position.isCurrent)
        'Present',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            position.isCurrent
                ? Icons.workspace_premium_rounded
                : Icons.history_rounded,
            size: 18,
            color: position.isCurrent ? AppColor.primary : textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  position.roleLabel,
                  style: AppTypography.titleSmall.copyWith(color: textPrimary),
                ),
                if (position.circleName.isNotEmpty || tenureParts.isNotEmpty)
                  Text(
                    [
                      if (position.circleName.isNotEmpty) position.circleName,
                      if (tenureParts.isNotEmpty) tenureParts.join(' – '),
                    ].join(' · '),
                    style: AppTypography.bodySmall
                        .copyWith(color: textSecondary),
                  ),
              ],
            ),
          ),
          EnterpriseStatusBadge(
            label: position.isCurrent ? 'Current' : 'Past Tenure',
            tone: position.isCurrent
                ? EnterpriseStatusTone.active
                : EnterpriseStatusTone.inactive,
            compact: true,
          ),
        ],
      ),
    );
  }
}
