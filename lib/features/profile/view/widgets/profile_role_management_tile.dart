import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_widgets.dart';

/// Navigation tile for Super Admins to manage organization roles and permissions.
class ProfileRoleManagementTile extends StatelessWidget {
  const ProfileRoleManagementTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.roleManagement);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const SquareRoundedGradientIcon(
                  icon: Icons.admin_panel_settings_rounded,
                  iconSize: 20,
                  boxSize: 38,
                  borderRadius: 10,
                  gradient: AppColors.brandGradient,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Role & Permission Matrix',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'Configure capabilities across all organization roles',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const GradientIcon(
                  icon: Icons.chevron_right_rounded,
                  size: 20,
                  gradient: AppColors.brandGradient,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
