import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../bloc/otp_bloc.dart';
import '../../bloc/otp_event.dart';
import '../../bloc/otp_state.dart';
import 'otp_input_fields.dart';
import 'otp_resend_section.dart';

/// Form section wrapping OTP inputs, recipient display, resend timer and verify button with auto-submit.
class OtpFormCard extends StatelessWidget {
  final String emailOrPhone;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final VoidCallback onSubmit;

  const OtpFormCard({
    super.key,
    required this.emailOrPhone,
    required this.controllers,
    required this.focusNodes,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<OtpBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Enter verification code',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            children: [
              const TextSpan(
                text: 'We have sent a 6-digit verification code to ',
              ),
              TextSpan(
                text: emailOrPhone,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        OtpInputFields(
          controllers: controllers,
          focusNodes: focusNodes,
          onOtpChanged: (code) {
            bloc.add(OtpInputChanged(code));
            // Auto-verify as soon as 6 digits are completed
            if (code.length == 6) {
              onSubmit();
            }
          },
        ),
        const SizedBox(height: 20),
        BlocBuilder<OtpBloc, OtpState>(
          buildWhen: (p, c) =>
              p.resendCountdown != c.resendCountdown ||
              p.canResend != c.canResend ||
              p.isResending != c.isResending,
          builder: (context, state) {
            return OtpResendSection(
              countdown: state.resendCountdown,
              canResend: state.canResend,
              isResending: state.isResending,
              onResend: () => bloc.add(const ResendOtpRequested()),
            );
          },
        ),
        const SizedBox(height: 24),
        BlocBuilder<OtpBloc, OtpState>(
          builder: (context, state) {
            final isEnabled = state.isFormValid && !state.isLoading;

            return SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isEnabled ? onSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  elevation: isEnabled ? 2 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: state.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Verify & Proceed',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
              ),
            );
          },
        ),
      ],
    );
  }
}
