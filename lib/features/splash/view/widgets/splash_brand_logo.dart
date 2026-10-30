import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'splash_animated_title.dart';

/// Renders the pre-loaded `assets/animations/splash.json` Lottie animation (same as Peers Global app)
/// with the animated "PEERS LEADERS" gradient text tightly positioned below it.
class SplashBrandLogo extends StatelessWidget {
  final AnimationController? animController;
  final void Function(LottieComposition)? onLoaded;
  final Animation<double> entranceScale;
  final Animation<double> fadeAnimation;

  const SplashBrandLogo({
    super.key,
    this.animController,
    this.onLoaded,
    required this.entranceScale,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // The 1080x1080 Lottie canvas has large transparent margins around the central logo.
        // Using Align(heightFactor: 0.52) trims the excess vertical canvas padding so the
        // title sits directly below the hexagon logo without a large gap.
        ClipRect(
          child: Align(
            alignment: Alignment.center,
            heightFactor: 0.52,
            child: SizedBox(
              width: 360,
              height: 360,
              child: Lottie.asset(
                'assets/animations/splash.json',
                controller: animController,
                repeat: false,
                onLoaded: onLoaded,
                fit: BoxFit.contain,
                frameBuilder: (context, child, composition) {
                  if (composition == null) {
                    return Center(
                      child: Image.asset(
                        'assets/icons/AppIcon.png',
                        width: 160,
                        height: 160,
                        fit: BoxFit.contain,
                      ),
                    );
                  }
                  return child;
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const SplashAnimatedTitle(),
      ],
    );
  }
}
