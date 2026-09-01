import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Countdown timer or active resend button for OTP with loading state.
class OtpResendSection extends StatelessWidget {
  final int countdown;
  final bool canResend;
  final bool isResending;
  final VoidCallback onResend;

  const OtpResendSection({
    super.key,
    required this.countdown,
    required this.canResend,
    this.isResending = false,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    if (isResending) {
      return const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Sending code...',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    }

    if (canResend) {
      return Center(
        child: TextButton.icon(
          onPressed: onResend,
          icon: const Icon(
            Icons.refresh_rounded,
            size: 18,
            color: AppColors.primary,
          ),
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

    final minutes = (countdown ~/ 60).toString().padLeft(2, '0');
    final seconds = (countdown % 60).toString().padLeft(2, '0');

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer_outlined,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            'Resend code in $minutes:${seconds}s',
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
