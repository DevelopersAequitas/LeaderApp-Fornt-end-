import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/profile_model.dart';

/// Renders the leader's contact details, bio, and official credentials card.
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

  void _copyToClipboard(BuildContext context, String label, String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E3C72),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (canEdit)
                InkWell(
                  onTap: onEditTap,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.edit_outlined,
                          size: 11,
                          color: Color(0xFF2563EB),
                        ),
                        SizedBox(width: 3),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context: context,
            icon: Icons.phone_outlined,
            label: 'Mobile Phone',
            value: profile.phone.isNotEmpty ? profile.phone : 'Not provided',
            onCopy: profile.phone.isNotEmpty
                ? () => _copyToClipboard(context, 'Phone number', profile.phone)
                : null,
          ),
          const Divider(color: AppColors.border, height: 16),
          _buildInfoRow(
            context: context,
            icon: Icons.mail_outline_rounded,
            label: 'Official Email',
            value: profile.email.isNotEmpty ? profile.email : 'Not provided',
            onCopy: profile.email.isNotEmpty
                ? () =>
                    _copyToClipboard(context, 'Email address', profile.email)
                : null,
          ),
          if (profile.company.isNotEmpty) ...[
            const Divider(color: AppColors.border, height: 16),
            _buildInfoRow(
              context: context,
              icon: Icons.business_outlined,
              label: 'Company / Organization',
              value: profile.company,
              onCopy: () =>
                  _copyToClipboard(context, 'Company name', profile.company),
            ),
          ],
          if (profile.id.isNotEmpty) ...[
            const Divider(color: AppColors.border, height: 16),
            _buildInfoRow(
              context: context,
              icon: Icons.badge_outlined,
              label: 'Leader ID',
              value: profile.id,
              onCopy: () => _copyToClipboard(context, 'Leader ID', profile.id),
            ),
          ],
          if (profile.bio.isNotEmpty) ...[
            const Divider(color: AppColors.border, height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EXECUTIVE BIO',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.bio,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
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
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F4F9),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: const Color(0xFF1E3C72), size: 16),
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
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (onCopy != null)
          IconButton(
            icon: const Icon(
              Icons.copy_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
            onPressed: onCopy,
            tooltip: 'Copy',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
      ],
    );
  }
}
