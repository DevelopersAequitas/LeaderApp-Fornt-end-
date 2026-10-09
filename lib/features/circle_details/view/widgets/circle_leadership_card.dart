import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../peers/model/peer_model.dart';
import '../../../teams/model/teams_model.dart';

class _LeaderItem {
  final CircleLeaderModel leader;
  final String roleBadge;
  final Color badgeBg;
  final Color badgeFg;

  const _LeaderItem({
    required this.leader,
    required this.roleBadge,
    required this.badgeBg,
    required this.badgeFg,
  });
}

/// Renders the Circle Leadership section placing all leaders in a single row
/// without a background container box, showing designation, company, and city details.
class CircleLeadershipCard extends StatelessWidget {
  final CircleTeamModel circle;

  const CircleLeadershipCard({super.key, required this.circle});

  @override
  Widget build(BuildContext context) {
    final items = <_LeaderItem>[];

    // Collect Chairs
    if (circle.chairs.isNotEmpty) {
      for (final c in circle.chairs) {
        items.add(_LeaderItem(
          leader: c,
          roleBadge: 'Chair',
          badgeBg: const Color(0xFFDCFCE7),
          badgeFg: const Color(0xFF16A34A),
        ));
      }
    } else if (circle.chairName.trim().isNotEmpty && circle.chairName != 'Unassigned') {
      items.add(_LeaderItem(
        leader: CircleLeaderModel(
          name: circle.chairName.trim(),
          role: 'Circle Chair',
          designation: 'Chairperson',
        ),
        roleBadge: 'Chair',
        badgeBg: const Color(0xFFDCFCE7),
        badgeFg: const Color(0xFF16A34A),
      ));
    }

    // Collect Founders
    if (circle.founders.isNotEmpty) {
      for (final f in circle.founders) {
        items.add(_LeaderItem(
          leader: f,
          roleBadge: 'Founder',
          badgeBg: const Color(0xFFFEF3C7),
          badgeFg: const Color(0xFFD97706),
        ));
      }
    } else if (circle.founderName.trim().isNotEmpty && circle.founderName != 'Unassigned') {
      items.add(_LeaderItem(
        leader: CircleLeaderModel(
          name: circle.founderName.trim(),
          role: 'Circle Founder',
          designation: 'Founder & CEO',
        ),
        roleBadge: 'Founder',
        badgeBg: const Color(0xFFFEF3C7),
        badgeFg: const Color(0xFFD97706),
      ));
    }

    // Collect Directors
    if (circle.directors.isNotEmpty) {
      for (final d in circle.directors) {
        items.add(_LeaderItem(
          leader: d,
          roleBadge: 'Director',
          badgeBg: const Color(0xFFEBF3FB),
          badgeFg: AppColors.primary,
        ));
      }
    } else if (circle.directorName.trim().isNotEmpty && circle.directorName != 'Unassigned') {
      items.add(_LeaderItem(
        leader: CircleLeaderModel(
          name: circle.directorName.trim(),
          role: 'Circle Director',
          designation: 'Managing Director',
        ),
        roleBadge: 'Director',
        badgeBg: const Color(0xFFEBF3FB),
        badgeFg: AppColors.primary,
      ));
    }

    // Ensure leadership team section is always populated and visible in a single row
    if (items.isEmpty) {
      final chairName =
          circle.chairName.trim().isNotEmpty ? circle.chairName.trim() : 'Circle Chair';
      final founderName = circle.founderName.trim().isNotEmpty
          ? circle.founderName.trim()
          : 'Circle Founder';
      final directorName = circle.directorName.trim().isNotEmpty
          ? circle.directorName.trim()
          : 'Circle Director';

      items.addAll([
        _LeaderItem(
          leader: CircleLeaderModel(
            name: chairName,
            role: 'Circle Chair',
            designation: 'Chairperson',
          ),
          roleBadge: 'Chair',
          badgeBg: const Color(0xFFDCFCE7),
          badgeFg: const Color(0xFF16A34A),
        ),
        _LeaderItem(
          leader: CircleLeaderModel(
            name: founderName,
            role: 'Circle Founder',
            designation: 'Founder & CEO',
          ),
          roleBadge: 'Founder',
          badgeBg: const Color(0xFFFEF3C7),
          badgeFg: const Color(0xFFD97706),
        ),
        _LeaderItem(
          leader: CircleLeaderModel(
            name: directorName,
            role: 'Circle Director',
            designation: 'Managing Director',
          ),
          roleBadge: 'Director',
          badgeBg: const Color(0xFFEBF3FB),
          badgeFg: AppColors.primary,
        ),
      ]);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Circle Leadership Team',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${items.length} Leaders',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Single row layout for leadership team
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildLeaderTile(context, item),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderTile(BuildContext context, _LeaderItem item) {
    final leader = item.leader;
    final initials = leader.name.trim().isNotEmpty
        ? leader.name
            .trim()
            .split(' ')
            .where((n) => n.isNotEmpty)
            .map((n) => n[0])
            .take(2)
            .join()
            .toUpperCase()
        : '?';

    final String designationText =
        (leader.designation != null && leader.designation!.isNotEmpty)
            ? leader.designation!
            : leader.role;

    final String companyText =
        (leader.company != null && leader.company!.isNotEmpty)
            ? leader.company!
            : circle.name;

    final String cityText =
        circle.location.isNotEmpty ? circle.location : 'Mumbai';

    return InkWell(
      onTap: () {
        final peer = PeerModel(
          id: leader.id.trim(),
          initials: initials,
          name: leader.name,
          avatarUrl: leader.avatarUrl,
          company: companyText,
          circle: circle.name,
          location: circle.location,
          tags: circle.category,
          impactCount: 0,
          dealsFormatted: '₹0',
          coins: 0,
          attendance: '90%',
          status: 'Active',
          phone: leader.phone ?? '',
          email: leader.email ?? '',
          designation: designationText,
        );
        Navigator.of(context).pushNamed(
          AppRoutes.peerProfile,
          arguments: peer,
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 148,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Role Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
              decoration: BoxDecoration(
                color: item.badgeBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.roleBadge,
                style: TextStyle(
                  color: item.badgeFg,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            // Avatar with subtle shadow
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InitialsAvatar(
                name: leader.name,
                imageUrl: leader.avatarUrl,
                radius: 22,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            // Name
            Text(
              leader.name,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            // Designation
            Text(
              designationText,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 3),
            // Company Name
            Text(
              companyText,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // City / Location
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 10,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    cityText,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
