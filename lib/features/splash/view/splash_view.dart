// ==============================================================================
// File: lib/features/splash/view/splash_view.dart
// Description: Application Launch Splash & Dynamic Lifecycle Orchestrator
// Framework: Flutter | Architecture: MVP View Layer (BLoC State Driven)
// Features:
//   - Official Peers emblem entrance animation with 12px border radius
//   - Fluid staggered character-by-character cascade for "PEERS GLOBAL"
//   - Remote maintenance mode checks and dynamic force-update verification
//   - Seamless authentication session evaluation and conditional route dispatching
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/app_config_service.dart';
import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';
import 'widgets/splash_background_ambience.dart';
import 'widgets/splash_brand_logo.dart';
import 'widgets/splash_footer_version.dart';

/// The View component of the Splash Screen feature.
/// Clean white theme with centered emblem, animated "PEERS GLOBAL" typewriter, and pure BLoC state routing.
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashBloc>(
      create: (context) => SplashBloc()..add(const InitializeSplash()),
      child: const _SplashContent(),
    );
  }
}

class _SplashContent extends StatefulWidget {
  const _SplashContent();

  @override
  State<_SplashContent> createState() => _SplashContentState();
}

class _SplashContentState extends State<_SplashContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _handleNavigation() async {
    if (!mounted) return;
    try {
      final service = AppConfigService();
      final config = await service.fetchAppConfig();
      if (!mounted) return;

      if (config.isMaintenanceMode &&
          service.isUnderMaintenance(SessionManager().currentRole.name)) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.maintenance);
        return;
      }

      if (service.isForceUpdateRequired()) {
        await service.triggerNativeStoreUpdate(isForce: true);
        return;
      }

      if (service.isOptionalUpdateAvailable()) {
        service.triggerNativeStoreUpdate(isForce: false);
      }
    } catch (_) {}

    if (!mounted) return;
    if (SessionManager().isAuthenticated) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashLoadSuccess) {
          _handleNavigation();
        } else if (state is SplashLoadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Initialization Error: ${state.errorMessage}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.expand(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Clean White Ambience
              const Positioned.fill(
                child: SplashBackgroundAmbience(),
              ),
              // Perfectly Centered Brand Logo & Animated "PEERS GLOBAL"
              SafeArea(
                child: Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(flex: 3),
                        SplashBrandLogo(
                          entranceScale: _scaleAnimation,
                          fadeAnimation: _fadeAnimation,
                        ),
                        const Spacer(flex: 3),
                        // Bottom Version & Enterprise Badge
                        BlocBuilder<SplashBloc, SplashState>(
                          builder: (context, state) {
                            final version = state is SplashLoadSuccess
                                ? state.model.appVersion
                                : '1.0.0';
                            return SplashFooterVersion(
                              appVersion: version,
                              fadeAnimation: _fadeAnimation,
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
