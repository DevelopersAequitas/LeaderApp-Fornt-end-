/// Represents the state of the sign-in screen, including form inputs, validation status, and loading states.
class LoginState {
  /// The current email or phone number input.
  final String emailOrPhone;

  /// True if the current input is a valid email or phone format.
  final bool isFormValid;

  /// True if the login submit request is currently loading.
  final bool isLoading;

  /// Error message to display, if any.
  final String errorMessage;

  /// True if the OTP was successfully sent (simulated).
  final bool isOtpSent;

  const LoginState({
    this.emailOrPhone = '',
    this.isFormValid = false,
    this.isLoading = false,
    this.errorMessage = '',
    this.isOtpSent = false,
  });

  /// Helper to copy the state with updated parameters.
  LoginState copyWith({
    String? emailOrPhone,
    bool? isFormValid,
    bool? isLoading,
    String? errorMessage,
    bool? isOtpSent,
  }) {
    return LoginState(
      emailOrPhone: emailOrPhone ?? this.emailOrPhone,
      isFormValid: isFormValid ?? this.isFormValid,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isOtpSent: isOtpSent ?? this.isOtpSent,
    );
  }
}
