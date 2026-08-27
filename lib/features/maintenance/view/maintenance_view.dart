import 'package:flutter/material.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/app_config_service.dart';
import '../../../core/theme/app_colors.dart';

/// Full-screen MD3 Maintenance screen with Super Admin bypass capability.
class MaintenanceView extends StatefulWidget {
  const MaintenanceView({super.key});

  @override
  State<MaintenanceView> createState() => _MaintenanceViewState();
}

class _MaintenanceViewState extends State<MaintenanceView> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    setState(() => _isRetrying = true);
    final service = AppConfigService();
    final config = await service.fetchAppConfig();
    if (!mounted) return;
    setState(() => _isRetrying = false);

    if (!config.isMaintenanceMode) {
      if (SessionManager().isAuthenticated) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('System is still undergoing maintenance. Please check back shortly.'),
          backgroundColor: AppColors.warningDark,
        ),
      );
    }
  }

  void _handleBypass() {
    if (SessionManager().isAuthenticated) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = AppConfigService().config;
    final isSuperAdmin = SessionManager().currentRole == UserRole.superAdmin;
    final canBypass = isSuperAdmin ||
        config.allowedBypassRoles.any((r) => r.toLowerCase() == SessionManager().currentRole.name.toLowerCase());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3), width: 2),
                ),
                child: const Icon(
                  Icons.build_circle_outlined,
                  size: 44,
                  color: AppColors.warningDark,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                config.maintenanceTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                config.maintenanceMessage,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isRetrying ? null : _handleRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isRetrying
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Check Status Again', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        ],
                      ),
              ),
              if (canBypass) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _handleBypass,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.warningDark,
                    side: const BorderSide(color: AppColors.warningDark),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.admin_panel_settings_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Bypass Maintenance (Admin Mode)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
