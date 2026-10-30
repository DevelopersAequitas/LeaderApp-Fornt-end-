import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typography.dart';

/// Text input field supporting both Email mode and WhatsApp Phone mode with country code selector.
class LoginInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isWhatsapp;
  final String dialCode;
  final String flag;
  final ValueChanged<String>? onChanged;
  final VoidCallback onCountryTap;
  final VoidCallback onSubmit;

  const LoginInputField({
    super.key,
    required this.controller,
    required this.isWhatsapp,
    required this.dialCode,
    required this.flag,
    this.onChanged,
    required this.onCountryTap,
    required this.onSubmit,
  });

  void _handlePhoneChanged(String val) {
    if (val.startsWith('0')) {
      final clean = val.replaceFirst(RegExp(r'^0+'), '');
      controller.value = TextEditingValue(
        text: clean,
        selection: TextSelection.collapsed(offset: clean.length),
      );
      onChanged?.call(clean);
      return;
    }
    onChanged?.call(val);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColor.darkSurface : AppColor.lightSurface;
    final borderColor = isDark ? AppColor.darkBorder : AppColor.lightBorder;
    final primaryTextColor =
        isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final secondaryTextColor =
        isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;
    final disabledTextColor =
        isDark ? AppColor.darkTextDisabled : AppColor.lightTextDisabled;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType:
            isWhatsapp ? TextInputType.phone : TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        inputFormatters: isWhatsapp
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ]
            : null,
        onChanged: isWhatsapp ? _handlePhoneChanged : onChanged,
        onSubmitted: (_) => onSubmit(),
        style: AppTypography.bodyLarge.copyWith(color: primaryTextColor),
        decoration: InputDecoration(
          hintText: isWhatsapp ? 'Phone number' : 'Email address',
          hintStyle: AppTypography.bodyLarge.copyWith(
            color: disabledTextColor,
          ),
          prefixIcon: isWhatsapp
              ? _buildPhonePrefix(
                  primaryTextColor: primaryTextColor,
                  secondaryTextColor: secondaryTextColor,
                  borderColor: borderColor,
                )
              : Icon(
                  Icons.mail_outline_rounded,
                  size: 20,
                  color: secondaryTextColor,
                ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColor.primaryBlue,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhonePrefix({
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color borderColor,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onCountryTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              flag.isNotEmpty ? flag : '🌐',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Text(
              dialCode,
              style: AppTypography.bodyMedium.copyWith(
                color: primaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: secondaryTextColor,
            ),
            const SizedBox(width: 8),
            Container(
              height: 20,
              width: 1,
              color: borderColor,
            ),
          ],
        ),
      ),
    );
  }
}
