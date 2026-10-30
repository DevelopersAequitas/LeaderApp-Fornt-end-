import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typography.dart';

/// 6-digit circular OTP input row with keyboard navigation, paste handling,
/// focus borders, and auto-submit callback — matching Peers Global Unity's VerifyOtpInputSection.
class OtpInputFields extends StatefulWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final ValueChanged<String> onOtpChanged;
  final ValueChanged<String>? onCompleted;

  const OtpInputFields({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onOtpChanged,
    this.onCompleted,
  });

  @override
  State<OtpInputFields> createState() => _OtpInputFieldsState();
}

class _OtpInputFieldsState extends State<OtpInputFields> {
  static const int _otpLength = 6;

  @override
  void initState() {
    super.initState();
    for (final node in widget.focusNodes) {
      node.addListener(_onFocusChange);
    }
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final node in widget.focusNodes) {
      node.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _notifyOtp({bool checkCompleted = false}) {
    final code = widget.controllers.map((c) => c.text.trim()).join();
    widget.onOtpChanged(code);
    if (checkCompleted && code.length == _otpLength) {
      widget.onCompleted?.call(code);
    }
  }

  void _onChanged(String value, int index) {
    if (value.isEmpty) {
      _notifyOtp();
      setState(() {});
      return;
    }

    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      widget.controllers[index].clear();
      _notifyOtp();
      setState(() {});
      return;
    }

    // If user pasted a 6+ digit OTP code into any box:
    if (digits.length >= _otpLength) {
      for (int i = 0; i < _otpLength; i++) {
        widget.controllers[i].text = digits[i];
      }
      for (final node in widget.focusNodes) {
        node.unfocus();
      }
      _notifyOtp(checkCompleted: true);
      setState(() {});
      return;
    }

    // If user typed a single character or typed over an existing character:
    if (digits.length == 2) {
      widget.controllers[index].text = digits[digits.length - 1];
    } else if (digits.length == 1) {
      widget.controllers[index].text = digits[0];
    } else {
      for (int i = 0; i < digits.length && (index + i) < _otpLength; i++) {
        widget.controllers[index + i].text = digits[i];
      }
    }

    if (index < _otpLength - 1) {
      widget.focusNodes[index + 1].requestFocus();
      _notifyOtp();
    } else {
      widget.focusNodes[index].unfocus();
      _notifyOtp(checkCompleted: true);
    }
    setState(() {});
  }

  void _onBackKey(int index) {
    if (widget.controllers[index].text.isEmpty && index > 0) {
      widget.controllers[index - 1].clear();
      widget.focusNodes[index - 1].requestFocus();
      _notifyOtp();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_otpLength, (index) {
        final isFocused = widget.focusNodes[index].hasFocus;
        final isFilled = widget.controllers[index].text.isNotEmpty;
        final borderColor = isFocused
            ? AppColor.primaryBlue
            : (isFilled
                ? AppColor.primaryBlue.withValues(alpha: 0.6)
                : (isDark ? AppColor.darkBorder : AppColor.lightBorder));

        return Focus(
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace) {
              _onBackKey(index);
            }
            return KeyEventResult.ignored;
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColor.darkSurface : AppColor.lightSurface,
              border: Border.all(
                color: borderColor,
                width: isFocused ? 1.8 : 1.2,
              ),
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: widget.controllers[index],
              focusNode: widget.focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: AppTypography.titleLarge.copyWith(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (val) => _onChanged(val, index),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                counterText: '',
              ),
            ),
          ),
        );
      }),
    );
  }
}
