import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/profile_model.dart';

/// Peers Global styled Executive Profile Header Card for the Leader App.
/// Matches the clean, modern card layout from Peers Global:
/// - Default cover banner with brand gradient tint & subtle app crest
/// - Overlapping circular avatar (68px) with white boundary ring
/// - Leader name (uppercase), verification badge, and role pill
/// - Designation & company with business center icon
/// - Business category / Level 4 category with gradient text mask
/// - Location & regional scope badges
/// - Note: Edit button and role metrics are commented out per user request.
class ProfileHeroCard extends StatelessWidget {
  final UserProfileModel profile;

  const ProfileHeroCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final companyName = profile.companyName.isNotEmpty
        ? profile.companyName
        : profile.company;
    final cityName = profile.city.isNotEmpty ? profile.city : profile.location;
    final categoryText = profile.level4Category.isNotEmpty
        ? profile.level4Category
        : (profile.industry.isNotEmpty
            ? profile.industry
            : profile.businessCategory);

    final workList = [
      if (profile.designation.isNotEmpty) profile.designation,
      if (companyName.isNotEmpty) companyName,
    ];
    final workText = workList.join(' • ');

    final avatarUrl = profile.avatarUrl.isNotEmpty
        ? profile.avatarUrl
        : profile.profilePhotoUrl;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner & Overlapping Avatar Stack (Matches Peers Global ProfileHeaderCard)
          SizedBox(
            height: 148,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Top Cover Banner
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 110,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: _buildDefaultCover(),
                  ),
                ),

                // Overlapping Avatar on Left
                Positioned(
                  left: 16,
                  top: 72,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: InitialsAvatar(
                      name: profile.name.toUpperCase(),
                      imageUrl: avatarUrl,
                      radius: 34, // 68px diameter matching Peers Global
                      backgroundColor: AppColors.secondaryBg,
                      border: Border.all(
                        color: AppColors.border,
                        width: 1.0,
                      ),
                      fontSize: 18,
                    ),
                  ),
                ),

                // =====================================================================
                // Camera photo edit button - Commented out per user request
                // =====================================================================
                // Positioned(
                //   bottom: 0,
                //   right: 0,
                //   child: Container(
                //     padding: const EdgeInsets.all(5),
                //     decoration: BoxDecoration(
                //       gradient: AppColors.brandGradient,
                //       shape: BoxShape.circle,
                //     ),
                //     child: const Icon(Icons.camera_alt_outlined, size: 12, color: Colors.white),
                //   ),
                // ),

                // =====================================================================
                // Edit Profile action button - Commented out per user request
                // =====================================================================
                // Positioned(
                //   right: 14,
                //   bottom: 2,
                //   child: _buildEditProfileBtn(context),
                // ),
              ],
            ),
          ),

          // User Information Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Verified Badge + Role Badge Row
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                          color: AppColors.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 6),
                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.selectionBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.primaryBlue.withValues(alpha: 0.25),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        profile.roleLabel.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),

                // Designation & Company Name
                if (workText.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.business_center_outlined,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          workText,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // Business Category / Level 4 category (with gradient mask matching Peers Global)
                if (categoryText.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const GradientIcon(
                        icon: Icons.sell_outlined,
                        size: 13,
                        gradient: AppColors.brandGradient,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: GradientText(
                          categoryText,
                          gradient: AppColors.brandGradient,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // Location & Regional Scope
                if (cityName.isNotEmpty || profile.regionalScope.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (cityName.isNotEmpty) ...[
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            cityName,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      if (cityName.isNotEmpty &&
                          profile.regionalScope.isNotEmpty) ...[
                        const Text(
                          '  •  ',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (profile.regionalScope.isNotEmpty) ...[
                        const Icon(
                          Icons.public_rounded,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            profile.regionalScope,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],

                // Member Tenure
                if (profile.memberSince.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Member since ${profile.memberSince}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
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

          // =========================================================================
          // Role Metrics Section (Lives Impacted, Circles, etc.) - Commented out per user request
          // =========================================================================
          // const SizedBox(height: 10),
          // const Divider(color: AppColors.border, height: 1),
          // Padding(
          //   padding: const EdgeInsets.all(12),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: _buildMetricTile(
          //           icon: Icons.favorite_rounded,
          //           label: 'Lives Impacted',
          //           value: '${profile.lifeImpact}',
          //         ),
          //       ),
          //       const SizedBox(width: 12),
          //       Expanded(
          //         child: _buildMetricTile(
          //           icon: Icons.groups_rounded,
          //           label: 'Circles',
          //           value: '${profile.managedCircles.length}',
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1D4ED8).withValues(alpha: 0.15),
            const Color(0xFFE11D48).withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: 0.85,
          child: Image.asset(
            'assets/icons/AppIcon.png',
            width: 44,
            height: 44,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(
              Icons.shield_outlined,
              size: 32,
              color: Color(0xFF1D4ED8),
            ),
          ),
        ),
      ),
    );
  }
}
