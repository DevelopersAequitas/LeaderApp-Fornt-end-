import 'package:flutter/material.dart';

@immutable
class OtpState {
  /// The currently entered OTP digits.
  final String otpCode;

  /// True if the OTP code entered is exactly 4 digits long.
  final bool isFormValid;

  /// True if validation is in progress.
  final bool isLoading;

  /// True if OTP is successfully verified.
  final bool isSuccess;

  /// Error message, if verification fails.
  final String errorMessage;

  /// Number of seconds left before resending is allowed.
  final int resendCountdown;

  /// True if the countdown timer has completed (reaches 0).
  final bool canResend;

  const OtpState({
    this.otpCode = '',
    this.isFormValid = false,
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage = '',
    this.resendCountdown = 30,
    this.canResend = false,
  });

  /// Helper to copy the state with updated parameters.
  OtpState copyWith({
    String? otpCode,
    bool? isFormValid,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    int? resendCountdown,
    bool? canResend,
  }) {
    return OtpState(
      otpCode: otpCode ?? this.otpCode,
      isFormValid: isFormValid ?? this.isFormValid,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      resendCountdown: resendCountdown ?? this.resendCountdown,
      canResend: canResend ?? this.canResend,
    );
  }
}
