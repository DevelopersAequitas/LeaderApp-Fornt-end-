import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/widgets/gradient_widgets.dart';

/// Renders the executive 5-tab Material 3 bottom navigation bar with clear semantic icons and max w500 typography.
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SquareRoundedGradientIcon(
              icon: isSelected ? activeIcon : inactiveIcon,
              iconSize: 20,
              boxSize: 34,
              borderRadius: 10,
              showBorder: true,
              borderWidth: isSelected ? 1.5 : 0.8,
              gradient: isSelected
                  ? AppColors.brandGradient
                  : const LinearGradient(
                      colors: [Color(0xFF94A3B8), Color(0xFF64748B)],
                    ),
              backgroundColor: isSelected ? AppColors.badgeBlueBg : Colors.white,
            ),
            const SizedBox(height: 3),
            isSelected
                ? GradientText(
                    label,
                    gradient: AppColors.brandGradient,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavBarItem(
                0,
                Icons.dashboard_rounded,
                Icons.dashboard_outlined,
                'Dashboard',
              ),
              _buildNavBarItem(
                1,
                Icons.people_alt_rounded,
                Icons.people_alt_outlined,
                'Peers',
              ),
              _buildNavBarItem(
                2,
                Icons.diversity_3_rounded,
                Icons.diversity_3_outlined,
                'Teams',
              ),
              _buildNavBarItem(
                3,
                Icons.credit_card_rounded,
                Icons.credit_card_outlined,
                'Finance',
              ),
              _buildNavBarItem(
                4,
                Icons.description_rounded,
                Icons.description_outlined,
                'Report',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
