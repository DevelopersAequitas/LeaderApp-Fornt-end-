import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import 'gradient_widgets.dart';

/// Full-width gradient (or outlined) action button.
///
/// [height] is a **minimum** height: a label that fits on one line keeps
/// exactly that height (so existing screens look the same), while a label too
/// long for the available width wraps onto more lines and the button grows
/// instead of overflowing. Icons stay vertically centred next to the text.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? color;
  final Gradient? gradient;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double height;
  final double borderRadius;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.color,
    this.gradient,
    this.leadingIcon,
    this.trailingIcon,
    this.height = 52.0,
    this.borderRadius = 12.0,
  });

  /// Breathing room that only matters once the label wraps. Small enough that
  /// a single line (even at 1.3x text scale, ~25 px) plus this padding still
  /// fits inside [height], so one-line buttons keep their exact design height
  /// (34 px buttons use 3, taller ones 6 vertical).
  EdgeInsets get _contentPadding =>
      EdgeInsets.symmetric(horizontal: 8, vertical: height >= 44 ? 6 : 3);

  Widget _row({
    required Widget? leading,
    required Widget text,
    required Widget? trailing,
  }) {
    return Padding(
      padding: _contentPadding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leading != null) ...[leading, const SizedBox(width: 8)],
          // Flexible (loose): short labels keep their natural width and stay
          // centred; long labels take the remaining width and wrap.
          Flexible(child: text),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? AppColor.brandGradient;

    if (isOutlined) {
      return SizedBox(
        width: double.infinity,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: height),
          child: Container(
            decoration: BoxDecoration(
              gradient: effectiveGradient,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: const EdgeInsets.all(1.5),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(borderRadius - 1.5),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isLoading ? null : onPressed,
                  borderRadius: BorderRadius.circular(borderRadius - 1.5),
                  child: Center(
                    heightFactor: 1.0,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColor.primaryBlue,
                              ),
                            ),
                          )
                        : _row(
                            leading: leadingIcon == null
                                ? null
                                : GradientIcon(
                                    icon: leadingIcon!,
                                    size: 18,
                                    gradient: effectiveGradient,
                                  ),
                            text: GradientText(
                              label,
                              gradient: effectiveGradient,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: trailingIcon == null
                                ? null
                                : GradientIcon(
                                    icon: trailingIcon!,
                                    size: 18,
                                    gradient: effectiveGradient,
                                  ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      width: double.infinity,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: height),
        child: Container(
          decoration: BoxDecoration(
            gradient: isEnabled ? effectiveGradient : null,
            color: isEnabled ? null : AppColor.disabled,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: AppColor.primaryBlue.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? onPressed : null,
              borderRadius: BorderRadius.circular(borderRadius),
              child: Center(
                heightFactor: 1.0,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : _row(
                        leading: leadingIcon == null
                            ? null
                            : Icon(leadingIcon, color: Colors.white, size: 18),
                        text: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: trailingIcon == null
                            ? null
                            : Icon(trailingIcon, color: Colors.white, size: 18),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
