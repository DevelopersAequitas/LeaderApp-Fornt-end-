import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Countdown timer or active resend button for OTP.
class OtpResendSection extends StatelessWidget {
  final int countdown;
  final bool canResend;
  final VoidCallback onResend;

  const OtpResendSection({
    super.key,
    required this.countdown,
    required this.canResend,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    if (canResend) {
      return Center(
        child: TextButton.icon(
          onPressed: onResend,
          icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.primary),
          label: const Text(
            'Resend Code',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    final formattedSec = countdown.toString().padLeft(2, '0');
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            'Resend code in 00:${formattedSec}s',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
