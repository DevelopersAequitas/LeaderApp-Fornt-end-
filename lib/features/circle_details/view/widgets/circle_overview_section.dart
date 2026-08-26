import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../teams/model/teams_model.dart';

/// Renders the Overview tab content for Circle Details.
class CircleOverviewSection extends StatelessWidget {
  final CircleTeamModel circle;

  const CircleOverviewSection({super.key, required this.circle});

  @override
  Widget build(BuildContext context) {
    final hasHealthData = circle.healthPercentage > 0;
    final isAtRisk = circle.healthPercentage < 70 && hasHealthData;
    final healthColor = !hasHealthData
        ? Colors.grey
        : (isAtRisk ? const Color(0xFFE53935) : const Color(0xFF16A34A));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Health & Performance',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _buildHealthProgressBar(
            'Overall Circle Health',
            circle.healthPercentage,
            healthColor,
          ),
          if (!hasHealthData) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondaryBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Newly formed circle. Health and performance metrics will populate once initial sessions and member transactions are logged.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (circle.tags.isNotEmpty) ...[
            const Text(
              'Sub-Industry Specializations',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: circle.tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Color(0xFF1E3C72),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildHealthProgressBar(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '$value%',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / 100,
            color: color,
            backgroundColor: AppColors.secondaryBg,
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}
