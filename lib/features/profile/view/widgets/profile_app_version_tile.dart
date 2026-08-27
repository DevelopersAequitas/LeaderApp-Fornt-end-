import 'package:flutter/material.dart';
import '../../../../core/services/app_config_service.dart';
import '../../../../core/theme/app_colors.dart';

/// MD3-styled tile displaying app version, update check, and maintenance status.
class ProfileAppVersionTile extends StatefulWidget {
  const ProfileAppVersionTile({super.key});

  @override
  State<ProfileAppVersionTile> createState() => _ProfileAppVersionTileState();
}

class _ProfileAppVersionTileState extends State<ProfileAppVersionTile> {
  bool _isChecking = false;

  Future<void> _handleCheckUpdate() async {
    setState(() => _isChecking = true);
    final service = AppConfigService();
    await service.fetchAppConfig();
    if (!mounted) return;
    setState(() => _isChecking = false);

    if (service.isForceUpdateRequired()) {
      service.triggerNativeStoreUpdate(isForce: true);
    } else if (service.isOptionalUpdateAvailable()) {
      service.triggerNativeStoreUpdate(isForce: false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your app is up to date with the latest version!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const currentVersion = AppConfigService.currentAppVersion;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondaryBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.phonelink_setup_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Version & Updates',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Version $currentVersion (Build 2026)',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _isChecking ? null : _handleCheckUpdate,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: AppColors.selectionBg,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isChecking
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Check',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }
}
