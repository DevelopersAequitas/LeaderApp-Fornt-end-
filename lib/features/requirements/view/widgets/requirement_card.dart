import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/requirement_model.dart';

class RequirementCard extends StatelessWidget {
  final RequirementModel requirement;
  final VoidCallback? onTap;

  const RequirementCard({
    super.key,
    required this.requirement,
    this.onTap,
  });

  void _navigateToPeer(BuildContext context) {
    Navigator.of(context).pushNamed(
      AppRoutes.peerProfile,
      arguments: requirement.toPeerModel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = requirement.status.toLowerCase() == 'open';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap ?? () => _navigateToPeer(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Peer Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InitialsAvatar(
                      name: requirement.peerName,
                      imageUrl: requirement.profileImage.isNotEmpty ? requirement.profileImage : null,
                      radius: 20,
                      backgroundColor: const Color(0xFF8B5CF6),
                      fontSize: 11,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  requirement.peerName,
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: isOpen
                                      ? const Color(0xFFF5F3FF)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isOpen
                                        ? const Color(0xFFDDD6FE)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Text(
                                  requirement.status.toUpperCase(),
                                  style: TextStyle(
                                    color: isOpen
                                        ? const Color(0xFF7C3AED)
                                        : AppColors.textSecondary,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            [
                              if (requirement.businessName.isNotEmpty) requirement.businessName,
                              if (requirement.city.isNotEmpty) requirement.city,
                              if (requirement.categoryLevel4.isNotEmpty) requirement.categoryLevel4,
                            ].join(' · '),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Requirement Details
                Text(
                  requirement.title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (requirement.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    requirement.description,
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.9),
                      fontSize: 11.5,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                // Footer
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'View Peer Profile',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
