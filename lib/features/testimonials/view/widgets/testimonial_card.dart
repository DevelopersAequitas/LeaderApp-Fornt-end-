import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/testimonial_model.dart';
import 'testimonial_detail_bottom_sheet.dart';

/// Renders a Material 3 peer testimonial card showing Given By, Received By, Circle, and testimonial quote.
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
    void openDetails() {
      TestimonialDetailBottomSheet.show(
        context,
        testimonial: testimonial,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap ?? openDetails,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Author & Recipient
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author Avatar
                    InitialsAvatar(
                      name: testimonial.authorName,
                      radius: 20,
                      backgroundColor: AppColors.primary,
                      fontSize: 11,
                    ),
                    const SizedBox(width: 10),
                    // Author & Recipient Flow
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  testimonial.authorName,
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (testimonial.targetPeerName.isNotEmpty) ...[
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
                                    testimonial.targetPeerName,
                                    style: const TextStyle(
                                      color: AppColors.primary,
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
                          const SizedBox(height: 2),
                          Text(
                            [
                              if (testimonial.authorRole.isNotEmpty)
                                testimonial.authorRole,
                              if (testimonial.circleName.isNotEmpty)
                                testimonial.circleName,
                            ].join(' · '),
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
                  ],
                ),
                const SizedBox(height: 10),
                // Quoted Testimonial Message Box (with Read more opening details)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ExpandableText(
                    text: '"${testimonial.content}"',
                    maxLines: 2,
                    onReadMoreTap: openDetails,
                    style: TextStyle(
                      color: AppColors.text.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Date tag & Tap hint
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
                    InkWell(
                      onTap: openDetails,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View details',
                            style: TextStyle(
                              color: Color(0xFF1E6091),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 14,
                            color: Color(0xFF1E6091),
                          ),
                        ],
                      ),
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
