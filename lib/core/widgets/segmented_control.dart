import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SegmentedControl extends StatelessWidget {
  final List<String> labels;
  final List<IconData?>? icons;
  final int activeIndex;
  final void Function(int) onSegmentChanged;
  final EdgeInsetsGeometry? margin;

  const SegmentedControl({
    super.key,
    required this.labels,
    required this.activeIndex,
    required this.onSegmentChanged,
    this.icons,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.secondaryBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isSelected = activeIndex == index;
          final icon = icons != null && index < icons!.length ? icons![index] : null;

          return Expanded(
            child: InkWell(
              onTap: () => onSegmentChanged(index),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      labels[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
