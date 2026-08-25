import 'package:flutter/material.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/profile_model.dart';

/// Renders the executive dark hero card for the leader profile.
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
          colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3C72).withValues(alpha: 0.15),
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
                radius: 34,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.5,
                ),
                fontSize: 22,
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF1E3C72),
                    width: 2.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Leader Name
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
          // Role Badge
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
          const SizedBox(height: 16),
          // 3-Metric Strip
          Row(
            children: [
              Expanded(
                child: _buildQuickStatTile('SCOPE', profile.regionalScope),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickStatTile(
                  'PERMISSIONS',
                  '${profile.capabilitiesCount} Active',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickStatTile('SINCE', profile.memberSince),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
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
