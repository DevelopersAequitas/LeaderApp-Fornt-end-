import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/teams_model.dart';

/// Renders a horizontal scrollable row of dynamic industry filter chips.
class TeamsIndustryFilterChips extends StatelessWidget {
  final List<String> industries;
  final List<CircleTeamModel> allCircles;
  final String selectedIndustry;
  final ValueChanged<String> onIndustrySelected;

  const TeamsIndustryFilterChips({
    super.key,
    required this.industries,
    required this.allCircles,
    required this.selectedIndustry,
    required this.onIndustrySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: industries.map((ind) {
          final isSelected = selectedIndustry == ind;
          final count = allCircles
              .where(
                (c) =>
                    c.category.toLowerCase().trim() == ind.toLowerCase().trim(),
              )
              .length;
          final label = ind == 'All Industries' ? ind : '$ind ($count)';

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => onIndustrySelected(ind),
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
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
