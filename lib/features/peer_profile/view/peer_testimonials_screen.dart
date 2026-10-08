import 'package:flutter/material.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/widgets.dart';
import '../../peers/model/peer_model.dart';
import '../model/peer_profile_model.dart';

class PeerTestimonialsScreen extends StatelessWidget {
  final PeerModel peer;
  final List<PeerTestimonialModel> testimonials;

  const PeerTestimonialsScreen({
    super.key,
    required this.peer,
    required this.testimonials,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Testimonials',
        subtitle: peer.name,
        showBackButton: true,
      ),
      body: SafeArea(
        top: false,
        child: testimonials.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: testimonials.length,
                itemBuilder: (context, index) {
                  return _buildTestimonialCard(testimonials[index]);
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GradientBorderContainer(
              borderWidth: 1.8,
              borderRadius: 16,
              padding: const EdgeInsets.all(14),
              child: const GradientIcon(
                icon: Icons.star_border_rounded,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No testimonials yet',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'When members write a testimonial, it will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialCard(PeerTestimonialModel item) {
    final authorName = item.authorName.isNotEmpty
        ? item.authorName
        : 'Anonymous';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.6),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  authorName,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (item.date.isNotEmpty)
                Text(
                  item.date,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          if (item.content.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '"${item.content}"',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
                height: 1.35,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
