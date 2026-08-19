import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';

/// Business Logic Component for managing user sign-in forms.
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<EmailOrPhoneChanged>(_onEmailOrPhoneChanged);
    on<RoleSelected>(_onRoleSelected);
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

  void _onRoleSelected(RoleSelected event, Emitter<LoginState> emit) {
    final email = event.role.email;
    emit(
      state.copyWith(
        emailOrPhone: email,
        isFormValid: _isValidEmailOrPhone(email),
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
      // Simulate remote API call to send OTP (e.g. 1.5 seconds)
      await Future.delayed(const Duration(milliseconds: 1500));
      emit(state.copyWith(isLoading: false, isOtpSent: true));
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
