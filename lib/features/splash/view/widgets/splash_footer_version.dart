import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typography.dart';

/// Bottom footer displaying app version and system badge on white theme.
class SplashFooterVersion extends StatelessWidget {
  final String appVersion;
  final Animation<double> fadeAnimation;

  const SplashFooterVersion({
    super.key,
    required this.appVersion,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColor.lightSurfaceSubtle,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColor.lightBorder, width: 1.0),
            ),
            child: Text(
              appVersion.isNotEmpty ? 'v$appVersion' : '',
              style: AppTypography.labelSmall.copyWith(
                color: AppColor.lightTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
