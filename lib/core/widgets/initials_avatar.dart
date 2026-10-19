import 'package:flutter/material.dart';
import '../constants/api_endpoints.dart';
import '../theme/app_colors.dart';

/// MD3-styled circular avatar displaying user/peer profile photo or initials fallback.
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
        fontWeight: FontWeight.w500,
      ),
    );

    String? resolvedUrl = imageUrl?.trim();
    if (resolvedUrl != null && resolvedUrl.isNotEmpty) {
      if (!resolvedUrl.startsWith('http://') &&
          !resolvedUrl.startsWith('https://')) {
        final host = ApiEndpoints.baseUrl.replaceFirst('/api/v1', '');
        resolvedUrl = resolvedUrl.startsWith('/')
            ? '$host$resolvedUrl'
            : '$host/$resolvedUrl';
      }
      if (resolvedUrl.startsWith('http://') &&
          resolvedUrl.contains('peersunity.com')) {
        resolvedUrl = resolvedUrl.replaceFirst('http://', 'https://');
      }
      if (resolvedUrl.contains(' ')) {
        resolvedUrl = Uri.encodeFull(resolvedUrl);
      }
    }

    final hasValidImage =
        resolvedUrl != null &&
        resolvedUrl.isNotEmpty &&
        (resolvedUrl.startsWith('http://') ||
            resolvedUrl.startsWith('https://'));

    if (hasValidImage) {
      final pixelSize =
          (radius * 2 * (MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0))
              .toInt()
              .clamp(48, 256);

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
            resolvedUrl,
            width: radius * 2,
            height: radius * 2,
            cacheWidth: pixelSize,
            cacheHeight: pixelSize,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: backgroundColor ?? AppColors.primary,
              alignment: Alignment.center,
              child: textWidget,
            ),
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
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
