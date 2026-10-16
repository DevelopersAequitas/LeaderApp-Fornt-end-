import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Filter chips for circle scope, report types, and statuses.
class ReportsHistoryFilters extends StatelessWidget {
  final String filterType;
  final String filterStatus;
  final String selectedCircle;
  final List<String> availableCircles;
  final ValueChanged<String>? onFilterTypeChanged;
  final ValueChanged<String>? onFilterStatusChanged;
  final ValueChanged<String>? onCircleChanged;

  const ReportsHistoryFilters({
    super.key,
    required this.filterType,
    required this.filterStatus,
    this.selectedCircle = '',
    this.availableCircles = const [],
    this.onFilterTypeChanged,
    this.onFilterStatusChanged,
    this.onCircleChanged,
  });

  Widget _buildChipRow({
    required List<String> items,
    required String selected,
    required ValueChanged<String>? onSelected,
    bool isCircle = false,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          final isSelected = selected.toLowerCase() == item.toLowerCase();
          final label = (!isCircle && item == 'all') ? 'All' : item;

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => onSelected?.call(item),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: (isSelected && !isCircle) ? AppColors.brandGradient : null,
                  color: isSelected
                      ? (isCircle ? const Color(0xFFEBF3FB) : null)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? (isCircle ? AppColors.primary : Colors.transparent)
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? (isCircle ? AppColors.primary : Colors.white)
                        : AppColors.text,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const typeFilters = ['all', 'Monthly', 'Weekly', 'Quarterly', 'Annual'];
    const statusFilters = ['all', 'Approved', 'Draft'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (availableCircles.length > 1) ...[
            _buildChipRow(
              items: availableCircles,
              selected: selectedCircle.isNotEmpty ? selectedCircle : 'All Circles',
              onSelected: onCircleChanged,
              isCircle: true,
            ),
            const SizedBox(height: 6),
          ],
          _buildChipRow(
            items: typeFilters,
            selected: filterType,
            onSelected: onFilterTypeChanged,
          ),
          const SizedBox(height: 6),
          _buildChipRow(
            items: statusFilters,
            selected: filterStatus,
            onSelected: onFilterStatusChanged,
            isCircle: true,
          ),
        ],
      ),
    );
  }
}
