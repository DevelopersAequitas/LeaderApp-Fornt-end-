// ==============================================================================
// File: lib/features/otp/view/otp_view.dart
// Description: Multi-Digit One-Time Password (OTP) Verification Screen
// Framework: Flutter | Architecture: MVP View Layer (100% Pure StatelessWidget + BLoC)
// Features:
//   - 6-digit individual input pin fields with keyboard navigation & backspace traversal
//   - Live countdown resend timer driven by `OtpBloc`
//   - Cryptographic session initialization on success
//   - Automated redirection to Home on verified authentication
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/otp_bloc.dart';
import '../bloc/otp_event.dart';
import '../bloc/otp_state.dart';
import 'widgets/otp_form_card.dart';
import 'widgets/otp_header_section.dart';

/// The View component of the OTP Verification feature.
/// Pure StatelessWidget powered 100% by BLoC state machine.
class OtpView extends StatelessWidget {
  final String emailOrPhone;

  const OtpView({super.key, required this.emailOrPhone});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OtpBloc>(
      create: (context) => OtpBloc(emailOrPhone: emailOrPhone),
      child: _OtpContent(emailOrPhone: emailOrPhone),
    );
  }
}

class _OtpContent extends StatelessWidget {
  final String emailOrPhone;
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  _OtpContent({required this.emailOrPhone});

  void _handleSubmit(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<OtpBloc>().add(const SubmitOtpVerification());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OtpBloc, OtpState>(
      listener: (context, state) {
        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login verified! Welcome to Leader App.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
        } else if (state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const OtpHeaderSection(),
                OtpFormCard(
                  emailOrPhone: emailOrPhone,
                  controllers: _controllers,
                  focusNodes: _focusNodes,
                  onSubmit: () => _handleSubmit(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
