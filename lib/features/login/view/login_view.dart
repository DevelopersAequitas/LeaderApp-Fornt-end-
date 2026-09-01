// ==============================================================================
// File: lib/features/login/view/login_view.dart
// Description: Secure Authentication & Mobile/Email Sign-In Portal
// Framework: Flutter | Architecture: MVP View Layer (BLoC State Driven)
// Features:
//   - Deep Navy curved top banner with white brand emblem
//   - Clean white bottom sheet with Sign In form & Send OTP action
//   - Phone number and email input handling with client-side validation
//   - Dispatches `SubmitLogin` event to `LoginBloc`
//   - Transitions automatically to `OtpView` upon successful OTP dispatch
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import 'widgets/login_form_section.dart';
import 'widgets/login_header_section.dart';

/// The View component of the Sign-In portal feature.
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
  late final TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

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
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
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
                                // Subtle ambient circle decoration
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
                                  padding: EdgeInsets.symmetric(vertical: 36.0),
                                  child: LoginHeaderSection(),
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
                                LoginFormSection(
                                  inputController: _inputController,
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
