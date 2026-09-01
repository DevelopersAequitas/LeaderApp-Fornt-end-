// ==============================================================================
// File: lib/features/otp/view/otp_view.dart
// Description: Multi-Digit One-Time Password (OTP) Verification Screen
// Framework: Flutter | Architecture: MVP View Layer (BLoC State Driven)
// Features:
//   - Deep Navy curved top banner with white brand emblem & back navigation
//   - Clean white bottom sheet with 6-digit PIN input & robust resend delay
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

class _OtpContent extends StatefulWidget {
  final String emailOrPhone;

  const _OtpContent({required this.emailOrPhone});

  @override
  State<_OtpContent> createState() => _OtpContentState();
}

class _OtpContentState extends State<_OtpContent> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

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
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
        } else if (state.resendSuccessMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.resendSuccessMessage),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Top Navy Brand Banner
                      Expanded(
                        flex: 4,
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF0A1828),
                                AppColors.primary,
                                Color(0xFF1B3B60),
                              ],
                            ),
                          ),
                          child: SafeArea(
                            bottom: false,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Ambient circle decorations
                                Positioned(
                                  top: -40,
                                  right: -40,
                                  child: Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.04),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -20,
                                  left: -30,
                                  child: Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.03),
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 8.0, bottom: 28.0),
                                  child: OtpHeaderSection(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Bottom White Curved Sheet
                      Expanded(
                        flex: 6,
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 20,
                                offset: Offset(0, -4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.fromLTRB(24.0, 36.0, 24.0, 24.0),
                          child: SafeArea(
                            top: false,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                OtpFormCard(
                                  emailOrPhone: widget.emailOrPhone,
                                  controllers: _controllers,
                                  focusNodes: _focusNodes,
                                  onSubmit: () => _handleSubmit(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
