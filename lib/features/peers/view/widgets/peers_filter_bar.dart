import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Renders streamlined sort metric chips for the Peers tab.
class PeersFilterBar extends StatelessWidget {
  final TextEditingController? searchController;
  final String? selectedStatus;
  final String selectedSort;
  final ValueChanged<String>? onStatusSelected;
  final ValueChanged<String> onSortSelected;
  final ValueChanged<String>? onSearchChanged;

  const PeersFilterBar({
    super.key,
    this.searchController,
    this.selectedStatus,
    required this.selectedSort,
    this.onStatusSelected,
    required this.onSortSelected,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sort Metric Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sort_rounded,
                      size: 14,
                      color: Color(0xFF8B9CB4),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Sort:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8B9CB4),
                      ),
                    ),
                  ],
                ),
              ),
              ...const ['Impact', 'Deals', 'Coins', 'Attendance'].map((metric) {
                final isSelected =
                    selectedSort.toLowerCase() == metric.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: InkWell(
                    onTap: () => onSortSelected(metric),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.brandGradient : null,
                        color: isSelected
                            ? null
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        metric,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
