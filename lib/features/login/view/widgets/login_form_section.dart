import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/widgets/primary_button.dart';
import 'country_picker_bottom_sheet.dart';
import 'login_footer_section.dart';
import 'login_input_field.dart';
import 'not_a_leader_card.dart';
import 'otp_channel_selector.dart';

/// Login form section matching Peers Global Unity (Email / WhatsApp toggle + Send OTP button),
/// without account registration links since Leader App is login-only.
class LoginFormSection extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final String selectedChannel;
  final String dialCode;
  final String flag;
  final Country selectedCountry;
  final bool isLoading;
  final bool isNotLeader;
  final bool isAccountUnregistered;
  final ValueChanged<String> onInputChanged;
  final ValueChanged<String> onChannelChanged;
  final ValueChanged<Country> onCountryChanged;
  final VoidCallback onSendOtp;
  final VoidCallback? onDismissNotLeader;

  const LoginFormSection({
    super.key,
    required this.emailController,
    required this.phoneController,
    required this.selectedChannel,
    required this.dialCode,
    required this.flag,
    required this.selectedCountry,
    required this.isLoading,
    this.isNotLeader = false,
    this.isAccountUnregistered = false,
    required this.onInputChanged,
    required this.onChannelChanged,
    required this.onCountryChanged,
    required this.onSendOtp,
    this.onDismissNotLeader,
  });

  void _openCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.transparent,
      builder: (_) => CountryPickerBottomSheet(
        selectedCountry: selectedCountry,
        onCountrySelected: onCountryChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWhatsapp = selectedChannel == 'whatsapp';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LoginInputField(
          controller: isWhatsapp ? phoneController : emailController,
          isWhatsapp: isWhatsapp,
          dialCode: dialCode,
          flag: flag,
          onChanged: onInputChanged,
          onCountryTap: () => _openCountryPicker(context),
          onSubmit: onSendOtp,
        ),
        const SizedBox(height: 16),
        OtpChannelSelector(
          selectedChannel: selectedChannel,
          onChannelChanged: onChannelChanged,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: isNotLeader
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: NotALeaderCard(
                    isAccountUnregistered: isAccountUnregistered,
                    onDismiss: onDismissNotLeader,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Send OTP',
          trailingIcon: Icons.arrow_forward_rounded,
          isLoading: isLoading,
          height: 48,
          borderRadius: 24,
          gradient: AppColor.brandGradient,
          onPressed: isLoading ? null : onSendOtp,
        ),
        const SizedBox(height: 32),
        const LoginFooterSection(),
      ],
    );
  }
}
