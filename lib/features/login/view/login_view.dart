import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_color.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import 'widgets/login_ambient_background.dart';
import 'widgets/login_form_section.dart';
import 'widgets/login_header_section.dart';

/// The View component of the Sign-In portal feature, matching Peers Global Unity
/// with Email and WhatsApp verification channels (login-only, no registration).
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (context) => LoginBloc(),
      child: const _LoginContent(),
    );
  }
}

class _LoginContent extends StatefulWidget {
  const _LoginContent();

  @override
  State<_LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<_LoginContent> {
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  Country _selectedCountry = Country.parse('IN');

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _currentIdentifier(LoginState state) {
    if (state.channel == 'whatsapp') {
      final rawDigits =
          _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
      if (rawDigits.isEmpty) return '';
      final code = state.dialCode.startsWith('+')
          ? state.dialCode
          : '+${state.dialCode}';
      return '$code$rawDigits';
    }
    return _emailController.text.trim();
  }

  void _onInputChanged(BuildContext context, LoginState state) {
    context.read<LoginBloc>().add(
          EmailOrPhoneChanged(_currentIdentifier(state)),
        );
  }

  void _onChannelChanged(BuildContext context, String channel, LoginState state) {
    FocusScope.of(context).unfocus();
    final nextState = state.copyWith(channel: channel);
    context.read<LoginBloc>()
      ..add(LoginChannelChanged(channel))
      ..add(EmailOrPhoneChanged(_currentIdentifier(nextState)));
  }

  void _onCountryChanged(BuildContext context, Country country, LoginState state) {
    setState(() {
      _selectedCountry = country;
    });
    final dialCode = '+${country.phoneCode}';
    final flag = country.flagEmoji;
    final nextState = state.copyWith(dialCode: dialCode, flag: flag);
    context.read<LoginBloc>()
      ..add(LoginCountryChanged(dialCode: dialCode, flag: flag))
      ..add(EmailOrPhoneChanged(_currentIdentifier(nextState)));
  }

  void _onSendOtp(BuildContext context, LoginState state) {
    FocusScope.of(context).unfocus();
    final identifier = _currentIdentifier(state);
    context.read<LoginBloc>().add(SubmitLogin(identifier: identifier));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.isOtpSent) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.successMessage.isNotEmpty
                    ? state.successMessage
                    : 'Verification code sent!',
              ),
              backgroundColor: AppColor.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pushNamed(
            AppRoutes.otp,
            arguments: {
              'emailOrPhone': state.emailOrPhone,
              'channel': state.channel,
              'otpExpirySeconds': state.otpExpirySeconds,
            },
          );
        } else if (state.isNotLeader) {
          // Hide any temporary SnackBar so the persistent in-screen NotALeaderCard is shown cleanly
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
      builder: (context, state) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
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
                          LoginHeaderSection(
                            channel: state.channel,
                            onBack: Navigator.of(context).canPop()
                                ? () => Navigator.of(context).pop()
                                : null,
                          ),
                          const SizedBox(height: 24),
                          LoginFormSection(
                            emailController: _emailController,
                            phoneController: _phoneController,
                            selectedChannel: state.channel,
                            dialCode: state.dialCode,
                            flag: state.flag,
                            selectedCountry: _selectedCountry,
                            isLoading: state.isLoading,
                            isNotLeader: state.isNotLeader,
                            isAccountUnregistered: state.isAccountUnregistered,
                            onInputChanged: (_) =>
                                _onInputChanged(context, state),
                            onChannelChanged: (ch) =>
                                _onChannelChanged(context, ch, state),
                            onCountryChanged: (c) =>
                                _onCountryChanged(context, c, state),
                            onSendOtp: () => _onSendOtp(context, state),
                            onDismissNotLeader: () => context
                                .read<LoginBloc>()
                                .add(const DismissNotLeaderNotice()),
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
