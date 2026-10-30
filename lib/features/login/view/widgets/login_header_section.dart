import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typography.dart';

/// Top header & title section for the Login screen matching Peers Global Unity.
class LoginHeaderSection extends StatelessWidget {
  final String channel;
  final VoidCallback? onBack;

  const LoginHeaderSection({
    super.key,
    this.channel = 'email',
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final secondaryTextColor =
        isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;

    final title =
        channel == 'whatsapp' ? 'Enter your mobile number' : 'Enter your email';
    final subtitle = channel == 'whatsapp'
        ? 'We\'ll send a 6-digit verification code on WhatsApp to help you sign in.'
        : 'We\'ll send a 6-digit verification code to your email to help you sign in.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 44,
          child: Row(
            children: [
              if (onBack != null)
                IconButton(
                  onPressed: onBack,
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: primaryTextColor,
                  ),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 96),
        Text(
          title,
          style: AppTypography.displayMedium.copyWith(
            color: primaryTextColor,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: secondaryTextColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
