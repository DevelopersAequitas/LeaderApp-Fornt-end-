import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/profile_model.dart';

/// MD3-styled luxury hero card for the leader profile with high-res avatar and role badge.
class ProfileHeroCard extends StatelessWidget {
  final UserProfileModel profile;

  const ProfileHeroCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary, // #102640 Brand Primary Navy
            Color(0xFF1A3860), // Harmonized Executive Blue
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          // Avatar with Active Indicator
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              InitialsAvatar(
                name: profile.name,
                imageUrl: profile.avatarUrl,
                radius: 34,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.5,
                ),
                fontSize: 22,
              ),
              Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  color: AppColors.healthGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF102640), width: 2.0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            profile.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          if (profile.company.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              profile.company,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              profile.roleLabel.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF16A34A),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildStatTile('REGIONAL SCOPE', profile.regionalScope),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatTile('MEMBER SINCE', profile.memberSince),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
