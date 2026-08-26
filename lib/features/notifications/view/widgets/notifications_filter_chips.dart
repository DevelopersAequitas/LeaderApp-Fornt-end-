import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Horizontal scrollable filter chips for categorizing notifications.
class NotificationsFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;
  final int allCount;
  final int unreadCount;

  const NotificationsFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.allCount,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'key': 'All', 'label': 'All ($allCount)'},
      {'key': 'Unread', 'label': 'Unread ($unreadCount)'},
      {'key': 'Referrals', 'label': 'Referrals'},
      {'key': 'Deals', 'label': 'Deals'},
      {'key': 'Meetings', 'label': 'Meetings'},
      {'key': 'Alerts', 'label': 'Alerts'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: filters.map((f) {
          final isSelected = selectedFilter == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: InkWell(
              onTap: () => onFilterSelected(f['key']!),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  f['label']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
