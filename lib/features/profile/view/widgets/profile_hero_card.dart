import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/profile_model.dart';

/// Clean executive hero card for the leader profile with name, city, designation, company, level 4 category, and lives impacted.
class ProfileHeroCard extends StatelessWidget {
  final UserProfileModel profile;

  const ProfileHeroCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final companyName = profile.companyName.isNotEmpty
        ? profile.companyName
        : profile.company;
    final cityName = profile.city.isNotEmpty ? profile.city : profile.location;
    final level4 = profile.level4Category.isNotEmpty
        ? profile.level4Category
        : (profile.industry.isNotEmpty
            ? profile.industry
            : profile.businessCategory);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A192B), // Deep Midnight Navy
            AppColors.primary, // #102640 Brand Primary Navy
            Color(0xFF1B3C66), // Rich Executive Indigo
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar on Left + Details on Right
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with Online Health Indicator
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  InitialsAvatar(
                    name: profile.name.toUpperCase(),
                    imageUrl: profile.avatarUrl,
                    radius: 36,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    fontSize: 20,
                  ),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.healthGreen,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0A192B),
                        width: 2.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // User Info Breakdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        profile.roleLabel.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF16A34A),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Full Name (Uppercase, max w500)
                    Text(
                      profile.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Designation & Company Name
                    if (profile.designation.isNotEmpty ||
                        companyName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        profile.designation.isNotEmpty && companyName.isNotEmpty
                            ? '${profile.designation} · $companyName'
                            : (profile.designation.isNotEmpty
                                ? profile.designation
                                : companyName),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // City Location
                    if (cityName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              cityName,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Level 4 Category (with clean business center icon)
                    if (level4.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.business_center_outlined,
                            size: 13,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              level4,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(
            color: Colors.white.withValues(alpha: 0.12),
            height: 1,
          ),
          const SizedBox(height: 14),

          // Primary Metrics: "Lives Impacted" and "Circles"
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.favorite_rounded,
                  label: 'Lives Impacted',
                  value: '${profile.lifeImpact}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.groups_rounded,
                  label: 'Circles',
                  value: '${profile.managedCircles.length}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
