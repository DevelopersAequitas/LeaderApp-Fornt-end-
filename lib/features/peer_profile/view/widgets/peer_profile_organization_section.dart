import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/peer_profile_sections_model.dart';

/// Section C: Organizational Membership & Placement.
class PeerProfileOrganizationSection extends StatelessWidget {
  final PeerOrganizationInfoModel organization;

  const PeerProfileOrganizationSection({
    super.key,
    required this.organization,
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
          EnterpriseSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORGANIZATIONAL PLACEMENT',
                  style: AppTypography.labelSmall.copyWith(color: textMuted),
                ),
                const SizedBox(height: 10),
                if (organization.country.isNotEmpty)
                  _OrgRow('Country', organization.country),
                if (organization.state.isNotEmpty)
                  _OrgRow('State / Region', organization.state),
                if (organization.districtName.isNotEmpty)
                  _OrgRow('District', organization.districtName),
                if (organization.city.isNotEmpty)
                  _OrgRow('City', organization.city),
                if (organization.primaryCircleName.isNotEmpty)
                  _OrgRow('Primary Circle', organization.primaryCircleName),
                if (organization.membershipType.isNotEmpty)
                  _OrgRow('Membership Type', organization.membershipType),
                if (organization.membershipStatus.isNotEmpty)
                  _OrgRow('Membership Status', organization.membershipStatus),
                if (organization.joiningDate.isNotEmpty)
                  _OrgRow('Platform Joined', organization.joiningDate),
                if (organization.circleJoinedAt.isNotEmpty)
                  _OrgRow('Circle Joined', organization.circleJoinedAt),
                if (organization.renewalExpiryDate.isNotEmpty)
                  _OrgRow('Renewal / Expiry', organization.renewalExpiryDate),
                if (organization.introducedByName != null &&
                    organization.introducedByName!.isNotEmpty)
                  InkWell(
                    onTap: organization.introducedById != null &&
                            organization.introducedById!.isNotEmpty
                        ? () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.peerProfile,
                              arguments: organization.introducedById!,
                            );
                          }
                        : null,
                    child: _OrgRow(
                      'Introduced By',
                      organization.introducedByCompany != null &&
                              organization.introducedByCompany!.isNotEmpty
                          ? '${organization.introducedByName} (${organization.introducedByCompany})'
                          : organization.introducedByName!,
                    ),
                  ),
              ],
            ),
          ),

          if (organization.circles.isNotEmpty) ...[
            const SizedBox(height: 10),
            EnterpriseSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CIRCLE MEMBERSHIPS',
                    style: AppTypography.labelSmall.copyWith(color: textMuted),
                  ),
                  const SizedBox(height: 10),
                  for (final cm in organization.circles)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.groups_rounded,
                            size: 18,
                            color: AppColor.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cm.circleName.isNotEmpty
                                      ? cm.circleName
                                      : 'Circle',
                                  style: AppTypography.titleSmall
                                      .copyWith(color: textPrimary),
                                ),
                                Text(
                                  [
                                    if (cm.role.isNotEmpty) cm.role,
                                    if (cm.districtName != null &&
                                        cm.districtName!.isNotEmpty)
                                      cm.districtName!,
                                    if (cm.joinedAt != null &&
                                        cm.joinedAt!.isNotEmpty)
                                      'Joined ${cm.joinedAt}',
                                  ].join(' · '),
                                  style: AppTypography.bodySmall
                                      .copyWith(color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                          if (cm.status.isNotEmpty)
                            EnterpriseStatusBadge(
                              label: cm.status,
                              tone: cm.status.toLowerCase() == 'active' ||
                                      cm.status.toLowerCase() == 'approved'
                                  ? EnterpriseStatusTone.active
                                  : EnterpriseStatusTone.inactive,
                              compact: true,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],

          if (organization.assignedLeadership.isNotEmpty) ...[
            const SizedBox(height: 10),
            EnterpriseSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CIRCLE ASSIGNED LEADERSHIP',
                    style: AppTypography.labelSmall.copyWith(color: textMuted),
                  ),
                  const SizedBox(height: 10),
                  for (final ldr in organization.assignedLeadership)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.workspace_premium_outlined,
                        color: AppColor.primary,
                        size: 18,
                      ),
                      title: Text(
                        ldr.name,
                        style: AppTypography.bodyMedium
                            .copyWith(color: textPrimary),
                      ),
                      subtitle: Text(
                        [
                          ldr.roleLabel,
                          if (ldr.companyName.isNotEmpty) ldr.companyName,
                        ].join(' · '),
                        style: AppTypography.bodySmall
                            .copyWith(color: textSecondary),
                      ),
                      onTap: ldr.userId.isNotEmpty
                          ? () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.peerProfile,
                                arguments: ldr.userId,
                              );
                            }
                          : null,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrgRow extends StatelessWidget {
  final String label;
  final String value;

  const _OrgRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isDark
                    ? AppColor.darkTextTertiary
                    : AppColor.lightTextMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(
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
