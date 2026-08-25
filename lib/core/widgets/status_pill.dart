import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatusPill extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const StatusPill({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  // Factory constructor for "Active" or success states (Green)
  factory StatusPill.active({required String label, double fontSize = 11}) {
    return StatusPill(
      label: label,
      backgroundColor: AppColors.successBg,
      textColor: AppColors.success,
      fontSize: fontSize,
    );
  }

  // Factory constructor for warning/pending/deals states (Orange/Mustard)
  factory StatusPill.warning({required String label, double fontSize = 11}) {
    return StatusPill(
      label: label,
      backgroundColor: AppColors.warningBg,
      textColor: AppColors.warning,
      fontSize: fontSize,
    );
  }

  // Factory constructor for danger/at-risk states (Red)
  factory StatusPill.danger({required String label, double fontSize = 11}) {
    return StatusPill(
      label: label,
      backgroundColor: AppColors.dangerBg,
      textColor: AppColors.danger,
      fontSize: fontSize,
    );
  }

  // Factory constructor for general info/primary states (Blue)
  factory StatusPill.info({required String label, double fontSize = 11}) {
    return StatusPill(
      label: label,
      backgroundColor: AppColors.infoBg,
      textColor: AppColors.info,
      fontSize: fontSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
