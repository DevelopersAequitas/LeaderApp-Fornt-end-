import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_state.dart';
import '../presenter/login_presenter.dart';

/// The View component of the Sign-In portal feature.
/// Renders a clean, production-ready sign-in form.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> implements LoginViewContract {
  late final LoginBloc _bloc;
  late final LoginPresenter _presenter;
  late final TextEditingController _inputController;

  bool _isFormValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bloc = LoginBloc();
    _presenter = LoginPresenter(view: this, bloc: _bloc);
    _inputController = TextEditingController();

    _inputController.addListener(() {
      _presenter.onEmailOrPhoneChanged(_inputController.text);
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _bloc.close();
    super.dispose();
  }

  // --- LoginViewContract Implementations ---

  @override
  void onLoginLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void onLoginSuccess() {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP sent successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.otp, arguments: _inputController.text.trim());
  }

  @override
  void onLoginError(String error) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sign in failed: $error'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  void onValidationChanged(bool isValid) {
    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>.value(
      value: _bloc,
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          _presenter.handleStateChange(state);
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Upper branding/portal title section
                  Container(
                    color: AppColors.primary,
                    padding: const EdgeInsets.only(top: 56, bottom: 52),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/whitelogo.png',
                            width: 180,
                            height: 180,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Leadership Portal',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // White sheet login form card
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 24.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top slide navigation pill indicators
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 24,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 6,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Sign in headers
                          const Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Enter your leadership credentials to access your portal.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Email/Phone Form Field Input
                          const Text(
                            'EMAIL ADDRESS OR PHONE NUMBER',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _inputController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) {
                              if (_isFormValid && !_isLoading) {
                                _presenter.submit();
                              }
                            },
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.text,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                                color: Colors.grey.shade400,
                                size: 22,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              hintText: 'name@example.com or +919876543210',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Subtext instruction guide
                          Text(
                            'Use your registered leader email address or phone number with country code.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Action trigger Send OTP Button
                          PrimaryButton(
                            label: 'Send OTP',
                            onPressed: (_isFormValid && !_isLoading)
                                ? () => _presenter.submit()
                                : null,
                            isLoading: _isLoading,
                            trailingIcon: Icons.arrow_forward_rounded,
                          ),
                          const SizedBox(height: 48),

                          // Security note
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
