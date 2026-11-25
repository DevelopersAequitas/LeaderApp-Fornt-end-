import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/notification_count_service.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/dashboard_circle_option.dart';
import 'dashboard_circle_switcher.dart';

/// Compact, refined Enterprise Top App Bar for the Leadership shell.
///
/// - Tab 0 (`Dashboard`): Peers Global architectural brand lockup + quick controls.
/// - Tab 1 (`Peers`): Clean `Peers` title + inline search toggle.
/// - Tabs 2–4: Crisp section title + scope switcher, notifications, and profile avatar.
class DashboardAppBar extends StatelessWidget {
  final int activeTab;
  final String? selectedCircle;
  final List<String> dynamicIndustries;
  final List<DashboardCircleOption> availableCircles;
  final ValueChanged<String> onCircleSelected;
  final bool isSearching;
  final TextEditingController? searchController;
  final VoidCallback? onSearchTap;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchClose;

  const DashboardAppBar({
    super.key,
    required this.activeTab,
    this.selectedCircle,
    required this.dynamicIndustries,
    this.availableCircles = const [],
    required this.onCircleSelected,
    this.isSearching = false,
    this.searchController,
    this.onSearchTap,
    this.onSearchChanged,
    this.onSearchClose,
  });

  @override
  Widget build(BuildContext context) {
    final session = SessionManager().currentSession;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColor.darkSurface : AppColor.lightSurface;
    final borderColor = isDark ? AppColor.darkBorder : AppColor.outline;
    final textPrimary =
        isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final textSecondary =
        isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;

    final tabTitle = switch (activeTab) {
      1 => 'Peers',
      2 => 'Circles & Teams',
      3 => 'Finance',
      4 => 'Reports',
      _ => 'Peers Global',
    };

    final showInlineSearch = activeTab == 1 && isSearching;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: surfaceColor,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: borderColor,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(
            bottom: BorderSide(color: borderColor, width: 1.0),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenMargin,
          6,
          AppSpacing.screenMargin,
          8,
        ),
        child: SafeArea(
          bottom: false,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: showInlineSearch
                ? _buildInlineSearchRow(
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    borderColor: borderColor,
                  )
                : Row(
                    children: [
                      Expanded(
                        child: activeTab == 0
                            ? _buildBrandLockup(
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                              )
                            : Text(
                                tabTitle,
                                style: AppTypography.titleLarge.copyWith(
                                  fontSize: 17,
                                  color: textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                      if (activeTab == 1) ...[
                        _buildHeaderIconButton(
                          icon: Icons.search_rounded,
                          semanticLabel: 'Search peers',
                          isDark: isDark,
                          onTap: onSearchTap ?? () {},
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (activeTab != 0 && availableCircles.length > 1) ...[
                        DashboardCircleSwitcher(
                          circles: availableCircles,
                          industries: dynamicIndustries,
                          selectedCircleId: selectedCircle,
                          isGlobalRole:
                              session.role == UserRole.superAdmin ||
                              session.role == UserRole.countryDirector,
                          onSelected: onCircleSelected,
                        ),
                        const SizedBox(width: 8),
                      ],
                      _buildNotificationBellButton(context, isDark: isDark),
                      const SizedBox(width: 8),
                      Semantics(
                        button: true,
                        label: 'Open leader profile for ${session.name}',
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () =>
                              Navigator.of(context).pushNamed(AppRoutes.profile),
                          child: Container(
                            width: 38,
                            height: 38,
                            padding: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColor.outlineStrong,
                                width: 1.2,
                              ),
                            ),
                            child: ClipOval(
                              child: InitialsAvatar(
                                name: session.name,
                                imageUrl: session.avatarUrl,
                                radius: 17,
                                backgroundColor: AppColor.primaryContainer,
                                textColor: AppColor.onPrimaryContainer,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandLockup({
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColor.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: AppColor.outline),
          ),
          child: Image.asset(
            'assets/icons/AppIcon.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Peers Global',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleMedium.copyWith(
                  fontSize: 16,
                  color: textPrimary,
                  letterSpacing: -0.25,
                ),
              ),
              Text(
                'Leadership Platform',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 11.5,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInlineSearchRow({
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required Color borderColor,
  }) {
    return Row(
      children: [
        _buildHeaderIconButton(
          icon: Icons.arrow_back_rounded,
          semanticLabel: 'Close search',
          isDark: isDark,
          onTap: onSearchClose ?? () {},
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColor.darkSurfaceSubtle
                  : AppColor.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: borderColor),
            ),
            alignment: Alignment.center,
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 17,
                  color: textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    autofocus: true,
                    onChanged: onSearchChanged,
                    style: AppTypography.bodyMedium.copyWith(
                      color: textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by name, company, circle...',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: AppColor.lightTextMuted,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (searchController != null)
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: searchController!,
                    builder: (context, value, _) {
                      if (value.text.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return GestureDetector(
                        onTap: () {
                          searchController!.clear();
                          onSearchChanged?.call('');
                        },
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: textSecondary,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required String semanticLabel,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final bg =
        isDark ? AppColor.darkSurfaceSubtle : AppColor.surfaceContainerLow;
    final stroke = isDark ? AppColor.darkBorder : AppColor.outline;
    final fg = isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: stroke, width: 1.0),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            onTap: onTap,
            child: Center(
              child: Icon(icon, size: 19, color: fg),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBellButton(
    BuildContext context, {
    required bool isDark,
  }) {
    final bg =
        isDark ? AppColor.darkSurfaceSubtle : AppColor.surfaceContainerLow;
    final stroke = isDark ? AppColor.darkBorder : AppColor.outline;
    final fg = isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;

    return ValueListenableBuilder<int>(
      valueListenable: NotificationCountService.instance.unreadCount,
      builder: (context, unreadCount, _) {
        final hasUnread = unreadCount > 0;
        final countText = unreadCount > 99 ? '99+' : '$unreadCount';

        return Semantics(
          button: true,
          label: hasUnread
              ? 'Notifications, $unreadCount unread'
              : 'Notifications',
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: stroke, width: 1.0),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    onTap: () async {
                      await Navigator.of(context)
                          .pushNamed(AppRoutes.notifications);
                      NotificationCountService.instance.fetchUnreadCount();
                    },
                    child: Center(
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 20,
                        color: fg,
                      ),
                    ),
                  ),
                ),
              ),
              if (hasUnread)
                Positioned(
                  top: -4,
                  right: -4,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.secondary,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusPill),
                        border: Border.all(
                          color: isDark
                              ? AppColor.darkSurface
                              : AppColor.lightSurface,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        countText,
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
