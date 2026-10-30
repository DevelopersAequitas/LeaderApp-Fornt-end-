import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/app_config_service.dart';
import '../../../core/theme/app_color.dart';
import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';
import 'widgets/splash_background_ambience.dart';
import 'widgets/splash_brand_logo.dart';
import 'widgets/splash_footer_version.dart';

/// The View component of the Splash Screen feature.
/// Plays the pre-loaded `assets/animations/splash.json` Lottie animation (same as Peers Global app)
/// with the animated "PEERS LEADERS" text below it.
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
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _safetyTimer;
  bool _animationFinished = false;
  bool _blocFinished = false;
  bool _isNavigated = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationFinished = true;
          _tryNavigate();
        }
      });

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _animController.forward();

    // Safety fallback timer ensuring screen advances even if animation finishes late
    _safetyTimer = Timer(const Duration(milliseconds: 2800), () {
      _animationFinished = true;
      _tryNavigate();
    });
  }

  void _onAnimationLoaded(LottieComposition composition) {
    if (mounted) {
      _animController.duration = composition.duration;
      if (!_animController.isAnimating && !_animController.isCompleted) {
        _animController.forward();
      }
    }
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _tryNavigate() {
    if (!mounted || _isNavigated) return;
    if (!_animationFinished || !_blocFinished) return;
    _isNavigated = true;
    _safetyTimer?.cancel();
    _handleNavigation();
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
          _blocFinished = true;
          _tryNavigate();
        } else if (state is SplashLoadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage.isNotEmpty
                  ? state.errorMessage
                  : 'Something went wrong while starting the app. Please try again.'),
              backgroundColor: AppColor.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColor.lightBackground,
        body: SizedBox.expand(
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(
                child: SplashBackgroundAmbience(),
              ),
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
                          animController: _animController,
                          onLoaded: _onAnimationLoaded,
                          entranceScale: _scaleAnimation,
                          fadeAnimation: _fadeAnimation,
                        ),
                        const Spacer(flex: 3),
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
                        const SizedBox(height: 24),
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
