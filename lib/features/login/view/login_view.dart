// ==============================================================================
// File: lib/features/login/view/login_view.dart
// Description: Secure Authentication & Mobile/Email Sign-In Portal
// Framework: Flutter | Architecture: MVP View Layer (100% Pure StatelessWidget + BLoC)
// Features:
//   - High-contrast responsive login header with brand emblem
//   - Phone number and email input handling with client-side validation
//   - Dispatches `SubmitLogin` event to `LoginBloc`
//   - Transitions automatically to `OtpView` upon successful OTP dispatch
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_routes.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import 'widgets/login_form_section.dart';
import 'widgets/login_header_section.dart';

/// The View component of the Sign-In portal feature.
/// Pure StatelessWidget powered 100% by BLoC state machine.
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (context) => LoginBloc(),
      child: _LoginContent(),
    );
  }
}

class _LoginContent extends StatelessWidget {
  _LoginContent();

  final _inputController = TextEditingController();

  void _handleSubmit(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<LoginBloc>().add(const SubmitLogin());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.isOtpSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent successfully! Please verify.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushNamed(
            AppRoutes.otp,
            arguments: state.emailOrPhone,
          );
        } else if (state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          const LoginHeaderSection(),
                          const SizedBox(height: 36),
                          LoginFormSection(
                            inputController: _inputController,
                            onSubmit: () => _handleSubmit(context),
                          ),
                          const Spacer(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
