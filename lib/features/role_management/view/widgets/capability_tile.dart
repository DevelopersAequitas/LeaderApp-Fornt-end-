import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_widgets.dart';
import '../../model/role_permission_model.dart';

/// MD3-styled soft capability tile with responsive switch.
class CapabilityTile extends StatelessWidget {
  final AppCapability capability;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const CapabilityTile({
    super.key,
    required this.capability,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: isEnabled ? AppColors.selectionBg.withValues(alpha: 0.35) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isEnabled ? AppColors.primary.withValues(alpha: 0.1) : AppColors.secondaryBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: isEnabled
                ? const GradientIcon(
                    icon: Icons.check_circle_rounded,
                    size: 14,
                    gradient: AppColors.brandGradient,
                  )
                : const Icon(
                    Icons.radio_button_unchecked_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capability.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isEnabled ? AppColors.text : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  capability.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: isEnabled,
              activeThumbColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withValues(alpha: 0.25),
              inactiveThumbColor: AppColors.disabled,
              inactiveTrackColor: AppColors.border,
              onChanged: onToggle,
            ),
          ),
        ],
      ),
    );
  }
}
