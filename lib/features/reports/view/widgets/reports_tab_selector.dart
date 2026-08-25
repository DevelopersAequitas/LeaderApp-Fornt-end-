import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Renders the segmented sub-tab selector for Reports screen.
class ReportsTabSelector extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTabSelected;
  final String firstTabLabel;
  final String secondTabLabel;
  final String? secondTabBadge;

  const ReportsTabSelector({
    super.key,
    required this.activeIndex,
    required this.onTabSelected,
    required this.firstTabLabel,
    required this.secondTabLabel,
    this.secondTabBadge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildSegmentTab(0, firstTabLabel, null),
          _buildSegmentTab(1, secondTabLabel, secondTabBadge),
        ],
      ),
    );
  }

  Widget _buildSegmentTab(int index, String label, String? countBadge) {
    final isSelected = activeIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(index),
        borderRadius: BorderRadius.circular(9),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
              if (countBadge != null) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    countBadge,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.text,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
