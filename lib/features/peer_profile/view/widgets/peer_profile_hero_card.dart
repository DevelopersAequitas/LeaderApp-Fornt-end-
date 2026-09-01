import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../peers/model/peer_model.dart';

/// Renders the luxury dark hero banner for Peer Profile with mandatory key peer information:
/// 1. Peer Profile Name (Uppercase, max w500 font weight)
/// 2. City / Location
/// 3. Designation
/// 4. Company Name
/// 5. Category (Level 4 Category / Specialization)
/// 6. Lives Impacted Count
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

    final displayCategory = peer.level4Category != null &&
            peer.level4Category!.trim().isNotEmpty
        ? peer.level4Category!.trim()
        : (peer.tags.isNotEmpty
            ? peer.tags
            : (peer.industry ?? 'Specialist'));

    final displayDesignation = peer.designation != null &&
            peer.designation!.trim().isNotEmpty
        ? peer.designation!.trim()
        : '';
    final displayCompany = peer.company.trim();

    String subtitle = '';
    if (displayDesignation.isNotEmpty && displayCompany.isNotEmpty) {
      subtitle = '$displayDesignation · $displayCompany';
    } else if (displayDesignation.isNotEmpty) {
      subtitle = displayDesignation;
    } else {
      subtitle = displayCompany;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A192B), // Brand Deep Midnight #0A192B
            AppColors.primary, // Brand Primary Navy #102640
            Color(0xFF1B3C66), // Executive Blue #1B3C66
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with image / initials fallback
              InitialsAvatar(
                name: peer.name.toUpperCase(),
                imageUrl: peer.avatarUrl,
                radius: 28,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                fontSize: 16,
              ),
              const SizedBox(width: 12),
              // Name (Uppercase, max w500), Verified Badge, Designation & Company Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            peer.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (peer.isVerified) ...[
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF60A5FA),
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Status Pill
              if (peer.status.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    peer.status,
                    style: TextStyle(
                      color: statusText,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          // Badges Row: Lives Impacted, Level 4 Category & City
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              // 1. Lives Impacted Count
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${peer.impactCount} Lives Impacted',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // 2. Level 4 Category / Specialization
              if (displayCategory.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          displayCategory,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              // 3. City / Location
              if (peer.location.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        peer.location,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
