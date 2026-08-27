import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';

/// MD3-styled bottom bar hosting save action and matrix synchronization state.
class RoleSaveBar extends StatelessWidget {
  final bool isSaving;
  final bool hasUnsavedChanges;
  final VoidCallback onSave;

  const RoleSaveBar({
    super.key,
    required this.isSaving,
    required this.hasUnsavedChanges,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Status Indicator Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: hasUnsavedChanges
                    ? AppColors.warningLightBg
                    : AppColors.successLightBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: hasUnsavedChanges
                      ? AppColors.warningBorder
                      : AppColors.successBorder,
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasUnsavedChanges ? Icons.fiber_manual_record : Icons.check_circle_rounded,
                    size: 12,
                    color: hasUnsavedChanges ? AppColors.warningDark : AppColors.successDark,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    hasUnsavedChanges ? 'Unsaved' : 'Synced',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: hasUnsavedChanges ? AppColors.warningDark : AppColors.successDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Primary Save Action
            Expanded(
              child: PrimaryButton(
                label: isSaving ? 'Saving Matrix...' : 'Save Matrix Settings',
                onPressed: isSaving ? null : onSave,
                isLoading: isSaving,
                leadingIcon: Icons.cloud_upload_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
