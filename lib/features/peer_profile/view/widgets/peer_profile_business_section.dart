import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/peer_profile_sections_model.dart';

/// Section B: Professional & Business Information.
class PeerProfileBusinessSection extends StatelessWidget {
  final PeerBusinessInfoModel business;
  final String fallbackBio;
  final List<String> fallbackTags;

  const PeerProfileBusinessSection({
    super.key,
    required this.business,
    this.fallbackBio = '',
    this.fallbackTags = const [],
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

    final bioText =
        business.shortBio.isNotEmpty ? business.shortBio : fallbackBio;
    final tags = business.industryTags.isNotEmpty
        ? business.industryTags
        : fallbackTags;

    final locationLine = [
      if (business.businessAddress.isNotEmpty) business.businessAddress,
      if (business.businessCity.isNotEmpty) business.businessCity,
      if (business.businessState.isNotEmpty) business.businessState,
      if (business.businessCountry.isNotEmpty) business.businessCountry,
      if (business.businessPincode.isNotEmpty) business.businessPincode,
    ].join(', ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (business.completenessPercent > 0) ...[
            EnterpriseSurfaceCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.business_center_outlined,
                    color: AppColor.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Business Profile Completeness',
                          style: AppTypography.labelLarge
                              .copyWith(color: textPrimary),
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: (business.completenessPercent / 100)
                              .clamp(0.0, 1.0),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${business.completenessPercent}%',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColor.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          EnterpriseSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COMPANY & INDUSTRY OVERVIEW',
                  style: AppTypography.labelSmall.copyWith(color: textMuted),
                ),
                const SizedBox(height: 10),
                if (business.companyName.isNotEmpty)
                  _DetailRow('Company', business.companyName),
                if (business.designation.isNotEmpty)
                  _DetailRow('Designation', business.designation),
                if (business.companyType.isNotEmpty)
                  _DetailRow('Company Type', business.companyType),
                if (business.industry.isNotEmpty)
                  _DetailRow('Industry', business.industry),
                if (business.subIndustry.isNotEmpty)
                  _DetailRow('Sub-Industry', business.subIndustry),
                if (business.level4Category.isNotEmpty)
                  _DetailRow('Specialization', business.level4Category),
                if (business.yearsInBusiness != null)
                  _DetailRow(
                    'Years in Business',
                    '${business.yearsInBusiness} years',
                  ),
                if (business.yearOfEstablishment != null)
                  _DetailRow(
                    'Established',
                    '${business.yearOfEstablishment}',
                  ),
                if (business.numberOfEmployees.isNotEmpty)
                  _DetailRow('Team Size', business.numberOfEmployees),
                if (business.annualRevenueRange.isNotEmpty)
                  _DetailRow('Annual Turnover', business.annualRevenueRange),
                if (business.website.isNotEmpty)
                  _DetailRow('Website', business.website),
                if (locationLine.isNotEmpty)
                  _DetailRow('Business Location', locationLine),
              ],
            ),
          ),

          if (bioText.isNotEmpty ||
              business.experienceSummary.isNotEmpty ||
              business.productsServicesOffered.isNotEmpty) ...[
            const SizedBox(height: 10),
            EnterpriseSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ABOUT, PRODUCTS & SERVICES',
                    style: AppTypography.labelSmall.copyWith(color: textMuted),
                  ),
                  if (bioText.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ExpandableText(
                      text: bioText,
                      maxLines: 3,
                      style: AppTypography.bodyMedium.copyWith(
                        color: textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (business.productsServicesOffered.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Products & Services Offered',
                      style: AppTypography.labelMedium
                          .copyWith(color: textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      business.productsServicesOffered,
                      style: AppTypography.bodySmall
                          .copyWith(color: textSecondary),
                    ),
                  ],
                  if (business.experienceSummary.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Experience Summary',
                      style: AppTypography.labelMedium
                          .copyWith(color: textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      business.experienceSummary,
                      style: AppTypography.bodySmall
                          .copyWith(color: textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ],

          if (business.skills.isNotEmpty ||
              business.superpower.isNotEmpty ||
              business.canHelpWith.isNotEmpty ||
              business.lookingFor.isNotEmpty ||
              tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            EnterpriseSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXPERTISE, CAPABILITIES & NEEDS',
                    style: AppTypography.labelSmall.copyWith(color: textMuted),
                  ),
                  if (business.superpower.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _DetailRow('Core Strength', business.superpower),
                  ],
                  if (business.skills.isNotEmpty)
                    _ChipGroup(label: 'Skills & Expertise', items: business.skills),
                  if (business.canHelpWith.isNotEmpty)
                    _ChipGroup(
                      label: 'Can Help Peers With',
                      items: business.canHelpWith,
                    ),
                  if (business.lookingFor.isNotEmpty)
                    _ChipGroup(
                      label: 'Looking For / Requirements',
                      items: business.lookingFor,
                    ),
                  if (business.targetBusinessCategories.isNotEmpty)
                    _ChipGroup(
                      label: 'Target Industries / Customers',
                      items: business.targetBusinessCategories,
                    ),
                  if (business.targetRegions.isNotEmpty)
                    _ChipGroup(
                      label: 'Target Markets / Regions',
                      items: business.targetRegions,
                    ),
                  if (tags.isNotEmpty)
                    _ChipGroup(label: 'Categories & Tags', items: tags),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

class _ChipGroup extends StatelessWidget {
  final String label;
  final List<String> items;

  const _ChipGroup({required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isDark
                  ? AppColor.darkTextPrimary
                  : AppColor.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items
                .map(
                  (t) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColor.darkSurfaceElevated
                          : AppColor.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      border: Border.all(
                        color: isDark ? AppColor.darkBorder : AppColor.outline,
                      ),
                    ),
                    child: Text(
                      t,
                      style: AppTypography.labelSmall.copyWith(
                        color: isDark
                            ? AppColor.darkTextSecondary
                            : AppColor.lightTextSecondary,
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
}
