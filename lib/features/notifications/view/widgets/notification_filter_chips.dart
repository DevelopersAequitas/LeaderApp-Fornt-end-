import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';

class NotificationFilterChips extends StatelessWidget {
  final String activeCategory;
  final ValueChanged<String> onSelected;

  const NotificationFilterChips({
    super.key,
    required this.activeCategory,
    required this.onSelected,
  });

  static const List<Map<String, dynamic>> categories = [
    {
      'key': 'all',
      'label': 'All',
      'icon': Icons.all_inbox_rounded,
    },
    {
      'key': 'circle',
      'label': 'Circle',
      'icon': Icons.groups_rounded,
    },
    {
      'key': 'peers',
      'label': 'Peers',
      'icon': Icons.person_search_rounded,
    },
    {
      'key': 'finance',
      'label': 'Finance',
      'icon': Icons.account_balance_wallet_rounded,
    },
    {
      'key': 'reports',
      'label': 'Reports',
      'icon': Icons.assessment_rounded,
    },
    {
      'key': 'milestones',
      'label': 'Milestones',
      'icon': Icons.emoji_events_rounded,
    },
    {
      'key': 'system',
      'label': 'System',
      'icon': Icons.notifications_active_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected =
              activeCategory.toLowerCase() == (cat['key'] as String);

          return GestureDetector(
            onTap: () => onSelected(cat['key'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColor.brandGradient : null,
                color: isSelected ? null : AppColor.lightSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : AppColor.lightBorder.withValues(alpha: 0.9),
                  width: 0.9,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color:
                              AppColor.primaryBlue.withValues(alpha: 0.28),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    size: 14,
                    color: isSelected
                        ? Colors.white
                        : AppColor.lightTextSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat['label'] as String,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColor.lightTextSecondary,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
