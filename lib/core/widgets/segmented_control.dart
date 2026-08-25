import 'package:flutter/material.dart';

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
              onTap: () => onSegmentChanged(index),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
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
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 14,
                        color: isSelected
                            ? const Color(0xFF1E3C72)
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      labels[index],
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF1E3C72)
                            : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
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
