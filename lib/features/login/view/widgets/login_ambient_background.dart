import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';

/// Soft ambient aura background matching the Peers Global authentication screens.
class LoginAmbientBackground extends StatelessWidget {
  final Widget child;

  const LoginAmbientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _AmbientBackgroundPainter(isDark: isDark),
          ),
        ),
        child,
      ],
    );
  }
}

class _AmbientBackgroundPainter extends CustomPainter {
  final bool isDark;

  _AmbientBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    // 1. Top-Right Soft Ambient Bloom
    final topGlowCenter = Offset(size.width * 0.96, size.height * 0.02);
    final topGlowRadius = size.width * 0.58;
    final topGlowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.4, -0.4),
        radius: 0.95,
        colors: [
          AppColor.primaryPink.withValues(alpha: isDark ? 0.28 : 0.18),
          AppColor.primaryBlue.withValues(alpha: isDark ? 0.22 : 0.13),
          AppColor.primaryBlue.withValues(alpha: isDark ? 0.08 : 0.04),
          AppColor.transparent,
        ],
        stops: const [0.0, 0.40, 0.70, 1.0],
      ).createShader(
        Rect.fromCircle(center: topGlowCenter, radius: topGlowRadius),
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);

    canvas.drawCircle(topGlowCenter, topGlowRadius, topGlowPaint);

    // 2. Bottom-Left Soft Translucent Blue Dome
    final blueCenter = Offset(size.width * 0.10, size.height * 1.20);
    final blueRadius = size.height * 0.32;
    final blueDomePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColor.primaryBlue.withValues(alpha: isDark ? 0.14 : 0.065),
          AppColor.primaryBlue.withValues(alpha: isDark ? 0.20 : 0.095),
        ],
      ).createShader(Rect.fromCircle(center: blueCenter, radius: blueRadius))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(blueCenter, blueRadius, blueDomePaint);

    // 3. Bottom-Right Soft Translucent Pink Dome
    final pinkCenter = Offset(size.width * 0.92, size.height * 1.16);
    final pinkRadius = size.height * 0.33;
    final pinkDomePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColor.primaryPink.withValues(alpha: isDark ? 0.13 : 0.065),
          AppColor.primaryPink.withValues(alpha: isDark ? 0.18 : 0.095),
        ],
      ).createShader(Rect.fromCircle(center: pinkCenter, radius: pinkRadius))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(pinkCenter, pinkRadius, pinkDomePaint);
  }

  @override
  bool shouldRepaint(covariant _AmbientBackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
