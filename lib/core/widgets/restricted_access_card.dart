import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RestrictedAccessCard extends StatelessWidget {
  final String title;
  final String message;
  final Widget? contentOverride;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color borderIconColor;

  const RestrictedAccessCard({
    super.key,
    this.title = 'Access Restricted',
    required this.message,
    this.contentOverride,
    this.icon = Icons.lock_outline_rounded,
    this.iconColor = AppColors.danger,
    this.iconBgColor = AppColors.dangerBg,
    this.borderIconColor = AppColors.dangerBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: 4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderIconColor, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          contentOverride ??
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.text.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
        ],
      ),
    );
  }
}
