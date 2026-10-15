import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Minimal, trendy security and privacy footnote for sign-in.
class LoginFooterSection extends StatelessWidget {
  const LoginFooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 13,
          color: AppColors.textSecondary.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Text(
          'Protected by Peers Global Security',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
