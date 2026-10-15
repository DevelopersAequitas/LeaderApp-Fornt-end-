import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../bloc/login_bloc.dart';
import '../../bloc/login_event.dart';
import '../../bloc/login_state.dart';
import 'country_picker_bottom_sheet.dart';
import 'login_footer_section.dart';
import 'login_input_field.dart';

/// Clean Sign In form coordinating input field, submit action, and trust footer.
class LoginFormSection extends StatefulWidget {
  final TextEditingController inputController;
  final VoidCallback onSubmit;

  const LoginFormSection({
    super.key,
    required this.inputController,
    required this.onSubmit,
  });

  @override
  State<LoginFormSection> createState() => _LoginFormSectionState();
}

class _LoginFormSectionState extends State<LoginFormSection> {
  bool _hasText = false;
  Country _selectedCountry = Country.parse('IN');

  @override
  void initState() {
    super.initState();
    _hasText = widget.inputController.text.isNotEmpty;
    widget.inputController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    widget.inputController.removeListener(_onInputChanged);
    super.dispose();
  }

  bool _isNumericPhoneInput(String input) {
    final clean = input.trim();
    if (clean.isEmpty) return false;
    final hasLetterOrAt = RegExp(r'[a-zA-Z@]').hasMatch(clean);
    final hasDigits = RegExp(r'[0-9]').hasMatch(clean);
    return !hasLetterOrAt && hasDigits;
  }

  void _syncWithBloc() {
    final raw = widget.inputController.text.trim();
    final bloc = context.read<LoginBloc>();

    if (raw.isEmpty) {
      bloc.add(const EmailOrPhoneChanged(''));
      return;
    }

    if (_isNumericPhoneInput(raw)) {
      if (raw.startsWith('+')) {
        bloc.add(EmailOrPhoneChanged(raw));
      } else {
        bloc.add(EmailOrPhoneChanged('+${_selectedCountry.phoneCode}$raw'));
      }
    } else {
      bloc.add(EmailOrPhoneChanged(raw));
    }
  }

  void _onInputChanged() {
    final hasText = widget.inputController.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
    _syncWithBloc();
  }

  void _openCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CountryPickerBottomSheet(
        selectedCountry: _selectedCountry,
        onCountrySelected: (Country country) {
          setState(() => _selectedCountry = country);
          _syncWithBloc();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = _isNumericPhoneInput(widget.inputController.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Sign In',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter your email address or phone number to continue.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        LoginInputField(
          controller: widget.inputController,
          isPhone: isPhone,
          selectedCountry: _selectedCountry,
          hasText: _hasText,
          onCountryTap: () => _openCountryPicker(context),
          onClear: () => widget.inputController.clear(),
          onSubmit: widget.onSubmit,
        ),
        const SizedBox(height: 24),
        BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            final isEnabled = state.isFormValid && !state.isLoading;

            return PrimaryButton(
              label: 'Send OTP',
              trailingIcon: Icons.arrow_forward_rounded,
              isLoading: state.isLoading,
              height: 48,
              borderRadius: 24,
              gradient: AppColors.brandGradient,
              onPressed: isEnabled ? widget.onSubmit : null,
            );
          },
        ),
        const SizedBox(height: 24),
        const LoginFooterSection(),
      ],
    );
  }
}
