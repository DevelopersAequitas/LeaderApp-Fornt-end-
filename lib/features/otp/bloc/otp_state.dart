import 'package:flutter/material.dart';

@immutable
class OtpState {
  /// The currently entered OTP digits.
  final String otpCode;

  /// True if the OTP code entered is exactly 6 digits long.
  final bool isFormValid;

  /// True if verification is in progress.
  final bool isLoading;

  /// True if resend request is in progress.
  final bool isResending;

  /// True if OTP is successfully verified.
  final bool isSuccess;

  /// Error message, if verification or resend fails.
  final String errorMessage;

  /// Success message when OTP is resent.
  final String resendSuccessMessage;

  /// Number of seconds left before resending is allowed.
  final int resendCountdown;

  /// Total duration in seconds for the current countdown cycle.
  final int totalCountdown;

  /// Number of times resend has been requested in this session.
  final int resendAttempt;

  /// True if the countdown timer has completed (reaches 0).
  final bool canResend;

  const OtpState({
    this.otpCode = '',
    this.isFormValid = false,
    this.isLoading = false,
    this.isResending = false,
    this.isSuccess = false,
    this.errorMessage = '',
    this.resendSuccessMessage = '',
    this.resendCountdown = 30,
    this.totalCountdown = 30,
    this.resendAttempt = 0,
    this.canResend = false,
  });

  /// Helper to copy the state with updated parameters.
  OtpState copyWith({
    String? otpCode,
    bool? isFormValid,
    bool? isLoading,
    bool? isResending,
    bool? isSuccess,
    String? errorMessage,
    String? resendSuccessMessage,
    int? resendCountdown,
    int? totalCountdown,
    int? resendAttempt,
    bool? canResend,
  }) {
    return OtpState(
      otpCode: otpCode ?? this.otpCode,
      isFormValid: isFormValid ?? this.isFormValid,
      isLoading: isLoading ?? this.isLoading,
      isResending: isResending ?? this.isResending,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      resendSuccessMessage: resendSuccessMessage ?? this.resendSuccessMessage,
      resendCountdown: resendCountdown ?? this.resendCountdown,
      totalCountdown: totalCountdown ?? this.totalCountdown,
      resendAttempt: resendAttempt ?? this.resendAttempt,
      canResend: canResend ?? this.canResend,
    );
  }
}
