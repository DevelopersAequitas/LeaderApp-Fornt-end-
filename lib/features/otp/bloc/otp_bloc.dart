import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import 'otp_event.dart';
import 'otp_state.dart';

/// Business Logic Component for managing OTP verification and robust countdown delay system.
class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final String emailOrPhone;
  final AuthRepository _authRepository;
  Timer? _timer;

  OtpBloc({
    required this.emailOrPhone,
    AuthRepository? authRepository,
  })  : _authRepository = authRepository ?? AuthRepositoryImpl(),
        super(const OtpState(resendCountdown: 30, totalCountdown: 30, canResend: false)) {
    on<OtpInputChanged>(_onOtpInputChanged);
    on<SubmitOtpVerification>(_onSubmitOtpVerification);
    on<ResendOtpRequested>(_onResendOtpRequested);
    on<TimerTicked>(_onTimerTicked);

    _startCountdownTimer(30);
  }

  void _startCountdownTimer(int seconds) {
    _timer?.cancel();
    int currentSeconds = seconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      currentSeconds--;
      if (currentSeconds <= 0) {
        timer.cancel();
        add(const TimerTicked(0));
      } else {
        add(TimerTicked(currentSeconds));
      }
    });
  }

  void _onOtpInputChanged(OtpInputChanged event, Emitter<OtpState> emit) {
    final value = event.otp;
    emit(
      state.copyWith(
        otpCode: value,
        isFormValid: value.length == 6,
        errorMessage: '',
        resendSuccessMessage: '',
      ),
    );
  }

  Future<void> _onSubmitOtpVerification(
    SubmitOtpVerification event,
    Emitter<OtpState> emit,
  ) async {
    if (!state.isFormValid || state.isLoading) return;
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: '',
        resendSuccessMessage: '',
        isSuccess: false,
      ),
    );

    try {
      final response =
          await _authRepository.verifyOtp(emailOrPhone, state.otpCode);
      if (response.success) {
        _timer?.cancel();
        emit(state.copyWith(isLoading: false, isSuccess: true));
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: response.message ?? 'Invalid verification code.',
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
    if (!state.canResend || state.isResending) return;

    emit(
      state.copyWith(
        isResending: true,
        errorMessage: '',
        resendSuccessMessage: '',
        canResend: false,
      ),
    );

    try {
      final response = await _authRepository.sendOtp(emailOrPhone);

      if (response.success) {
        final nextAttempt = state.resendAttempt + 1;
        // Standard progressive delay: 30s for attempt 1, 60s for attempt 2, 90s max
        final nextDelay = nextAttempt == 1
            ? 30
            : nextAttempt == 2
                ? 60
                : 90;

        emit(
          state.copyWith(
            isResending: false,
            resendAttempt: nextAttempt,
            resendCountdown: nextDelay,
            totalCountdown: nextDelay,
            canResend: false,
            resendSuccessMessage: 'New verification code sent successfully!',
          ),
        );

        _startCountdownTimer(nextDelay);
      } else {
        emit(
          state.copyWith(
            isResending: false,
            canResend: true,
            errorMessage: response.message ?? 'Failed to resend verification code.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isResending: false,
          canResend: true,
          errorMessage: e.toString(),
        ),
      );
    }
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
    _timer?.cancel();
    return super.close();
  }
}
