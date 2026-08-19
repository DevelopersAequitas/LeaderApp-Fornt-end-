import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'otp_event.dart';
import 'otp_state.dart';

/// Business Logic Component for managing OTP verification and countdown timer.
class OtpBloc extends Bloc<OtpEvent, OtpState> {
  StreamSubscription<int>? _timerSubscription;

  OtpBloc() : super(const OtpState()) {
    on<OtpInputChanged>(_onOtpInputChanged);
    on<SubmitOtpVerification>(_onSubmitOtpVerification);
    on<ResendOtpRequested>(_onResendOtpRequested);
    on<TimerTicked>(_onTimerTicked);

    _startTimer();
  }

  void _startTimer() {
    _timerSubscription?.cancel();
    // Emits 29 down to 0
    _timerSubscription = Stream.periodic(
      const Duration(seconds: 1),
      (tick) => 29 - tick,
    ).take(30).listen((secondsLeft) {
      add(TimerTicked(secondsLeft));
    });
  }

  void _onOtpInputChanged(OtpInputChanged event, Emitter<OtpState> emit) {
    final value = event.otp;
    emit(
      state.copyWith(
        otpCode: value,
        isFormValid: value.length == 4,
        errorMessage: '',
      ),
    );
  }

  Future<void> _onSubmitOtpVerification(
    SubmitOtpVerification event,
    Emitter<OtpState> emit,
  ) async {
    if (!state.isFormValid) return;
    emit(state.copyWith(isLoading: true, errorMessage: '', isSuccess: false));

    try {
      // Simulate remote API call to verify OTP
      await Future.delayed(const Duration(milliseconds: 1000));
      if (state.otpCode == '1234') {
        _timerSubscription?.cancel();
        emit(state.copyWith(isLoading: false, isSuccess: true));
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Incorrect OTP. Use 1234 for demo verification.',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onResendOtpRequested(ResendOtpRequested event, Emitter<OtpState> emit) {
    if (!state.canResend) return;
    emit(
      state.copyWith(
        resendCountdown: 30,
        canResend: false,
        errorMessage: '',
      ),
    );
    _startTimer();
  }

  void _onTimerTicked(TimerTicked event, Emitter<OtpState> emit) {
    emit(
      state.copyWith(
        resendCountdown: event.remainingSeconds,
        canResend: event.remainingSeconds <= 0,
      ),
    );
  }

  @override
  Future<void> close() {
    _timerSubscription?.cancel();
    return super.close();
  }
}
