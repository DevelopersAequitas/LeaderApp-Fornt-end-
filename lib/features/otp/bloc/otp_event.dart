import 'package:flutter/material.dart';

@immutable
abstract class OtpEvent {
  const OtpEvent();
}

/// Dispatched when the user inputs or changes the OTP digits.
class OtpInputChanged extends OtpEvent {
  final String otp;
  const OtpInputChanged(this.otp);
}

/// Dispatched when the user triggers the verification step.
class SubmitOtpVerification extends OtpEvent {
  const SubmitOtpVerification();
}

/// Dispatched when the user requests a new OTP to be sent.
class ResendOtpRequested extends OtpEvent {
  const ResendOtpRequested();
}

/// Dispatched by the internal timer logic to decrement remaining seconds.
class TimerTicked extends OtpEvent {
  final int remainingSeconds;
  const TimerTicked(this.remainingSeconds);
}
