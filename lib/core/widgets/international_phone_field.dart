import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../formatting/phone_number_helper.dart';
import '../theme/app_colors.dart';

/// Reusable international phone input with a country-code selector, country-
/// specific placeholder hint, and no hard-coded digit cap.
///
/// Uses `country_picker` for selecting any country's dial code and
/// [PhoneNumberHelper] for country-specific hints.
class InternationalPhoneField extends StatelessWidget {
  const InternationalPhoneField({
    super.key,
    required this.controller,
    required this.selectedCountry,
    required this.onCountryChanged,
    this.label,
    this.errorText,
    this.onChanged,
    this.isRequired = false,
    this.isDense = false,
  });

  final TextEditingController controller;
  final Country selectedCountry;
  final ValueChanged<Country> onCountryChanged;
  final String? label;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final bool isRequired;
  final bool isDense;

  void _openCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        backgroundColor: Colors.white,
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.72,
        inputDecoration: InputDecoration(
          hintText: 'Search country or dial code',
          prefixIcon: const Icon(Icons.search_rounded, size: 18),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
      onSelect: onCountryChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hint = PhoneNumberHelper.exampleHint(selectedCountry.countryCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          Row(
            children: [
              Text(
                label!,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                  letterSpacing: 0.1,
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          onChanged: onChanged,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-\(\)\+]')),
            LengthLimitingTextInputFormatter(25),
          ],
          style: TextStyle(
            fontSize: isDense ? 13 : 14,
            color: AppColors.text,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            errorMaxLines: 2,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _openCountryPicker(context),
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedCountry.flagEmoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '+${selectedCountry.phoneCode}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Container(
                      height: 18,
                      width: 1,
                      color: const Color(0xFFE2E8F0),
                    ),
                  ],
                ),
              ),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            isDense: isDense,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: isDense ? 10 : 13,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.6,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}
