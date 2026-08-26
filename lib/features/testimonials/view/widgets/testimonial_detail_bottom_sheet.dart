import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../peers/model/peer_model.dart';
import '../../model/testimonial_model.dart';

/// Modal bottom sheet showing full endorsement details and profile navigation for both users.
class TestimonialDetailBottomSheet extends StatelessWidget {
  final TestimonialModel testimonial;

  const TestimonialDetailBottomSheet({super.key, required this.testimonial});

  static Future<void> show(
    BuildContext context, {
    required TestimonialModel testimonial,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => TestimonialDetailBottomSheet(testimonial: testimonial),
    );
  }

  void _navigateToPeer(
    BuildContext context, {
    required String peerId,
    required String name,
    required String company,
  }) {
    final peer = PeerModel(
      id: peerId,
      initials: name.length >= 2 ? name.substring(0, 2).toUpperCase() : 'PR',
      name: name,
      company: company,
      circle: '',
      location: '',
      tags: '',
      impactCount: 0,
      dealsFormatted: '₹0',
      coins: 0,
      attendance: '90%',
      status: 'Active',
    );
    Navigator.of(context).pushNamed(AppRoutes.peerProfile, arguments: peer);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Title & Rating
            Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Endorsement Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const Spacer(),
                StarRatingDisplay(
                  rating: testimonial.rating,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Both Users Visual Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  // Endorsed By (Author)
                  _buildUserTile(
                    context: context,
                    roleLabel: 'ENDORSED BY',
                    name: testimonial.fromName,
                    company: testimonial.fromCompany,
                    initials: testimonial.fromInitials,
                    peerId: testimonial.fromPeerId,
                    badgeColor: const Color(0xFF1E3C72),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.border)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.arrow_downward_rounded,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),
                  ),
                  // Endorsed To (Recipient)
                  _buildUserTile(
                    context: context,
                    roleLabel: 'ENDORSED TO',
                    name: testimonial.toName.isNotEmpty
                        ? testimonial.toName
                        : 'Circle Member',
                    company: testimonial.toCompany,
                    initials: testimonial.toInitials,
                    peerId: testimonial.toPeerId,
                    badgeColor: const Color(0xFF16A34A),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Testimonial Message
            const Text(
              'ENDORSEMENT MESSAGE',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: Text(
                '"${testimonial.content}"',
                style: const TextStyle(
                  color: Color(0xFF1E3C72),
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 13,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Endorsed on ${testimonial.date}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTile({
    required BuildContext context,
    required String roleLabel,
    required String name,
    required String company,
    required String initials,
    required String peerId,
    required Color badgeColor,
  }) {
    return Row(
      children: [
        InitialsAvatar(
          name: name,
          radius: 18,
          backgroundColor: badgeColor,
          fontSize: 11,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                roleLabel,
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                name,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (company.isNotEmpty) ...[
                Text(
                  company,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (peerId.isNotEmpty)
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              _navigateToPeer(
                context,
                peerId: peerId,
                name: name,
                company: company,
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
