import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

/// 6-digit PIN input row with keyboard navigation.
class OtpInputFields extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final ValueChanged<String> onOtpChanged;

  const OtpInputFields({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onOtpChanged,
  });

  void _notifyOtp() {
    final code = controllers.map((c) => c.text).join();
    onOtpChanged(code);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 46,
          height: 56,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace &&
                  controllers[index].text.isEmpty &&
                  index > 0) {
                focusNodes[index - 1].requestFocus();
              }
            },
            child: TextField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AppColors.secondaryBg,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2.0,
                  ),
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  if (index < 5) {
                    focusNodes[index + 1].requestFocus();
                  } else {
                    focusNodes[index].unfocus();
                  }
                }
                _notifyOtp();
              },
            ),
          ),
        );
      }),
    );
  }
}
