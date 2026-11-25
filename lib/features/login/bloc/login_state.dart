/// Represents the state of the sign-in screen, including form inputs, channel, validation status, and loading states.
class LoginState {
  /// The current email or phone number input.
  final String emailOrPhone;

  /// Active verification channel ('email' or 'whatsapp').
  final String channel;

  /// Selected ISO 3166-1 alpha-2 country code for WhatsApp phone login (e.g., 'US', 'GB', 'IN').
  final String countryCode;

  /// Selected country dial code for WhatsApp phone login (e.g., '+1', '+44', '+91').
  final String dialCode;

  /// Selected country flag emoji.
  final String flag;

  /// True if the current input is a valid email or phone format.
  final bool isFormValid;

  /// True if the login submit request is currently loading.
  final bool isLoading;

  /// Error message to display, if any.
  final String errorMessage;

  /// Success message returned by the server when OTP is sent.
  final String successMessage;

  /// True if the OTP was successfully sent.
  final bool isOtpSent;

  /// OTP expiry duration in seconds returned by `POST /api/v1/leader/auth/send-otp` (defaults to 300).
  final int otpExpirySeconds;

  /// True when a user without a leadership role (or unregistered account) attempts to sign in.
  /// Renders a persistent card with a direct link to the "Become a Leader" screen in Peers Global.
  final bool isNotLeader;

  /// True when the account was not found at all (`is_registered == false`), false when registered as a regular peer.
  final bool isAccountUnregistered;

  const LoginState({
    this.emailOrPhone = '',
    this.channel = 'email',
    this.countryCode = 'US',
    this.dialCode = '+1',
    this.flag = '🇺🇸',
    this.isFormValid = false,
    this.isLoading = false,
    this.errorMessage = '',
    this.successMessage = '',
    this.isOtpSent = false,
    this.otpExpirySeconds = 300,
    this.isNotLeader = false,
    this.isAccountUnregistered = false,
  });

  /// Helper to copy the state with updated parameters.
  LoginState copyWith({
    String? emailOrPhone,
    String? channel,
    String? countryCode,
    String? dialCode,
    String? flag,
    bool? isFormValid,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool? isOtpSent,
    int? otpExpirySeconds,
    bool? isNotLeader,
    bool? isAccountUnregistered,
  }) {
    return LoginState(
      emailOrPhone: emailOrPhone ?? this.emailOrPhone,
      channel: channel ?? this.channel,
      countryCode: countryCode ?? this.countryCode,
      dialCode: dialCode ?? this.dialCode,
      flag: flag ?? this.flag,
      isFormValid: isFormValid ?? this.isFormValid,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      otpExpirySeconds: otpExpirySeconds ?? this.otpExpirySeconds,
      isNotLeader: isNotLeader ?? this.isNotLeader,
      isAccountUnregistered:
          isAccountUnregistered ?? this.isAccountUnregistered,
    );
  }
}
