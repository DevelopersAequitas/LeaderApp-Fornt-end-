import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_widgets.dart';
import '../../model/role_permission_model.dart';

/// MD3-styled smooth horizontal role selector bar.
class RoleSelectorBar extends StatelessWidget {
  final List<RolePermissionModel> rolesPermissions;
  final String selectedRoleId;
  final ValueChanged<String> onSelectRole;
  final VoidCallback onAddRole;

  const RoleSelectorBar({
    super.key,
    required this.rolesPermissions,
    required this.selectedRoleId,
    required this.onSelectRole,
    required this.onAddRole,
  });

  IconData _getRoleIcon(RoleModel role) {
    final label = role.label.toLowerCase();
    if (label.contains('business growth')) return Icons.trending_up_rounded;
    if (label.contains('membership')) return Icons.group_outlined;
    if (label.contains('events')) return Icons.event_note_outlined;
    if (label.contains('founder')) return Icons.lightbulb_outline_rounded;
    if (label.contains('director')) return Icons.business_center_outlined;
    if (label.contains('admin')) return Icons.admin_panel_settings_outlined;
    return role.isSystemRole ? Icons.shield_outlined : Icons.tune_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            ...rolesPermissions.map((rp) {
              final isSelected = rp.role.id == selectedRoleId;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: () => onSelectRole(rp.role.id),
                    borderRadius: BorderRadius.circular(24),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.brandGradient : null,
                        color: isSelected ? null : AppColors.secondaryBg,
                        borderRadius: BorderRadius.circular(24),
                        border: isSelected
                            ? null
                            : Border.all(
                                color: AppColors.border,
                                width: 0.8,
                              ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.28),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          isSelected
                              ? Icon(
                                  _getRoleIcon(rp.role),
                                  size: 15,
                                  color: Colors.white,
                                )
                              : GradientIcon(
                                  icon: _getRoleIcon(rp.role),
                                  size: 15,
                                  gradient: AppColors.brandGradient,
                                ),
                          const SizedBox(width: 7),
                          Text(
                            rp.role.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                              color: isSelected ? Colors.white : AppColors.text,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.25)
                                  : AppColors.border.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${rp.enabledCapabilityIds.length}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            // Add Role Chip Action
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: onAddRole,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: const GradientBoxBorder(
                      gradient: AppColors.cardBorderGradient,
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GradientIcon(
                        icon: Icons.add_rounded,
                        size: 15,
                        gradient: AppColors.brandGradient,
                      ),
                      SizedBox(width: 4),
                      GradientText(
                        'New Role',
                        gradient: AppColors.brandGradient,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
