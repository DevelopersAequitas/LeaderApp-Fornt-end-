import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

/// Business Logic Component for managing user sign-in forms with real API integration.
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl(),
        super(const LoginState()) {
    on<EmailOrPhoneChanged>(_onEmailOrPhoneChanged);
    on<SubmitLogin>(_onSubmitLogin);
  }

  void _onEmailOrPhoneChanged(
    EmailOrPhoneChanged event,
    Emitter<LoginState> emit,
  ) {
    final value = event.value;
    emit(
      state.copyWith(
        emailOrPhone: value,
        isFormValid: _isValidEmailOrPhone(value),
        errorMessage: '',
        isOtpSent: false,
      ),
    );
  }

  Future<void> _onSubmitLogin(
    SubmitLogin event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.isFormValid) return;

    emit(state.copyWith(isLoading: true, errorMessage: '', isOtpSent: false));

    try {
      final response = await _authRepository.sendOtp(state.emailOrPhone);
      if (response.success) {
        emit(state.copyWith(isLoading: false, isOtpSent: true));
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: response.message ?? 'Failed to send OTP.',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  /// Validates whether the string is a valid email address or phone format.
  bool _isValidEmailOrPhone(String value) {
    final cleanValue = value.trim();
    if (cleanValue.isEmpty) return false;

    // Standard Email Regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    // Standard Phone Regex: allows optional country code '+' and 7 to 15 digits
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');

    return emailRegex.hasMatch(cleanValue) || phoneRegex.hasMatch(cleanValue);
  }
}
