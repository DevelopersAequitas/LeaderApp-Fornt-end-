import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import '../theme/app_typography.dart';
import 'gradient_widgets.dart';

/// Renders numeric values as brand-gradient text (no image assets).
/// [digitHeight] drives the font size; [spacing] adjusts letter spacing.
class ThreeDNumberDisplay extends StatelessWidget {
  final String value;
  final double digitHeight;
  final double spacing;

  const ThreeDNumberDisplay({
    super.key,
    required this.value,
    this.digitHeight = 28.0,
    this.spacing = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final text = value.trim().isEmpty ? '0' : value.trim();

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: GradientText(
        text,
        gradient: AppColor.brandGradient,
        style: AppTypography.titleMedium.copyWith(
          fontFamily: AppTypography.fontFamily,
          fontSize: digitHeight * 0.95,
          fontWeight: FontWeight.bold,
          height: 1.0,
          letterSpacing: spacing.clamp(-1.0, 2.0),
        ),
      ),
    );
  }
}
