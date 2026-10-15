import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_widgets.dart';

/// Clean, trendy input field with gradient icons and seamless country selection.
class LoginInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isPhone;
  final Country selectedCountry;
  final bool hasText;
  final VoidCallback onCountryTap;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  const LoginInputField({
    super.key,
    required this.controller,
    required this.isPhone,
    required this.selectedCountry,
    required this.hasText,
    required this.onCountryTap,
    required this.onClear,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => onSubmit(),
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.text,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        prefixIcon: InkWell(
          onTap: onCountryTap,
          borderRadius: BorderRadius.circular(12),
          child: isPhone ? _buildPhonePrefix() : _buildEmailPrefix(),
        ),
        suffixIcon: hasText
            ? IconButton(
                icon: const Icon(Icons.cancel_rounded, size: 16, color: AppColors.textSecondary),
                onPressed: onClear,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        hintText: isPhone ? '98765 43210' : 'name@example.com or phone',
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.6),
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryPink, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildEmailPrefix() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.0),
      child: GradientIcon(
        icon: Icons.alternate_email_rounded,
        size: 20,
        gradient: AppColors.brandGradient,
      ),
    );
  }

  Widget _buildPhonePrefix() {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(selectedCountry.flagEmoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 4),
          Text(
            '+${selectedCountry.phoneCode}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.text,
            ),
          ),
          const SizedBox(width: 4),
          const GradientIcon(
            icon: Icons.keyboard_arrow_down_rounded,
            size: 18,
            gradient: AppColors.brandGradient,
          ),
          Container(
            height: 20,
            width: 1,
            color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ],
      ),
    );
  }
}
