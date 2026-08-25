import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Renders the section title alongside a compact segmented status filter (All, Active, At Risk).
class TeamsStatusFilterHeader extends StatelessWidget {
  final String title;
  final String selectedStatus;
  final ValueChanged<String> onStatusSelected;

  const TeamsStatusFilterHeader({
    super.key,
    required this.title,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: ['All', 'Active', 'At Risk'].map((status) {
                final isSelected =
                    selectedStatus.toLowerCase() == status.toLowerCase();
                return InkWell(
                  onTap: () => onStatusSelected(status),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF1E3C72)
                            : const Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
