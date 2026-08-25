import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import 'otp_event.dart';
import 'otp_state.dart';

/// Business Logic Component for managing OTP verification and countdown timer with real API.
class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final String emailOrPhone;
  final AuthRepository _authRepository;
  StreamSubscription<int>? _timerSubscription;

  OtpBloc({
    required this.emailOrPhone,
    AuthRepository? authRepository,
  })  : _authRepository = authRepository ?? AuthRepositoryImpl(),
        super(const OtpState()) {
    on<OtpInputChanged>(_onOtpInputChanged);
    on<SubmitOtpVerification>(_onSubmitOtpVerification);
    on<ResendOtpRequested>(_onResendOtpRequested);
    on<TimerTicked>(_onTimerTicked);

    _startTimer();
  }

  void _startTimer() {
    _timerSubscription?.cancel();
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
        isFormValid: value.length == 6,
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
      final response = await _authRepository.verifyOtp(emailOrPhone, state.otpCode);
      if (response.success) {
        _timerSubscription?.cancel();
        emit(state.copyWith(isLoading: false, isSuccess: true));
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: response.message ?? 'Invalid OTP code.',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onResendOtpRequested(
    ResendOtpRequested event,
    Emitter<OtpState> emit,
  ) async {
    if (!state.canResend) return;
    emit(
      state.copyWith(
        resendCountdown: 30,
        canResend: false,
        errorMessage: '',
      ),
    );
    _startTimer();
    try {
      await _authRepository.sendOtp(emailOrPhone);
    } catch (_) {}
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
