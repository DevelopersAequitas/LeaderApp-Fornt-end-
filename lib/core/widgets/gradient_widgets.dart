import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import '../theme/app_typography.dart';

/// Applies a linear gradient mask over any [IconData].
class GradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Gradient gradient;

  const GradientIcon({
    super.key,
    required this.icon,
    this.size = 24.0,
    this.gradient = AppColor.brandGradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Icon(icon, size: size, color: Colors.white),
    );
  }
}

/// Applies a linear gradient mask over any [Text].
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.gradient = AppColor.brandGradient,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
      ),
    );
  }
}

/// Renders a container with a smooth linear gradient border.
class GradientBorderContainer extends StatelessWidget {
  final Widget child;
  final double borderWidth;
  final double borderRadius;
  final Gradient gradient;
  final Color backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final List<BoxShadow>? boxShadow;

  const GradientBorderContainer({
    super.key,
    required this.child,
    this.borderWidth = 1.8,
    this.borderRadius = 18.0,
    this.gradient = AppColor.brandGradient,
    this.backgroundColor = Colors.white,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow,
      ),
      child: Container(
        margin: EdgeInsets.all(borderWidth),
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        ),
        child: child,
      ),
    );
  }
}

/// Executive Action Card matching the brand design with a gradient border,
/// white interior, gradient icon, and descriptive title underneath.
class GradientActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final double borderRadius;
  final double borderWidth;
  final Gradient gradient;

  const GradientActionCard({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.size = 58.0,
    this.iconSize = 26.0,
    this.borderRadius = 18.0,
    this.borderWidth = 1.8,
    this.gradient = AppColor.brandGradient,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GradientBorderContainer(
            width: size,
            height: size,
            borderRadius: borderRadius,
            borderWidth: borderWidth,
            gradient: gradient,
            backgroundColor: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColor.primaryBlue.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            child: Center(
              child: GradientIcon(
                icon: icon,
                size: iconSize,
                gradient: gradient,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 76,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(
                color: AppColor.lightTextPrimary,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A custom [BoxBorder] that paints a continuous linear or radial [Gradient] along the border.
/// Drop-in replacement for [Border.all] inside any [BoxDecoration].
class GradientBoxBorder extends BoxBorder {
  final Gradient gradient;
  final double width;

  const GradientBoxBorder({
    this.gradient = AppColor.cardBorderGradient,
    this.width = 1.2,
  });

  @override
  BorderSide get bottom => BorderSide(width: width);

  @override
  BorderSide get top => BorderSide(width: width);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  bool get isUniform => true;

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    if (width <= 0.0) return;

    final paint = Paint()
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..shader = gradient.createShader(rect);

    if (shape == BoxShape.circle) {
      final radius = (rect.shortestSide - width) / 2.0;
      canvas.drawCircle(rect.center, radius, paint);
    } else if (borderRadius != null && borderRadius != BorderRadius.zero) {
      final rrect = borderRadius.toRRect(rect).deflate(width / 2.0);
      canvas.drawRRect(rrect, paint);
    } else {
      canvas.drawRect(rect.deflate(width / 2.0), paint);
    }
  }

  @override
  ShapeBorder scale(double t) {
    return GradientBoxBorder(gradient: gradient, width: width * t);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is GradientBoxBorder &&
        other.gradient == gradient &&
        other.width == width;
  }

  @override
  int get hashCode => Object.hash(gradient, width);
}

/// Renders an icon inside a square container with rounded border and gradient icon or styling.
class SquareRoundedGradientIcon extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final double boxSize;
  final double borderRadius;
  final Gradient gradient;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool showBorder;
  final double borderWidth;
  final VoidCallback? onTap;

  const SquareRoundedGradientIcon({
    super.key,
    required this.icon,
    this.iconSize = 18.0,
    this.boxSize = 34.0,
    this.borderRadius = 10.0,
    this.gradient = AppColor.brandGradient,
    this.backgroundColor,
    this.iconColor,
    this.showBorder = true,
    this.borderWidth = 1.2,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget iconWidget = iconColor != null
        ? Icon(icon, size: iconSize, color: iconColor)
        : GradientIcon(
            icon: icon,
            size: iconSize,
            gradient: gradient,
          );

    final Widget boxContent = Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? GradientBoxBorder(gradient: gradient, width: borderWidth)
            : Border.all(color: AppColor.lightBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryBlue.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: iconWidget),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: boxContent,
      );
    }
    return boxContent;
  }
}

