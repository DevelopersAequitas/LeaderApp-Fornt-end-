import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/testimonial_model.dart';
import 'testimonial_detail_bottom_sheet.dart';

/// Renders a Material 3 peer testimonial card with endorsement quotes, star ratings, and both users' details.
class TestimonialCard extends StatelessWidget {
  final TestimonialModel testimonial;
  final VoidCallback? onTap;

  const TestimonialCard({
    super.key,
    required this.testimonial,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap ??
              () => TestimonialDetailBottomSheet.show(
                    context,
                    testimonial: testimonial,
                  ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Both Users Header Row
                Row(
                  children: [
                    // Author Avatar
                    InitialsAvatar(
                      name: testimonial.fromName,
                      radius: 17,
                      backgroundColor: const Color(0xFF1E3C72),
                      fontSize: 10,
                    ),
                    const SizedBox(width: 8),
                    // Author & Recipient Name Flow
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  testimonial.fromName,
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (testimonial.toName.isNotEmpty) ...[
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    testimonial.toName,
                                    style: const TextStyle(
                                      color: Color(0xFF1E3C72),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 1),
                          Text(
                            testimonial.toCompany.isNotEmpty
                                ? '${testimonial.fromCompany} · ${testimonial.toCompany}'
                                : testimonial.fromCompany,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    StarRatingDisplay(
                      rating: testimonial.rating,
                      size: 14,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Quoted Endorsement Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '"${testimonial.content}"',
                    style: TextStyle(
                      color: AppColors.text.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Date tag and Tap hint
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      testimonial.date,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'View details',
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 14,
                      color: Color(0xFF2563EB),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
