import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HorizontalSelectionChips extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final void Function(String) onSelected;
  final bool showBulletWhenSelected;
  final Color? selectedBgColor;
  final Color? unselectedBgColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final Color? bulletColor;

  const HorizontalSelectionChips({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
    this.showBulletWhenSelected = false,
    this.selectedBgColor,
    this.unselectedBgColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.bulletColor,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) {
          final isSelected = option.toLowerCase() == selectedOption.toLowerCase();

          // Define style fallbacks based on primary/transparent theme
          final bgSelected = selectedBgColor ?? AppColors.primary;
          final bgUnselected = unselectedBgColor ?? Colors.transparent;
          final textSelected = selectedTextColor ?? Colors.white;
          final textUnselected = unselectedTextColor ?? AppColors.textSecondary;
          final bullet = bulletColor ?? Colors.white;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => onSelected(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? bgSelected : bgUnselected,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected && showBulletWhenSelected) ...[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: bullet,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? textSelected : textUnselected,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
