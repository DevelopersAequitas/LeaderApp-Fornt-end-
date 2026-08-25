import 'package:flutter/material.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

/// Renders the role assignment controls card for executive leadership roles.
class PeerRoleManagementSection extends StatelessWidget {
  const PeerRoleManagementSection({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRole = SessionManager().currentRole;
    final isSuperAdmin = currentRole == UserRole.superAdmin;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
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
          const Row(
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                color: Color(0xFF1E3C72),
                size: 18,
              ),
              SizedBox(width: 6),
              Text(
                'Role Management',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Circle Founder role cannot be changed once assigned.',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          _buildRoleRow(
            context,
            'Change Chair (per circle)',
            () => Navigator.of(context).pushNamed(AppRoutes.roleManagement),
          ),
          const SizedBox(height: 6),
          _buildRoleRow(
            context,
            'Change Circle Director',
            () => Navigator.of(context).pushNamed(AppRoutes.roleManagement),
          ),
          if (isSuperAdmin) ...[
            const SizedBox(height: 6),
            _buildRoleRow(
              context,
              'Change Industry Director',
              () => Navigator.of(context).pushNamed(AppRoutes.roleManagement),
            ),
            const SizedBox(height: 6),
            _buildRoleRow(
              context,
              'Change District Exec',
              () => Navigator.of(context).pushNamed(AppRoutes.roleManagement),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoleRow(
    BuildContext context,
    String label,
    VoidCallback onManage,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          InkWell(
            onTap: onManage,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Manage',
                style: TextStyle(
                  color: Color(0xFF1E3C72),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
