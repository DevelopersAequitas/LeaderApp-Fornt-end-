import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../teams/model/teams_model.dart';
import '../../model/dashboard_circle_option.dart';
import 'dashboard_circle_switcher.dart';

/// Compact Executive Identity & Permission-Aware Organizational Scope Bar.
///
/// Designed for rapid orientation: displays greeting + date, leader name,
/// role badge, scope summary, and an intuitive scope switcher when authorized
/// across multiple Circles.
class DashboardWelcomeHeader extends StatelessWidget {
  final List<CircleTeamModel> circles;
  final List<DashboardCircleOption> availableCircles;
  final List<String> industries;
  final String? selectedCircleId;
  final ValueChanged<String> onCircleSelected;
  final DateTime? currentTime;

  const DashboardWelcomeHeader({
    super.key,
    required this.circles,
    required this.availableCircles,
    required this.industries,
    required this.selectedCircleId,
    required this.onCircleSelected,
    this.currentTime,
  });

  static String _greetingForHour(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _resolveScopeSummary(UserSession session) {
    if (selectedCircleId != null && selectedCircleId!.trim().isNotEmpty) {
      for (final c in circles) {
        if (c.id.trim() == selectedCircleId!.trim()) {
          final parts = <String>['Filtered Circle: ${c.name}'];
          if (c.location.trim().isNotEmpty) parts.add(c.location.trim());
          return parts.join(' · ');
        }
      }
      for (final opt in availableCircles) {
        if (opt.id == selectedCircleId) return 'Filtered Circle: ${opt.name}';
      }
    }

    final activeCircles = circles
        .where((c) => c.status.toLowerCase() == 'active')
        .length;
    final totalCircles = circles.isNotEmpty
        ? circles.length
        : availableCircles.length;

    switch (session.role) {
      case UserRole.superAdmin:
      case UserRole.globalFounder:
        final segments = <String>['Global'];
        if (totalCircles > 0) {
          segments.add(
            activeCircles > 0 && activeCircles != totalCircles
                ? '$activeCircles/$totalCircles Circles'
                : '$totalCircles Circles',
          );
        }
        if (industries.isNotEmpty) {
          segments.add('${industries.length} Industries');
        }
        return segments.join(' · ');

      case UserRole.countryDirector:
        final territory =
            session.regionalScope.trim().isNotEmpty &&
                session.regionalScope.toLowerCase() != 'own circle'
            ? session.regionalScope.trim()
            : 'National Scope';
        return totalCircles > 0
            ? '$territory · $totalCircles Circles'
            : territory;

      case UserRole.districtExecDirector:
        final district =
            session.regionalScope.trim().isNotEmpty &&
                session.regionalScope.toLowerCase() != 'own circle'
            ? session.regionalScope.trim()
            : (session.city.trim().isNotEmpty
                  ? '${session.city.trim()} District'
                  : 'Assigned District');
        return totalCircles > 0
            ? '$district · $totalCircles Circles'
            : district;

      case UserRole.industryDirector:
        final ind = session.industry.trim().isNotEmpty
            ? session.industry.trim()
            : (industries.isNotEmpty ? industries.first : 'Assigned Industry');
        return totalCircles > 0 ? '$ind · $totalCircles Circles' : ind;

      case UserRole.circleFounder:
      case UserRole.circleDirector:
      case UserRole.chairBusinessGrowth:
      case UserRole.chairMembership:
      case UserRole.chairEvents:
      case UserRole.circleChair:
      case UserRole.committeeLeader:
      case UserRole.viceChair:
      case UserRole.secretary:
        if (circles.length == 1) {
          final c = circles.first;
          return c.location.trim().isNotEmpty
              ? '${c.name} · ${c.location.trim()}'
              : c.name;
        }
        if (session.managedCircles.isNotEmpty) {
          return session.managedCircles.length == 1
              ? session.managedCircles.first
              : '${session.managedCircles.first} +${session.managedCircles.length - 1} more';
        }
        return session.regionalScope.trim().isNotEmpty
            ? session.regionalScope.trim()
            : 'Assigned Circle';
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionManager().currentSession;
    final perms = SessionManager().permissions;
    final isSuper = SessionManager().isSuperAdmin;
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

    final now = currentTime ?? DateTime.now();
    final greeting = _greetingForHour(now.hour);
    String dateLabel;
    try {
      dateLabel = DateFormat('EEE, MMM d').format(now);
    } catch (_) {
      dateLabel =
          '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
    }

    final displayName = session.name.trim().isNotEmpty
        ? session.name.trim()
        : 'Leader';
    final roleLabel =
        (session.customRoleLabel != null &&
            session.customRoleLabel!.trim().isNotEmpty)
        ? session.customRoleLabel!.trim()
        : session.role.label;
    final scopeSummary = _resolveScopeSummary(session);
    final isGlobalRole = isSuper || session.role == UserRole.countryDirector;
    final canSwitchScope =
        availableCircles.length > 1 &&
        (isSuper ||
            isGlobalRole ||
            perms.canViewRegionalScope ||
            perms.canAccessTeamsTab ||
            session.managedCircles.length > 1);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColor.darkSurface : AppColor.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColor.darkBorder : AppColor.outline,
            width: 1.0,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenMargin,
        vertical: 9,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting · $dateLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 11,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium.copyWith(
                        fontSize: 16.5,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (canSwitchScope) ...[
                const SizedBox(width: 8),
                DashboardCircleSwitcher(
                  circles: availableCircles,
                  industries: industries,
                  selectedCircleId: selectedCircleId,
                  isGlobalRole: isGlobalRole,
                  onSelected: onCircleSelected,
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              final textScale = MediaQuery.textScalerOf(context).scale(1.0);
              final useWrap = constraints.maxWidth < 330 || textScale > 1.25;
              if (!useWrap) {
                return Row(
                  children: [
                    EnterpriseStatusBadge(
                      label: roleLabel,
                      tone: EnterpriseStatusTone.info,
                      icon: Icons.verified_user_outlined,
                      compact: true,
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.public_rounded, size: 13, color: textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        scopeSummary,

                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelMedium.copyWith(
                          color: textSecondary,
                        ),
                      ),
                    ),
                    if (selectedCircleId != null &&
                        selectedCircleId!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      InkWell(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXs,
                        ),
                        onTap: () => onCircleSelected(kAllCirclesValue),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.surfaceContainer,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusXs,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.close_rounded,
                                size: 11,
                                color: textSecondary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Reset',
                                style: AppTypography.labelSmall.copyWith(
                                  fontSize: 11,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }
              return Wrap(
                spacing: 8,
                runSpacing: 5,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                    child: EnterpriseStatusBadge(
                      label: roleLabel,
                      tone: EnterpriseStatusTone.info,
                      icon: Icons.verified_user_outlined,
                      compact: true,
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.public_rounded,
                          size: 13,
                          color: textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            scopeSummary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.labelMedium.copyWith(
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selectedCircleId != null && selectedCircleId!.isNotEmpty)
                    InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                      onTap: () => onCircleSelected(kAllCirclesValue),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.surfaceContainer,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusXs,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.close_rounded,
                              size: 12,
                              color: textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Reset scope',
                              style: AppTypography.labelSmall.copyWith(
                                fontSize: 11,
                                color: textSecondary,
                              ),
                            ),
                          ],
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
}
