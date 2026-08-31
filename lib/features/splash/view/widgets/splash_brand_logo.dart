import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'splash_animated_title.dart';

/// Clean brand emblem with 12px border radius and bottom-edge animated "PEERS GLOBAL" title.
class SplashBrandLogo extends StatelessWidget {
  final Animation<double> entranceScale;
  final Animation<double> fadeAnimation;

  const SplashBrandLogo({
    super.key,
    required this.entranceScale,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([entranceScale, fadeAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: entranceScale.value,
          child: Opacity(
            opacity: fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo container with 12px border radius
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 18,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/icons/AppIcon.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Animated "PEERS GLOBAL" sliding up from bottom edge
          const SplashAnimatedTitle(),
        ],
      ),
    );
  }
}
