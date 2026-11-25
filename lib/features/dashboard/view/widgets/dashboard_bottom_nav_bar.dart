import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class _DashboardNavItemData {
  final int index;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  const _DashboardNavItemData({
    required this.index,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}

/// Enterprise Bottom Navigation Bar with crisp Cobalt indicator, accessible
/// WCAG AA contrast, tactile press feedback, and role-gated destinations.
class DashboardBottomNavBar extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int> onTabSelected;

  const DashboardBottomNavBar({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSuper = SessionManager().isSuperAdmin;
    final perms = SessionManager().permissions;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navItems = <_DashboardNavItemData>[
      const _DashboardNavItemData(
        index: 0,
        activeIcon: Icons.space_dashboard_rounded,
        inactiveIcon: Icons.space_dashboard_outlined,
        label: 'Dashboard',
      ),
    ];

    if (isSuper || perms.canAccessPeersTab) {
      navItems.add(
        const _DashboardNavItemData(
          index: 1,
          activeIcon: Icons.people_alt_rounded,
          inactiveIcon: Icons.people_alt_outlined,
          label: 'Peers',
        ),
      );
    }

    if (isSuper || perms.canAccessTeamsTab) {
      navItems.add(
        const _DashboardNavItemData(
          index: 2,
          activeIcon: Icons.hub_rounded,
          inactiveIcon: Icons.hub_outlined,
          label: 'Teams',
        ),
      );
    }

    if (isSuper || perms.canAccessFinanceTab) {
      navItems.add(
        const _DashboardNavItemData(
          index: 3,
          activeIcon: Icons.account_balance_wallet_rounded,
          inactiveIcon: Icons.account_balance_wallet_outlined,
          label: 'Finance',
        ),
      );
    }

    if (isSuper || perms.canAccessReportsTab) {
      navItems.add(
        const _DashboardNavItemData(
          index: 4,
          activeIcon: Icons.analytics_rounded,
          inactiveIcon: Icons.analytics_outlined,
          label: 'Report',
        ),
      );
    }

    final surface = isDark ? AppColor.darkSurface : AppColor.lightSurface;
    final border = isDark ? AppColor.darkBorder : AppColor.outline;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          top: BorderSide(color: border, width: 1.0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSpacing.navBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: navItems
                .map(
                  (item) => Expanded(
                    child: _TactileNavBarItem(
                      item: item,
                      isSelected: activeTab == item.index,
                      onTap: () {
                        if (activeTab != item.index) {
                          HapticFeedback.selectionClick();
                        }
                        onTabSelected(item.index);
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _TactileNavBarItem extends StatefulWidget {
  final _DashboardNavItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  const _TactileNavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_TactileNavBarItem> createState() => _TactileNavBarItemState();
}

class _TactileNavBarItemState extends State<_TactileNavBarItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final indicatorDuration = AppMotion.duration(context, AppMotion.indicator);
    final pressDuration = AppMotion.duration(context, AppMotion.press);
    final isSelected = widget.isSelected;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeColor = isDark ? const Color(0xFF60A5FA) : AppColor.primary;
    final activePillBg = isDark
        ? const Color(0xFF1E3A8A).withValues(alpha: 0.55)
        : AppColor.primaryContainer;
    final inactiveColor =
        isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${widget.item.label} tab',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          if (_isPressed) setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () {
          if (_isPressed) setState(() => _isPressed = false);
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.94 : 1.0,
          duration: pressDuration,
          curve: AppMotion.easeOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: indicatorDuration,
                curve: AppMotion.easeOut,
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 14 : 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? activePillBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Icon(
                  isSelected
                      ? widget.item.activeIcon
                      : widget.item.inactiveIcon,
                  size: 20,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                widget.item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
