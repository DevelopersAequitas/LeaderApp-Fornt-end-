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

  static const List<Map<String, String>> categories = [
    {'key': 'all', 'label': 'All'},
    {'key': 'milestones', 'label': 'Milestones'},
    {'key': 'circle', 'label': 'Circle'},
    {'key': 'peers', 'label': 'Peers'},
    {'key': 'reports', 'label': 'Reports'},
    {'key': 'finance', 'label': 'Finance'},
    {'key': 'system', 'label': 'System'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = activeCategory.toLowerCase() == cat['key'];

          return GestureDetector(
            onTap: () => onSelected(cat['key']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColor.primaryBlue : AppColor.lightSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColor.primaryBlue : AppColor.lightBorder,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColor.primaryBlue.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: Text(
                cat['label']!,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColor.lightTextSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
