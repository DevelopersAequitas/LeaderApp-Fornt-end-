import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Semantic operational status variants — always communicated via BOTH
/// icon + label + accessible tint (never colour alone).
enum EnterpriseStatusTone {
  critical,
  pending,
  completed,
  active,
  rejected,
  inactive,
  info,
}

/// Crisp, minimal enterprise container using 1px structural borders instead of
/// decorative gradients or heavy shadows.
class EnterpriseSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final String? semanticLabel;

  const EnterpriseSurfaceCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardInsets,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = AppSpacing.radiusMd,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ??
        (isDark ? AppColor.darkSurface : AppColor.lightSurface);
    final stroke = borderColor ??
        (isDark ? AppColor.darkBorder : AppColor.outline);

    Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: stroke, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(borderRadius),
                child: Padding(padding: padding, child: child),
              )
            : Padding(padding: padding, child: child),
      ),
    );

    if (semanticLabel != null && semanticLabel!.isNotEmpty) {
      content = Semantics(
        button: onTap != null,
        label: semanticLabel,
        child: content,
      );
    }

    return content;
  }
}

/// Consistent section header across executive screens.
class EnterpriseSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? countLabel;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final EdgeInsetsGeometry padding;

  const EnterpriseSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.countLabel,
    this.actionLabel,
    this.onActionTap,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final subColor = isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;

    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxActionWidth = (constraints.maxWidth * 0.42).clamp(80.0, 180.0);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: AppTypography.sectionTitle.copyWith(
                              color: titleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (countLabel != null && countLabel!.isNotEmpty) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(
                            flex: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColor.darkSurfaceSubtle
                                    : AppColor.surfaceContainer,
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusXs),
                                border: Border.all(
                                  color: isDark
                                      ? AppColor.darkBorder
                                      : AppColor.outline,
                                ),
                              ),
                              child: Text(
                                countLabel!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelSmall.copyWith(
                                  color: subColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTypography.bodySmall.copyWith(color: subColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (actionLabel != null && onActionTap != null) ...[
                const SizedBox(width: AppSpacing.sm),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 36,
                    maxWidth: maxActionWidth,
                  ),
                  child: Semantics(
                    button: true,
                    label: '$actionLabel, $title',
                    child: InkWell(
                      onTap: onActionTap,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                actionLabel!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColor.primary,
                                  fontWeight: FontWeight.w600,
                                ),
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
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Accessible status pill combining an explicit icon, label, semantic background,
/// and border so status is never communicated by colour alone.
class EnterpriseStatusBadge extends StatelessWidget {
  final String label;
  final EnterpriseStatusTone tone;
  final IconData? icon;
  final bool compact;

  const EnterpriseStatusBadge({
    super.key,
    required this.label,
    required this.tone,
    this.icon,
    this.compact = false,
  });

  (Color fg, Color bg, Color border, IconData defaultIcon) _resolvePalette() {
    return switch (tone) {
      EnterpriseStatusTone.critical => (
          AppColor.critical,
          AppColor.criticalBg,
          AppColor.criticalBorder,
          Icons.error_outline_rounded,
        ),
      EnterpriseStatusTone.pending => (
          AppColor.pending,
          AppColor.pendingBg,
          AppColor.pendingBorder,
          Icons.schedule_rounded,
        ),
      EnterpriseStatusTone.completed => (
          AppColor.completed,
          AppColor.completedBg,
          AppColor.completedBorder,
          Icons.task_alt_rounded,
        ),
      EnterpriseStatusTone.active => (
          AppColor.activeStatus,
          AppColor.activeStatusBg,
          AppColor.activeStatusBorder,
          Icons.check_circle_outline_rounded,
        ),
      EnterpriseStatusTone.rejected => (
          AppColor.rejected,
          AppColor.rejectedBg,
          AppColor.rejectedBorder,
          Icons.cancel_outlined,
        ),
      EnterpriseStatusTone.inactive => (
          AppColor.inactiveStatus,
          AppColor.inactiveStatusBg,
          AppColor.inactiveStatusBorder,
          Icons.remove_circle_outline_rounded,
        ),
      EnterpriseStatusTone.info => (
          AppColor.info,
          AppColor.infoBg,
          AppColor.infoBorder,
          Icons.info_outline_rounded,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (fg, bg, border, defaultIcon) = _resolvePalette();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 2.5 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? defaultIcon,
            size: compact ? 12 : 13.5,
            color: fg,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(
                color: fg,
                fontSize: compact ? 11 : 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Executive KPI Metric Card (Stripe / Linear style) with tabular figures,
/// clear label, semantic icon badge, optional truthful context note, and
/// accessible touch feedback.
class EnterpriseMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final String? contextNote;
  final EnterpriseStatusTone? noteTone;
  final bool isUnavailable;
  final bool compact;
  final VoidCallback? onTap;

  const EnterpriseMetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accentColor = AppColor.primary,
    this.contextNote,
    this.noteTone,
    this.isUnavailable = false,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final textSecondary = isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;
    final textMuted = isDark ? AppColor.darkTextTertiary : AppColor.lightTextMuted;

    if (compact) {
      return EnterpriseSurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        onTap: onTap,
        semanticLabel: '$label: $value${contextNote != null ? ', $contextNote' : ''}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 13, color: accentColor),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelMedium.copyWith(
                      color: textSecondary,
                    ),
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 13,
                    color: textMuted,
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: isUnavailable
                          ? AppTypography.titleSmall.copyWith(
                              color: textMuted,
                              fontWeight: FontWeight.w500,
                            )
                          : AppTypography.metricLarge.copyWith(
                              fontSize: 18.5,
                              color: textPrimary,
                            ),
                    ),
                  ),
                ),
                if (contextNote != null && contextNote!.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      contextNote!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 11,
                        color: noteTone == EnterpriseStatusTone.active
                            ? AppColor.success
                            : (noteTone == EnterpriseStatusTone.pending
                                ? AppColor.pending
                                : textMuted),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    }

    return EnterpriseSurfaceCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      semanticLabel: '$label: $value${contextNote != null ? ', $contextNote' : ''}',
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
                  color: accentColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 16, color: accentColor),
              ),
              const Spacer(),
              if (onTap != null)
                Icon(
                  Icons.arrow_outward_rounded,
                  size: 15,
                  color: textMuted,
                ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: isUnavailable
                  ? AppTypography.titleSmall.copyWith(
                      color: textMuted,
                      fontWeight: FontWeight.w500,
                    )
                  : AppTypography.metricLarge.copyWith(color: textPrimary),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMedium.copyWith(color: textSecondary),
          ),
          if (contextNote != null && contextNote!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              contextNote!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(
                color: noteTone == EnterpriseStatusTone.active
                    ? AppColor.success
                    : (noteTone == EnterpriseStatusTone.pending
                        ? AppColor.pending
                        : textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Clean, reassuring Empty State component explaining why no data is shown
/// and offering an optional next action.
class EnterpriseEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  const EnterpriseEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final subColor = isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;

    return EnterpriseSurfaceCard(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: compact ? 18 : 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 38 : 44,
            height: compact ? 38 : 44,
            decoration: BoxDecoration(
              color: isDark ? AppColor.darkSurfaceSubtle : AppColor.surfaceContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: compact ? 19 : 22,
              color: subColor,
            ),
          ),
          SizedBox(height: compact ? 10 : 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.titleSmall.copyWith(color: titleColor),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: subColor),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(88, 38),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

/// Non-technical, recoverable Error State component with explicit Retry button.
class EnterpriseErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const EnterpriseErrorState({
    super.key,
    this.title = 'Unable to load dashboard data',
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final subColor = isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenMargin),
      child: EnterpriseSurfaceCard(
        padding: const EdgeInsets.all(24),
        borderColor: AppColor.criticalBorder,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColor.criticalBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 22,
                color: AppColor.critical,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium.copyWith(color: titleColor),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: subColor),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
