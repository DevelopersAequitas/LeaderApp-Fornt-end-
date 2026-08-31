import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/expandable_text.dart';
import '../../../testimonials/model/testimonial_model.dart';
import '../../../testimonials/view/widgets/testimonial_detail_bottom_sheet.dart';
import '../../model/peer_profile_model.dart';

/// Renders the Testimonials tab list for Peer Profile.
class PeerProfileTestimonialsSection extends StatelessWidget {
  final List<PeerTestimonialModel> testimonials;

  const PeerProfileTestimonialsSection({
    super.key,
    required this.testimonials,
  });

  @override
  Widget build(BuildContext context) {
    if (testimonials.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            'No testimonials submitted yet.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      children: testimonials
          .map((test) => _buildTestimonialCard(context, test))
          .toList(),
    );
  }

  Widget _buildTestimonialCard(
    BuildContext context,
    PeerTestimonialModel testimonial,
  ) {
    void openDetails() {
      final tModel = TestimonialModel(
        id: testimonial.id,
        authorName: testimonial.authorName,
        authorRole: testimonial.subtitle,
        targetPeerName: '',
        circleName: '',
        authorInitials: testimonial.authorInitials,
        targetPeerInitials: '',
        content: testimonial.content,
        date: testimonial.date.isNotEmpty ? testimonial.date : 'Recent',
      );
      TestimonialDetailBottomSheet.show(context, testimonial: tModel);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          onTap: openDetails,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        testimonial.authorInitials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            testimonial.authorName,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (testimonial.subtitle.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            Text(
                              testimonial.subtitle,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (testimonial.date.isNotEmpty)
                      Text(
                        testimonial.date,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ExpandableText(
                  text: '"${testimonial.content}"',
                  maxLines: 2,
                  onReadMoreTap: openDetails,
                  style: TextStyle(
                    color: AppColors.text.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
