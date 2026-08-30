import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Top branding banner displaying white logo and portal title.
class LoginHeaderSection extends StatelessWidget {
  const LoginHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.only(top: 56, bottom: 52),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/whitelogo.png',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Text(
              'Leadership Portal',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
