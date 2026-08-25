import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class InitialsAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final BorderRadius? borderRadius;
  final BoxBorder? border;

  const InitialsAvatar({
    super.key,
    required this.name,
    this.radius = 24,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final cleanName = name.trim();
    final initials = cleanName.isEmpty
        ? '?'
        : cleanName
            .split(' ')
            .where((w) => w.isNotEmpty)
            .map((w) => w[0])
            .take(2)
            .join()
            .toUpperCase();

    final textWidget = Text(
      initials,
      style: TextStyle(
        color: textColor ?? Colors.white,
        fontSize: fontSize ?? (radius * 0.65),
        fontWeight: FontWeight.w800,
      ),
    );

    if (borderRadius != null || border != null) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.primary,
          borderRadius: borderRadius ?? BorderRadius.circular(radius),
          border: border,
        ),
        alignment: Alignment.center,
        child: textWidget,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppColors.primary,
      child: textWidget,
    );
  }
}
