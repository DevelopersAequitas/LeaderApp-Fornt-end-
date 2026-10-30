import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';

/// Category icon & tint configuration using [AppColor] tokens.
class CircleCategoryThemeConfig {
  final IconData icon;
  final Color tintColor;
  final Color bgTint;

  const CircleCategoryThemeConfig({
    required this.icon,
    required this.tintColor,
    required this.bgTint,
  });

  static CircleCategoryThemeConfig fromCircle(String? category, String? name) {
    final lower = '${category ?? ''} ${name ?? ''}'.toLowerCase();

    if (lower.contains('manufactur') || lower.contains('engineer')) {
      return const CircleCategoryThemeConfig(
        icon: Icons.precision_manufacturing_outlined,
        tintColor: AppColor.primaryPink,
        bgTint: AppColor.badgePinkBg,
      );
    }
    if (lower.contains('real estate') ||
        lower.contains('construction') ||
        lower.contains('infra')) {
      return const CircleCategoryThemeConfig(
        icon: Icons.domain_outlined,
        tintColor: AppColor.attendanceColor,
        bgTint: AppColor.attendanceBg,
      );
    }
    if (lower.contains('tech') ||
        lower.contains('digital') ||
        lower.contains('it &') ||
        lower.contains('software')) {
      return const CircleCategoryThemeConfig(
        icon: Icons.computer_rounded,
        tintColor: AppColor.primaryBlue,
        bgTint: AppColor.badgeBlueBg,
      );
    }
    if (lower.contains('health') ||
        lower.contains('wellness') ||
        lower.contains('life sci') ||
        lower.contains('med')) {
      return const CircleCategoryThemeConfig(
        icon: Icons.spa_outlined,
        tintColor: AppColor.success,
        bgTint: AppColor.successBg,
      );
    }
    if (lower.contains('educat') ||
        lower.contains('train') ||
        lower.contains('skill')) {
      return const CircleCategoryThemeConfig(
        icon: Icons.school_outlined,
        tintColor: AppColor.primaryBlue,
        bgTint: AppColor.badgeBlueBg,
      );
    }
    if (lower.contains('event') ||
        lower.contains('fashion') ||
        lower.contains('lifestyle')) {
      return const CircleCategoryThemeConfig(
        icon: Icons.diamond_outlined,
        tintColor: AppColor.attendanceColor,
        bgTint: AppColor.attendanceBg,
      );
    }
    if (lower.contains('csr') ||
        lower.contains('ngo') ||
        lower.contains('nation')) {
      return const CircleCategoryThemeConfig(
        icon: Icons.favorite_rounded,
        tintColor: AppColor.primaryPink,
        bgTint: AppColor.badgePinkBg,
      );
    }
    if (lower.contains('franchise') || lower.contains('licens')) {
      return const CircleCategoryThemeConfig(
        icon: Icons.storefront_outlined,
        tintColor: AppColor.warning,
        bgTint: AppColor.warningBg,
      );
    }
    if (lower.contains('sustain') ||
        lower.contains('esg') ||
        lower.contains('green')) {
      return const CircleCategoryThemeConfig(
        icon: Icons.eco_outlined,
        tintColor: AppColor.success,
        bgTint: AppColor.successBg,
      );
    }
    if (lower.contains('import') ||
        lower.contains('export') ||
        lower.contains('trade')) {
      return const CircleCategoryThemeConfig(
        icon: Icons.public_rounded,
        tintColor: AppColor.primaryBlue,
        bgTint: AppColor.badgeBlueBg,
      );
    }
    if (lower.contains('startup') || lower.contains('founder')) {
      return const CircleCategoryThemeConfig(
        icon: Icons.rocket_launch_rounded,
        tintColor: AppColor.primaryPink,
        bgTint: AppColor.badgePinkBg,
      );
    }
    if (lower.contains('ipo') || lower.contains('sme')) {
      return const CircleCategoryThemeConfig(
        icon: Icons.bar_chart_rounded,
        tintColor: AppColor.attendanceColor,
        bgTint: AppColor.attendanceBg,
      );
    }
    if (lower.contains('investor') ||
        lower.contains('capital') ||
        lower.contains('finance')) {
      return const CircleCategoryThemeConfig(
        icon: Icons.monetization_on_outlined,
        tintColor: AppColor.warning,
        bgTint: AppColor.warningBg,
      );
    }
    if (lower.contains('global') ||
        lower.contains('cross-border') ||
        lower.contains('expansion')) {
      return const CircleCategoryThemeConfig(
        icon: Icons.explore_outlined,
        tintColor: AppColor.primaryBlue,
        bgTint: AppColor.badgeBlueBg,
      );
    }
    if (lower.contains('msme') || lower.contains('entrepreneur')) {
      return const CircleCategoryThemeConfig(
        icon: Icons.store_rounded,
        tintColor: AppColor.primaryPink,
        bgTint: AppColor.badgePinkBg,
      );
    }

    return const CircleCategoryThemeConfig(
      icon: Icons.bubble_chart_outlined,
      tintColor: AppColor.primaryBlue,
      bgTint: AppColor.badgeBlueBg,
    );
  }
}

