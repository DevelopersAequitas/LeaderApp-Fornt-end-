import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typography.dart';

/// Countdown timer or active resend button for OTP, matching Peers Global Unity's VerifyOtpResendSection.
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

  String _formatTime(int totalSecs) {
    final mins = totalSecs ~/ 60;
    final secs = totalSecs % 60;
    return '${mins.toString().padLeft(1, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;

    final isActionEnabled = canResend && !isResending;

    return Center(
      child: Column(
        children: [
          Text(
            "Didn't receive the code?",
            style: AppTypography.bodySmall.copyWith(color: secondaryTextColor),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: isActionEnabled ? onResend : null,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Text(
                isResending
                    ? 'Sending code...'
                    : (isActionEnabled
                        ? 'Resend OTP'
                        : 'Resend code in ${_formatTime(countdown)}'),
                style: AppTypography.bodyMedium.copyWith(
                  color: isActionEnabled
                      ? AppColor.primaryBlue
                      : secondaryTextColor.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
