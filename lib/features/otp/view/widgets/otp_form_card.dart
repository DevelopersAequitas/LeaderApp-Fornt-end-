import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../bloc/otp_bloc.dart';
import '../../bloc/otp_event.dart';
import '../../bloc/otp_state.dart';
import 'otp_input_fields.dart';
import 'otp_resend_section.dart';

/// Form card container wrapping inputs, instructions, resend timer and verify button.
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

    return Transform.translate(
      offset: const Offset(0, -24),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Slide indicators
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 24,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Enter verification code',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                letterSpacing: -0.5,
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
                  const TextSpan(text: 'We have sent a 6-digit verification code to '),
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
            const SizedBox(height: 32),
            OtpInputFields(
              controllers: controllers,
              focusNodes: focusNodes,
              onOtpChanged: (code) => bloc.add(OtpInputChanged(code)),
            ),
            const SizedBox(height: 24),
            BlocBuilder<OtpBloc, OtpState>(
              buildWhen: (p, c) =>
                  p.resendCountdown != c.resendCountdown || p.canResend != c.canResend,
              builder: (context, state) {
                return OtpResendSection(
                  countdown: state.resendCountdown,
                  canResend: state.canResend,
                  onResend: () => bloc.add(const ResendOtpRequested()),
                );
              },
            ),
            const SizedBox(height: 32),
            BlocBuilder<OtpBloc, OtpState>(
              builder: (context, state) {
                return PrimaryButton(
                  label: 'Verify & Proceed',
                  onPressed: (state.isFormValid && !state.isLoading) ? onSubmit : null,
                  isLoading: state.isLoading,
                  trailingIcon: Icons.arrow_forward_rounded,
                );
              },
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
