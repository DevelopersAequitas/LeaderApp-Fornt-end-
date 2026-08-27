import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/role_permission_model.dart';

/// MD3-styled soft header card presenting selected role status and controls.
class RoleHeaderCard extends StatelessWidget {
  final RolePermissionModel rolePermission;
  final int totalCapabilities;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleAll;

  const RoleHeaderCard({
    super.key,
    required this.rolePermission,
    required this.totalCapabilities,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAll,
  });

  IconData _getHeaderIcon(String label) {
    final l = label.toLowerCase();
    if (l.contains('business growth')) return Icons.trending_up_rounded;
    if (l.contains('membership')) return Icons.group_outlined;
    if (l.contains('events')) return Icons.event_note_outlined;
    if (l.contains('founder')) return Icons.lightbulb_outline_rounded;
    if (l.contains('director')) return Icons.business_center_outlined;
    if (l.contains('admin')) return Icons.admin_panel_settings_outlined;
    return Icons.verified_user_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final enabledCount = rolePermission.enabledCapabilityIds.length;
    final progress = totalCapabilities > 0 ? enabledCount / totalCapabilities : 0.0;
    final isAllEnabled = totalCapabilities > 0 && enabledCount == totalCapabilities;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: rolePermission.role.isSystemRole
                      ? AppColors.selectionBg
                      : AppColors.successLightBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getHeaderIcon(rolePermission.role.label),
                  color: rolePermission.role.isSystemRole ? AppColors.primary : AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            rolePermission.role.label,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border, width: 0.6),
                          ),
                          child: Text(
                            rolePermission.role.isSystemRole ? 'SYSTEM' : 'CUSTOM',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$enabledCount of $totalCapabilities capabilities granted (${(progress * 100).toInt()}%)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.info),
                onPressed: onEdit,
                tooltip: 'Rename Role',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
              ),
              if (!rolePermission.role.isSystemRole) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                  onPressed: onDelete,
                  tooltip: 'Delete Role',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppColors.progressBg,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.6 ? AppColors.success : (progress > 0.3 ? AppColors.warning : AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Full Role Access (Enable All)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: isAllEnabled,
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.2),
                  inactiveThumbColor: AppColors.disabled,
                  inactiveTrackColor: AppColors.border,
                  onChanged: onToggleAll,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
