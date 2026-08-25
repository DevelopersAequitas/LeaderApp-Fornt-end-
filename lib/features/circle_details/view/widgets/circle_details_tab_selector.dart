import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Renders the compact sub-tab selector for Circle Details in Material 3 style.
class CircleDetailsTabSelector extends StatelessWidget {
  final int activeTab;
  final int peersCount;
  final int eventsCount;
  final ValueChanged<int> onTabChanged;

  const CircleDetailsTabSelector({
    super.key,
    required this.activeTab,
    required this.peersCount,
    required this.eventsCount,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      'Overview',
      peersCount > 0 ? 'Peers ($peersCount)' : 'Peers',
      'Sub-Industries',
      eventsCount > 0 ? 'Events ($eventsCount)' : 'Events',
    ];

    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: List.generate(tabs.length, (idx) {
          final isSelected = activeTab == idx;
          return Expanded(
            child: InkWell(
              onTap: () => onTabChanged(idx),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                alignment: Alignment.center,
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
                child: Text(
                  tabs[idx],
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF1E3C72)
                        : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
