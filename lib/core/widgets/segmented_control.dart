import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

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
    final animDuration = AppMotion.duration(context, AppMotion.indicator);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isSelected = activeIndex == index;
          final icon =
              icons != null && index < icons!.length ? icons![index] : null;

          return Expanded(
            child: InkWell(
              onTap: () {
                if (!isSelected) {
                  HapticFeedback.selectionClick();
                  onSegmentChanged(index);
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: animDuration,
                curve: AppMotion.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 14,
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      labels[index],
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
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
