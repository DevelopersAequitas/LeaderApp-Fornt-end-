import '../bloc/otp_bloc.dart';
import '../bloc/otp_event.dart';
import '../bloc/otp_state.dart';

/// Contract interface defining OTP view callbacks.
abstract class OtpViewContract {
  /// Invoked when verification starts.
  void onOtpLoading();

  /// Invoked when verification succeeds.
  void onOtpSuccess();

  /// Invoked when verification fails.
  void onOtpError(String error);

  /// Invoked when countdown timer changes.
  void onCountdownChanged(int secondsLeft, bool canResend);
}

/// Presenter coordinating visual actions and countdown timers for OTP Verification.
class OtpPresenter {
  /// View contract reference.
  final OtpViewContract view;

  /// BLoC reference.
  final OtpBloc bloc;

  OtpPresenter({required this.view, required this.bloc});

  /// Relays input modifications back to BLoC.
  void onCodeChanged(String code) {
    bloc.add(OtpInputChanged(code));
  }

  /// Requests validation of entered OTP.
  void submit() {
    bloc.add(const SubmitOtpVerification());
  }

  /// Requests resending OTP code.
  void resend() {
    bloc.add(const ResendOtpRequested());
  }

  /// Maps BLoC state changes back to view contract triggers.
  void handleStateChange(OtpState state) {
    view.onCountdownChanged(state.resendCountdown, state.canResend);

    if (state.isLoading) {
      view.onOtpLoading();
    }

    if (state.isSuccess) {
      view.onOtpSuccess();
    }

    if (state.errorMessage.isNotEmpty) {
      view.onOtpError(state.errorMessage);
    }
  }
}
