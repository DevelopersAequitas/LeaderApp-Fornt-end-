import 'package:flutter/material.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_widgets.dart';

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

/// Renders the executive bottom navigation bar with clear semantic icons and max w500 typography.
/// Dynamically renders all 5 tabs for Super Admin, and permitted tabs for non-super-admin roles.
class DashboardBottomNavBar extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int> onTabSelected;

  const DashboardBottomNavBar({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
  });

  Widget _buildNavBarItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final isSelected = activeTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(index),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.fastOutSlowIn,
              child: isSelected
                  ? GradientIcon(
                      icon: activeIcon,
                      size: 22,
                      gradient: AppColors.brandGradient,
                    )
                  : Icon(
                      inactiveIcon,
                      size: 22,
                      color: const Color(0xFF64748B),
                    ),
            ),
            const SizedBox(height: 4),
            isSelected
                ? GradientText(
                    label,
                    gradient: AppColors.brandGradient,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSuper = SessionManager().isSuperAdmin;
    final perms = SessionManager().permissions;

    final navItems = <_DashboardNavItemData>[
      const _DashboardNavItemData(
        index: 0,
        activeIcon: Icons.dashboard_rounded,
        inactiveIcon: Icons.dashboard_outlined,
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
          activeIcon: Icons.diversity_3_rounded,
          inactiveIcon: Icons.diversity_3_outlined,
          label: 'Teams',
        ),
      );
    }

    if (isSuper || perms.canAccessFinanceTab) {
      navItems.add(
        const _DashboardNavItemData(
          index: 3,
          activeIcon: Icons.credit_card_rounded,
          inactiveIcon: Icons.credit_card_outlined,
          label: 'Finance',
        ),
      );
    }

    if (isSuper || perms.canAccessReportsTab) {
      navItems.add(
        const _DashboardNavItemData(
          index: 4,
          activeIcon: Icons.description_rounded,
          inactiveIcon: Icons.description_outlined,
          label: 'Report',
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: navItems
                .map(
                  (item) => _buildNavBarItem(
                    item.index,
                    item.activeIcon,
                    item.inactiveIcon,
                    item.label,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
