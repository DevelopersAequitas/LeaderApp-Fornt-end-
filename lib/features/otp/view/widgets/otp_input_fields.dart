import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

/// 6-digit PIN input row with keyboard navigation, paste handling and auto-submit callback.
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
    final code = controllers.map((c) => c.text.trim()).join();
    onOtpChanged(code);
  }

  void _handlePastedText(String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    for (int i = 0; i < 6; i++) {
      if (i < digits.length) {
        controllers[i].text = digits[i];
      } else {
        controllers[i].clear();
      }
    }
    if (digits.length >= 6) {
      for (final f in focusNodes) {
        f.unfocus();
      }
    } else if (digits.isNotEmpty) {
      focusNodes[digits.length.clamp(0, 5)].requestFocus();
    }
    _notifyOtp();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 48,
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
              maxLength: 6, // Allow paste up to 6 digits in any box
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2.0,
                  ),
                ),
              ),
              onChanged: (value) {
                if (value.length > 1) {
                  _handlePastedText(value);
                  return;
                }

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
