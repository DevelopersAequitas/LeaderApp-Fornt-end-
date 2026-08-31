import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/profile_model.dart';

/// Renders the Assigned Circles and Territory card for the leader.
class ProfileAssignedCirclesCard extends StatelessWidget {
  final UserProfileModel profile;

  const ProfileAssignedCirclesCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final circles = profile.managedCircles;

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
                Icons.hub_outlined,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'Assigned Circles & Territory',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${circles.length} ${circles.length == 1 ? 'Circle' : 'Circles'}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (circles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Text(
                'National Scope – All circles accessible.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            ...circles.map((circleName) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      InitialsAvatar(
                        name: circleName,
                        radius: 15,
                        backgroundColor: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                        fontSize: 10,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              circleName,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 1),
                            const Text(
                              'Active Leadership Assignment',
                              style: TextStyle(
                                color: Color(0xFF16A34A),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
