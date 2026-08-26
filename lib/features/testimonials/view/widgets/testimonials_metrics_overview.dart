import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/testimonial_model.dart';

/// Overview summary banner displaying computed total endorsements, avg rating, and 5-star count.
class TestimonialsMetricsOverview extends StatelessWidget {
  final List<TestimonialModel> testimonials;

  const TestimonialsMetricsOverview({super.key, required this.testimonials});

  @override
  Widget build(BuildContext context) {
    final total = testimonials.length;
    final fiveStarCount = testimonials.where((t) => t.rating == 5).length;
    final avgRating = total > 0
        ? (testimonials.map((t) => t.rating).reduce((a, b) => a + b) / total)
            .toStringAsFixed(1)
        : '5.0';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              value: '$total',
              label: 'endorsements',
              valueColor: AppColors.primary,
              labelColor: AppColors.textSecondary,
              valueFontSize: 16,
              labelFontSize: 10,
              padding: EdgeInsets.zero,
            ),
          ),
          Container(width: 1, height: 28, color: AppColors.border),
          Expanded(
            child: StatCard(
              value: '$avgRating★',
              label: 'avg rating',
              valueColor: const Color(0xFFD97706),
              labelColor: AppColors.textSecondary,
              valueFontSize: 16,
              labelFontSize: 10,
              padding: EdgeInsets.zero,
            ),
          ),
          Container(width: 1, height: 28, color: AppColors.border),
          Expanded(
            child: StatCard(
              value: '$fiveStarCount',
              label: '5-star',
              valueColor: const Color(0xFF16A34A),
              labelColor: AppColors.textSecondary,
              valueFontSize: 16,
              labelFontSize: 10,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
