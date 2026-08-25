import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Renders a Material 3 compact search bar and streamlined status & sort filters.
class PeersFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedStatus;
  final String selectedSort;
  final ValueChanged<String> onStatusSelected;
  final ValueChanged<String> onSortSelected;

  const PeersFilterBar({
    super.key,
    required this.searchController,
    required this.selectedStatus,
    required this.selectedSort,
    required this.onStatusSelected,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Compact Material 3 Search Field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF8B9CB4),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(fontSize: 13, color: AppColors.text),
                    decoration: const InputDecoration(
                      hintText: 'Search by name, company, circle...',
                      hintStyle: TextStyle(
                        color: Color(0xFF8B9CB4),
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: searchController,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return GestureDetector(
                      onTap: () => searchController.clear(),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF8B9CB4),
                        size: 16,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Status Filter Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
          child: Row(
            children: const ['All', 'Active', 'Needs Attention', 'At Risk']
                .map((status) {
              final isSelected =
                  selectedStatus.toLowerCase() == status.toLowerCase();
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: InkWell(
                  onTap: () => onStatusSelected(status),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1E3C72) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1E3C72)
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Sort Metric Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
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
                        fontWeight: FontWeight.w700,
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
                        color: isSelected
                            ? const Color(0xFFE2E8F0)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFCBD5E1)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        metric,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF0F172A)
                              : const Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
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
