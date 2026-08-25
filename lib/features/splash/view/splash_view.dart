import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/splash_bloc.dart';
import '../bloc/splash_state.dart';
import '../presenter/splash_presenter.dart';

/// The View component of the Splash Screen feature.
/// Handles the entrance animations, layout, and rendering.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin
    implements SplashViewContract {
  late final SplashBloc _bloc;
  late final SplashPresenter _presenter;

  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _pulseAnimation;

  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _bloc = SplashBloc();
    _presenter = SplashPresenter(view: this, bloc: _bloc);

    // Entrance pop-in animation (2000ms for extra smoothness)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Continuous breathing/pulse loop (3000ms for slow, calm breathing effect)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Slow organic scaling
    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    // Soft fade-in
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    // Smooth subtle slide-up
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.04), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Calm breathing pulse using Sine curve
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // Start entrance animation and trigger repeating pulse loop on completion
    _entranceController.forward().then((_) {
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });

    // Start presenter initialization logic
    _presenter.initialize();
  }

  @override
  void dispose() {
    // Properly clean up resources to prevent memory leaks (Rule 23)
    _entranceController.dispose();
    _pulseController.dispose();
    _bloc.close();
    super.dispose();
  }

  // --- SplashViewContract Implementations ---

  @override
  void onSplashLoading() {}

  @override
  void onSplashLoaded(String appVersion, String brandingText) {
    setState(() {
      _appVersion = appVersion;
    });
  }

  @override
  void onSplashError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Initialization Error: $message'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  void navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashBloc>.value(
      value: _bloc,
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          _presenter.handleStateChange(state);
        },
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.3,
                colors: [
                  AppColors.primary, // Dark Blue: #102640
                  AppColors.darkMidnight, // Deep Midnight Blue
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _entranceController,
                        _pulseController,
                      ]),
                      builder: (context, child) {
                        final double entranceScale = _scaleAnimation.value;
                        final double pulseScale =
                            _entranceController.isCompleted
                            ? 1.0 +
                                  (_pulseAnimation.value *
                                      0.03) // 3% breathing pulse
                            : 1.0;

                        return FractionalTranslation(
                          translation: _slideAnimation.value,
                          child: Transform.scale(
                            scale: entranceScale * pulseScale,
                            child: Opacity(
                              opacity: _fadeAnimation.value,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Main logo/symbol with subtle gold gradient
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Image.asset(
                              'assets/icons/whitelogo.png',
                              width: 280,
                              height: 280,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // App Version at the bottom
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: AnimatedBuilder(
                        animation: _entranceController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: child,
                          );
                        },
                        child: Text(
                          _appVersion.isNotEmpty ? 'VERSION $_appVersion' : '',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.4),
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
