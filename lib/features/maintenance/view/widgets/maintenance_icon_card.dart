import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Animated/Styled maintenance icon avatar badge.
class MaintenanceIconCard extends StatelessWidget {
  const MaintenanceIconCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.35),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(
        Icons.build_circle_outlined,
        size: 48,
        color: AppColors.warningDark,
      ),
    );
  }
}
