import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../peers/model/peer_model.dart';

/// Renders the top Hero Card for Peer Profile with luxury gradient, badges, and details.
class PeerProfileHeroCard extends StatelessWidget {
  final PeerModel peer;

  const PeerProfileHeroCard({super.key, required this.peer});

  Color _getStatusBg(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFFDCFCE7);
      case 'at risk':
        return const Color(0xFFFEE2E2);
      case 'needs attention':
        return const Color(0xFFFEF3C7);
      case 'pending':
        return const Color(0xFFE0E7FF);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF16A34A);
      case 'at risk':
        return const Color(0xFFDC2626);
      case 'needs attention':
        return const Color(0xFFD97706);
      case 'pending':
        return const Color(0xFF4F46E5);
      default:
        return const Color(0xFF4B5563);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBg = _getStatusBg(peer.status);
    final statusText = _getStatusText(peer.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Dark Luxury Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(17),
                topRight: Radius.circular(17),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Image with fallback initials
                    InitialsAvatar(
                      name: peer.name,
                      imageUrl: peer.avatarUrl,
                      radius: 26,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      fontSize: 16,
                    ),
                    const SizedBox(width: 12),
                    // Name & Designation/Company
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  peer.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (peer.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF60A5FA),
                                  size: 16,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            peer.designation != null &&
                                    peer.designation!.isNotEmpty
                                ? '${peer.designation} · ${peer.company}'
                                : peer.company,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Badges row
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    // Impact badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lightbulb_outline_rounded,
                            color: Colors.white,
                            size: 11,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${peer.impactCount} Lives Impacted',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        peer.status,
                        style: TextStyle(
                          color: statusText,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    // Circle Badge
                    if (peer.circle.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          peer.circle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Details Rows
          _buildDetailRow(
            icon: Icons.corporate_fare_outlined,
            label: 'CIRCLE',
            value: peer.circle,
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildDetailRow(
            icon: Icons.location_on_outlined,
            label: 'CITY',
            value: peer.location,
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildDetailRow(
            icon: Icons.local_offer_outlined,
            label: 'INDUSTRY / SPECIALIZATION',
            value: peer.industry != null && peer.industry!.isNotEmpty
                ? peer.industry!
                : peer.tags,
          ),
          if (peer.phone != null && peer.phone!.isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.border),
            _buildDetailRow(
              icon: Icons.phone_outlined,
              label: 'PHONE',
              value: peer.phone!,
            ),
          ],
          if (peer.email != null && peer.email!.isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.border),
            _buildDetailRow(
              icon: Icons.email_outlined,
              label: 'EMAIL',
              value: peer.email!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF1E3C72), size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : '—',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
