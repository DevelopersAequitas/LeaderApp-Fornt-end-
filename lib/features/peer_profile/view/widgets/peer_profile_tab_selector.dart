import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../presenter/peer_profile_presenter.dart';

/// Responsive scrollable section selector for the Founder-Level Peer Profile.
class PeerProfileTabSelector extends StatelessWidget {
  final List<PeerProfileSection> sections;
  final PeerProfileSection activeSection;
  final ValueChanged<PeerProfileSection> onSectionSelected;

  const PeerProfileTabSelector({
    super.key,
    required this.sections,
    required this.activeSection,
    required this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColor.darkBorder : AppColor.outline;

    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColor.darkSurface : AppColor.lightSurface,
        border: Border(
          top: BorderSide(color: borderColor, width: 0.8),
          bottom: BorderSide(color: borderColor, width: 0.8),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenMargin,
          vertical: 8,
        ),
        child: Row(
          children: [
            for (var i = 0; i < sections.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              _SectionChip(
                section: sections[i],
                selected: sections[i] == activeSection,
                onTap: () => onSectionSelected(sections[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionChip extends StatelessWidget {
  final PeerProfileSection section;
  final bool selected;
  final VoidCallback onTap;

  const _SectionChip({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: selected
          ? AppColor.primary
          : (isDark
              ? AppColor.darkSurfaceElevated
              : AppColor.surfaceContainerLow),
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(
              color: selected
                  ? AppColor.primary
                  : (isDark ? AppColor.darkBorder : AppColor.outline),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                section.icon,
                size: 14,
                color: selected
                    ? Colors.white
                    : (isDark
                        ? AppColor.darkTextSecondary
                        : AppColor.lightTextSecondary),
              ),
              const SizedBox(width: 6),
              Text(
                section.label,
                style: AppTypography.labelMedium.copyWith(
                  color: selected
                      ? Colors.white
                      : (isDark
                          ? AppColor.darkTextPrimary
                          : AppColor.lightTextPrimary),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
