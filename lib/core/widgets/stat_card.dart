import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color? backgroundColor;
  final Color? valueColor;
  final Color? labelColor;
  final double valueFontSize;
  final double labelFontSize;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.backgroundColor,
    this.valueColor,
    this.labelColor,
    this.valueFontSize = 14,
    this.labelFontSize = 9,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: valueFontSize,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: labelColor ?? AppColors.textSecondary,
            fontSize: labelFontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            height: 1.1,
          ),
        ),
      ],
    );

    if (backgroundColor != null) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
        ),
        child: content,
      );
    }

    return Padding(
      padding: padding,
      child: content,
    );
  }
}
