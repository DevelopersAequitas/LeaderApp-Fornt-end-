import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// MD3-styled circular avatar displaying the user/peer's profile photo or calculated initials fallback.
class InitialsAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final BoxBorder? border;
  final bool isCircle;

  const InitialsAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 24,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.border,
    this.isCircle = true,
    BorderRadius? borderRadius,
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

    final hasValidImage = imageUrl != null &&
        imageUrl!.trim().isNotEmpty &&
        imageUrl!.startsWith('http');

    if (hasValidImage) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? AppColors.primary,
          border: border,
        ),
        child: ClipOval(
          child: Image.network(
            imageUrl!.trim(),
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: backgroundColor ?? AppColors.primary,
              alignment: Alignment.center,
              child: textWidget,
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: backgroundColor ?? AppColors.primary,
                alignment: Alignment.center,
                child: textWidget,
              );
            },
          ),
        ),
      );
    }

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? AppColors.primary,
        border: border,
      ),
      alignment: Alignment.center,
      child: textWidget,
    );
  }
}
