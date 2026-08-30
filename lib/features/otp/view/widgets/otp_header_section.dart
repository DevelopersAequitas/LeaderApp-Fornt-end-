import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Top header banner displaying back button, logo and verification subtitle.
class OtpHeaderSection extends StatelessWidget {
  const OtpHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.only(top: 12, bottom: 48),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Image.asset(
              'assets/icons/whitelogo.png',
              width: 140,
              height: 140,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Text(
              'Security Verification',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 14,
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
