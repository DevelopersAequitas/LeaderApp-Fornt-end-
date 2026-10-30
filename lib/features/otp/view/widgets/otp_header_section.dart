import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';

/// Top header for the OTP screen with a left-aligned back button, matching Peers Global Unity.
class OtpHeaderSection extends StatelessWidget {
  final VoidCallback? onBack;

  const OtpHeaderSection({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor =
        isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: onBack ?? () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: iconColor,
          ),
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        ),
      ],
    );
  }
}
