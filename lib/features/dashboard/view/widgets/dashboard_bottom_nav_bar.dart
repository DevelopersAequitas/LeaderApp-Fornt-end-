import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Renders the executive 5-tab Material 3 bottom navigation bar.
class DashboardBottomNavBar extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int> onTabSelected;

  const DashboardBottomNavBar({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
  });

  Widget _buildNavBarItem(int index, IconData icon, String label) {
    final isSelected = activeTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.selectionBg : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF1E3C72)
                    : AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF1E3C72)
                    : AppColors.textSecondary,
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
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavBarItem(0, Icons.dashboard_rounded, 'Dashboard'),
          _buildNavBarItem(1, Icons.people_outline_rounded, 'Peers'),
          _buildNavBarItem(2, Icons.group_work_outlined, 'Teams'),
          _buildNavBarItem(3, Icons.credit_card_rounded, 'Finance'),
          _buildNavBarItem(4, Icons.description_outlined, 'Report'),
        ],
      ),
    );
  }
}
