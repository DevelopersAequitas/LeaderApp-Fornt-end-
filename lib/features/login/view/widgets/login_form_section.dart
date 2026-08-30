import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../bloc/login_bloc.dart';
import '../../bloc/login_event.dart';
import '../../bloc/login_state.dart';

/// Card container housing the sign-in form inputs and action buttons.
class LoginFormSection extends StatelessWidget {
  final TextEditingController inputController;
  final VoidCallback onSubmit;

  const LoginFormSection({
    super.key,
    required this.inputController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LoginBloc>();

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
            // Sign in typography headers
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
            // Email/Phone input title
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
              controller: inputController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onChanged: (val) => bloc.add(EmailOrPhoneChanged(val)),
              onSubmitted: (_) => onSubmit(),
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
            // Subtext instruction
            Text(
              'Use your registered leader email address or phone number with country code.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            // Reactive Action Button
            BlocBuilder<LoginBloc, LoginState>(
              builder: (context, state) {
                return PrimaryButton(
                  label: 'Send OTP',
                  onPressed: (state.isFormValid && !state.isLoading)
                      ? onSubmit
                      : null,
                  isLoading: state.isLoading,
                  trailingIcon: Icons.arrow_forward_rounded,
                );
              },
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
