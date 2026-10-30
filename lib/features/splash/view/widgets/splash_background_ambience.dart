import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';

/// Clean, crisp white background with subtle ambient depth.
class SplashBackgroundAmbience extends StatelessWidget {
  const SplashBackgroundAmbience({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColor.white,
        gradient: AppColor.lightBgGradient,
      ),
    );
  }
}
