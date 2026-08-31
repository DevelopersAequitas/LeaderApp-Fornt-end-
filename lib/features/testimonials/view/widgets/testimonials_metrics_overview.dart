import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/testimonial_model.dart';

/// Overview summary banner displaying total testimonials count.
class TestimonialsMetricsOverview extends StatelessWidget {
  final List<TestimonialModel> testimonials;

  const TestimonialsMetricsOverview({super.key, required this.testimonials});

  @override
  Widget build(BuildContext context) {
    final total = testimonials.length;

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
              label: 'TESTIMONIALS',
              valueColor: AppColors.primary,
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
