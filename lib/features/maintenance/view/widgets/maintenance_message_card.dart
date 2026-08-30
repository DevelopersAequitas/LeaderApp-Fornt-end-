import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Clean typography presentation for maintenance headline and explanation.
class MaintenanceMessageCard extends StatelessWidget {
  final String title;
  final String message;

  const MaintenanceMessageCard({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        Text(
          message,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textSecondary,
            height: 1.55,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
