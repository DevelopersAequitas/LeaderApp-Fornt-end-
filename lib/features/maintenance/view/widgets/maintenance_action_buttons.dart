import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Action triggers for checking maintenance status or bypassing as authorized leader.
class MaintenanceActionButtons extends StatelessWidget {
  final bool isChecking;
  final bool canBypass;
  final VoidCallback onRetry;
  final VoidCallback onBypass;

  const MaintenanceActionButtons({
    super.key,
    required this.isChecking,
    required this.canBypass,
    required this.onRetry,
    required this.onBypass,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: isChecking ? null : onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: isChecking
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh_rounded, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Check Status Again',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
        if (canBypass) ...[
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onBypass,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.warningDark,
              side: const BorderSide(color: AppColors.warningDark, width: 1.2),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.admin_panel_settings_outlined, size: 18),
                SizedBox(width: 8),
                Text(
                  'Bypass Maintenance (Admin Mode)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
