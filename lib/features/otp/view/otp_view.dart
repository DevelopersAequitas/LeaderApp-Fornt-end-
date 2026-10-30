import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_color.dart';
import '../../login/view/widgets/login_ambient_background.dart';
import '../bloc/otp_bloc.dart';
import '../bloc/otp_event.dart';
import '../bloc/otp_state.dart';
import 'widgets/otp_form_card.dart';
import 'widgets/otp_header_section.dart';

/// The View component of the OTP Verification feature, matching Peers Global Unity
/// with a 6-digit verification code input.
class OtpView extends StatelessWidget {
  final String emailOrPhone;
  final String channel;
  final int otpExpirySeconds;

  const OtpView({
    super.key,
    required this.emailOrPhone,
    this.channel = 'email',
    this.otpExpirySeconds = 300,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OtpBloc>(
      create: (context) => OtpBloc(emailOrPhone: emailOrPhone),
      child: _OtpContent(
        emailOrPhone: emailOrPhone,
        channel: channel,
      ),
    );
  }
}

class _OtpContent extends StatefulWidget {
  final String emailOrPhone;
  final String channel;

  const _OtpContent({
    required this.emailOrPhone,
    required this.channel,
  });

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<OtpBloc, OtpState>(
      listener: (context, state) {
        if (state.isSuccess) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome back to Peers Leaders!'),
              backgroundColor: AppColor.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
        } else if (state.resendSuccessMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.resendSuccessMessage),
              backgroundColor: AppColor.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state.isNotLeader) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        } else if (state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColor.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: AppColor.transparent,
          statusBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor:
              isDark ? AppColor.darkBackground : AppColor.lightBackground,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor:
              isDark ? AppColor.darkBackground : AppColor.lightBackground,
          body: LoginAmbientBackground(
            child: SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        OtpHeaderSection(
                          onBack: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(height: 16),
                        OtpFormCard(
                          emailOrPhone: widget.emailOrPhone,
                          channel: widget.channel,
                          controllers: _controllers,
                          focusNodes: _focusNodes,
                          onSubmit: () => _handleSubmit(context),
                        ),
                        const SizedBox(height: 32),
                      ],
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
}
