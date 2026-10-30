import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../login/view/widgets/not_a_leader_card.dart';
import '../../bloc/otp_bloc.dart';
import '../../bloc/otp_event.dart';
import '../../bloc/otp_state.dart';
import 'otp_input_fields.dart';
import 'otp_resend_section.dart';

/// Form section wrapping the title, 6-digit circular OTP inputs, resend timer,
/// and pill-shaped "Verify & Continue" button — matching Peers Global Unity.
class OtpFormCard extends StatelessWidget {
  final String emailOrPhone;
  final String channel;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final VoidCallback onSubmit;

  const OtpFormCard({
    super.key,
    required this.emailOrPhone,
    this.channel = 'email',
    required this.controllers,
    required this.focusNodes,
    required this.onSubmit,
  });

  String get _formattedTarget {
    if (emailOrPhone.isEmpty) return '';
    return ' ($emailOrPhone)';
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<OtpBloc>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final secondaryTextColor =
        isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;

    final subtitle = channel == 'whatsapp'
        ? 'Enter the 6-digit code sent to your registered WhatsApp number$_formattedTarget'
        : 'Enter the 6-digit code sent to your registered email address$_formattedTarget';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Enter OTP',
          style: AppTypography.displayMedium.copyWith(
            color: primaryTextColor,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: AppTypography.bodyMedium.copyWith(
            color: secondaryTextColor,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 32),
        OtpInputFields(
          controllers: controllers,
          focusNodes: focusNodes,
          onOtpChanged: (code) {
            bloc.add(OtpInputChanged(code));
          },
          onCompleted: (_) => onSubmit(),
        ),
        const SizedBox(height: 32),
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
        BlocBuilder<OtpBloc, OtpState>(
          buildWhen: (p, c) => p.isNotLeader != c.isNotLeader,
          builder: (context, state) {
            if (!state.isNotLeader) return const SizedBox.shrink();
            return const Padding(
              padding: EdgeInsets.only(top: 16),
              child: NotALeaderCard(),
            );
          },
        ),
        const SizedBox(height: 48),
        BlocBuilder<OtpBloc, OtpState>(
          builder: (context, state) {
            return PrimaryButton(
              label: 'Verify & Continue',
              isLoading: state.isLoading,
              height: 48,
              borderRadius: 24,
              gradient: AppColor.brandGradient,
              onPressed: state.isLoading ? null : onSubmit,
            );
          },
        ),
      ],
    );
  }
}
