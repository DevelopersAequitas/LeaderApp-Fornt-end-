import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/teams_model.dart';

/// Renders an individual circle summary card adhering to Material 3 principles.
class TeamsCircleCard extends StatelessWidget {
  final CircleTeamModel circle;

  const TeamsCircleCard({super.key, required this.circle});

  @override
  Widget build(BuildContext context) {
    final isActive = circle.status.toLowerCase() == 'active';
    final progressColor =
        isActive ? const Color(0xFF16A34A) : const Color(0xFFD97706);
    final statusBgColor =
        isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
    final statusTextColor =
        isActive ? const Color(0xFF15803D) : const Color(0xFFB91C1C);

    final String metaLocation =
        circle.location.isNotEmpty ? ' · ${circle.location}' : '';

    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.circleDetails, arguments: circle);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    circle.name,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    circle.status,
                    style: TextStyle(
                      color: statusTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '${circle.category}$metaLocation',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: circle.healthPercentage / 100,
                color: progressColor,
                backgroundColor: const Color(0xFFF1F5F9),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${circle.peersCount} peers · ${circle.healthPercentage}% health',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  circle.revenue,
                  style: TextStyle(
                    color: progressColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            if (circle.tags.isNotEmpty) ...[
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: circle.tags.map((tag) {
                    return Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 8),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRoleItem(
                  name:
                      circle.founderName.isNotEmpty ? circle.founderName : '—',
                  role: 'Founder',
                  isFounder: true,
                ),
                _buildRoleItem(
                  name: circle.directorName.isNotEmpty
                      ? circle.directorName
                      : '—',
                  role: 'Director',
                ),
                _buildRoleItem(
                  name: circle.chairName.isNotEmpty ? circle.chairName : '—',
                  role: 'Chair',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleItem({
    required String name,
    required String role,
    bool isFounder = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            name,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                role,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isFounder) ...[
                const SizedBox(width: 3),
                Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.grey.shade400,
                  size: 9,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
