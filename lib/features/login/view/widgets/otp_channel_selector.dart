import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typography.dart';

/// Selector allowing the user to toggle between Email and WhatsApp verification channels.
class OtpChannelSelector extends StatelessWidget {
  final String selectedChannel;
  final ValueChanged<String> onChannelChanged;

  const OtpChannelSelector({
    super.key,
    required this.selectedChannel,
    required this.onChannelChanged,
  });

  static const Color _whatsappGreen = Color(0xFF25D366);
  static const Color _gmailRed = Color(0xFFEA4335);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark
        ? AppColor.darkTextSecondary
        : AppColor.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Receive verification code via:',
          style: AppTypography.labelSmall.copyWith(
            color: secondaryTextColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildChannelCard(
              label: 'Email',
              channel: 'email',
              assetPath: 'assets/images/gmail.png',
              activeColor: _gmailRed,
              isDark: isDark,
            ),
            const SizedBox(width: 12),
            _buildChannelCard(
              label: 'WhatsApp',
              channel: 'whatsapp',
              assetPath: 'assets/images/whatsapp.png',
              activeColor: _whatsappGreen,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChannelCard({
    required String label,
    required String channel,
    required String assetPath,
    required Color activeColor,
    required bool isDark,
  }) {
    final isSelected = selectedChannel == channel;
    final surfaceColor = isDark ? AppColor.darkSurface : AppColor.lightSurface;
    final borderColor = isSelected
        ? activeColor
        : (isDark ? AppColor.darkBorder : AppColor.lightBorder);
    final primaryTextColor = isDark
        ? AppColor.darkTextPrimary
        : AppColor.lightTextPrimary;
    final secondaryTextColor = isDark
        ? AppColor.darkTextSecondary
        : AppColor.lightTextSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChannelChanged(channel),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: isDark ? 0.16 : 0.08)
                : surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Image.asset(
                  assetPath,
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: isSelected ? primaryTextColor : secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
