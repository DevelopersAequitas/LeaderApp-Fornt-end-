import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/profile_model.dart';

/// Clean contact details and executive bio card for the leader profile without duplicate fields or copy buttons.
class ProfileContactCard extends StatelessWidget {
  final UserProfileModel profile;
  final VoidCallback onEditTap;
  final bool canEdit;

  const ProfileContactCard({
    super.key,
    required this.profile,
    required this.onEditTap,
    this.canEdit = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title & Edit Button
          Row(
            children: [
              const Icon(
                Icons.contact_mail_outlined,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Contact & Details',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (canEdit)
                InkWell(
                  onTap: onEditTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.selectionBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 1. Mobile Phone (without copy button)
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Mobile Phone',
            value: profile.phone.isNotEmpty ? profile.phone : 'Not provided',
          ),
          const Divider(color: AppColors.border, height: 14),

          // 2. Official Email (without copy button)
          _buildInfoRow(
            icon: Icons.mail_outline_rounded,
            label: 'Official Email',
            value: profile.email.isNotEmpty ? profile.email : 'Not provided',
          ),

          // 3. Executive Bio (if present)
          if (profile.bio.isNotEmpty) ...[
            const Divider(color: AppColors.border, height: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EXECUTIVE BIO',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.bio,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.secondaryBg,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.primary, size: 15),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
