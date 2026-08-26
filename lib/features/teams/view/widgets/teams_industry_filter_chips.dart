import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/teams_model.dart';

/// Renders a horizontal scrollable row of dynamic industry filter chips directly from live API.
class TeamsIndustryFilterChips extends StatelessWidget {
  final List<String> industries;
  final List<IndustryModel> industriesList;
  final List<CircleTeamModel> allCircles;
  final String selectedIndustry;
  final ValueChanged<String> onIndustrySelected;

  const TeamsIndustryFilterChips({
    super.key,
    required this.industries,
    this.industriesList = const [],
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
          final matchedModel = industriesList.firstWhere(
            (item) => item.name.toLowerCase().trim() == ind.toLowerCase().trim(),
            orElse: () => IndustryModel(id: '', name: ind, slug: '', iconUrl: ''),
          );

          final count = allCircles
              .where(
                (c) =>
                    c.category.toLowerCase().trim() == ind.toLowerCase().trim(),
              )
              .length;

          final label = ind == 'All Industries' ? ind : (count > 0 ? '$ind ($count)' : ind);
          final iconUrl = matchedModel.iconUrl;

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
                  boxShadow: [
                    if (!isSelected)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.015),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (ind == 'All Industries') ...[
                      Icon(
                        Icons.apps_rounded,
                        size: 13,
                        color: isSelected ? Colors.white : const Color(0xFF1E3C72),
                      ),
                      const SizedBox(width: 5),
                    ] else if (iconUrl.isNotEmpty) ...[
                      Image.network(
                        iconUrl,
                        width: 14,
                        height: 14,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.business_rounded,
                          size: 13,
                          color: isSelected ? Colors.white70 : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
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

