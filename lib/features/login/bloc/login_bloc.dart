import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/error_formatter.dart';
import '../../../data/repositories/auth_repository.dart';
import '../model/send_otp_result_model.dart';
import 'login_event.dart';
import 'login_state.dart';

/// Business Logic Component for managing user sign-in forms with real API integration.
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl(),
        super(const LoginState()) {
    on<EmailOrPhoneChanged>(_onEmailOrPhoneChanged);
    on<LoginChannelChanged>(_onChannelChanged);
    on<LoginCountryChanged>(_onCountryChanged);
    on<SubmitLogin>(_onSubmitLogin);
    on<DismissNotLeaderNotice>(_onDismissNotLeaderNotice);
  }

  void _onEmailOrPhoneChanged(
    EmailOrPhoneChanged event,
    Emitter<LoginState> emit,
  ) {
    final value = event.value;
    emit(
      state.copyWith(
        emailOrPhone: value,
        isFormValid: _isValidForChannel(value, state.channel),
        errorMessage: '',
        successMessage: '',
        isOtpSent: false,
        isNotLeader: false,
        isAccountUnregistered: false,
      ),
    );
  }

  void _onChannelChanged(
    LoginChannelChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(
      state.copyWith(
        channel: event.channel,
        isFormValid: _isValidForChannel(state.emailOrPhone, event.channel),
        errorMessage: '',
        successMessage: '',
        isOtpSent: false,
        isNotLeader: false,
        isAccountUnregistered: false,
      ),
    );
  }

  void _onCountryChanged(
    LoginCountryChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(
      state.copyWith(
        dialCode: event.dialCode,
        flag: event.flag,
        errorMessage: '',
        successMessage: '',
        isOtpSent: false,
        isNotLeader: false,
        isAccountUnregistered: false,
      ),
    );
  }

  void _onDismissNotLeaderNotice(
    DismissNotLeaderNotice event,
    Emitter<LoginState> emit,
  ) {
    emit(
      state.copyWith(
        isNotLeader: false,
        isAccountUnregistered: false,
      ),
    );
  }

  Future<void> _onSubmitLogin(
    SubmitLogin event,
    Emitter<LoginState> emit,
  ) async {
    final identifier = (event.identifier ?? state.emailOrPhone).trim();

    if (identifier.isEmpty || !_isValidForChannel(identifier, state.channel)) {
      final invalidMsg = state.channel == 'whatsapp'
          ? 'Please enter a valid mobile number.'
          : 'Please enter a valid email address.';
      emit(
        state.copyWith(
          errorMessage: invalidMsg,
          isOtpSent: false,
          isNotLeader: false,
          isAccountUnregistered: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        emailOrPhone: identifier,
        isLoading: true,
        errorMessage: '',
        successMessage: '',
        isOtpSent: false,
        isNotLeader: false,
        isAccountUnregistered: false,
      ),
    );

    try {
      final response = await _authRepository.sendOtp(identifier);
      final data = response.data;
      final errorCode = (response.errorCode ?? '').toUpperCase();
      final resultModel = data != null
          ? SendOtpResultModel.fromJson(
              data,
              fallbackChannel: state.channel,
            )
          : null;

      // Handle both non-leader registered peers (`NOT_A_LEADER`) and unregistered accounts (`USER_NOT_FOUND`)
      // via the persistent Become a Leader card so the user gets a permanent link to Peers Global.
      if ((resultModel != null && !resultModel.isLeader) ||
          errorCode == 'NOT_A_LEADER' ||
          errorCode == 'USER_NOT_FOUND') {
        final isUnregistered =
            (resultModel != null && !resultModel.isRegistered) ||
                errorCode == 'USER_NOT_FOUND';
        emit(
          state.copyWith(
            isLoading: false,
            isOtpSent: false,
            isNotLeader: true,
            isAccountUnregistered: isUnregistered,
            errorMessage: '',
          ),
        );
        return;
      }

      if (response.success) {
        final resolvedChannel = resultModel?.channel ?? state.channel;
        final expirySeconds = resultModel?.otpExpirySeconds ?? 300;
        final fallbackSuccessMessage = resolvedChannel == 'whatsapp'
            ? 'OTP has been sent successfully to your WhatsApp.'
            : 'OTP has been sent successfully to your registered email.';

        emit(
          state.copyWith(
            isLoading: false,
            isOtpSent: true,
            channel: resolvedChannel,
            otpExpirySeconds: expirySeconds,
            isNotLeader: false,
            isAccountUnregistered: false,
            successMessage: response.message?.isNotEmpty == true
                ? ErrorFormatter.format(response.message!)
                : fallbackSuccessMessage,
          ),
        );
      } else {
        final msg = response.message ?? '';
        if (_isNotLeaderResponse(message: msg)) {
          emit(
            state.copyWith(
              isLoading: false,
              isOtpSent: false,
              isNotLeader: true,
              isAccountUnregistered:
                  msg.toLowerCase().contains('no account found'),
              errorMessage: '',
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            isLoading: false,
            isNotLeader: false,
            isAccountUnregistered: false,
            errorMessage: response.message != null
                ? ErrorFormatter.format(response.message)
                : 'We couldn\'t send the code right now. Please check your details and try again.',
          ),
        );
      }
    } catch (e) {
      if (_isNotLeaderException(e)) {
        final isUnregistered = e is ApiException &&
            ((e.errorCode ?? '').toUpperCase() == 'USER_NOT_FOUND' ||
                e.statusCode == 404);
        emit(
          state.copyWith(
            isLoading: false,
            isOtpSent: false,
            isNotLeader: true,
            isAccountUnregistered: isUnregistered,
            errorMessage: '',
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          isLoading: false,
          isNotLeader: false,
          isAccountUnregistered: false,
          errorMessage: ErrorFormatter.format(e),
        ),
      );
    }
  }

  bool _isNotLeaderException(Object error) {
    if (error is ApiException) {
      final code = (error.errorCode ?? '').toUpperCase();
      if (code == 'NOT_A_LEADER' ||
          code == 'USER_NOT_FOUND' ||
          error.statusCode == 403 ||
          error.statusCode == 404) {
        return true;
      }
      if (_isNotLeaderResponse(message: error.message)) {
        return true;
      }
    }
    return _isNotLeaderResponse(message: error.toString());
  }

  bool _isNotLeaderResponse({required String message}) {
    final lower = message.toLowerCase();
    return lower.contains('not_a_leader') ||
        lower.contains('user_not_found') ||
        lower.contains('no account found') ||
        lower.contains('leadership role') ||
        lower.contains('not a leader') ||
        lower.contains('assigned leadership');
  }

  /// Validates whether the string is valid for the selected channel.
  bool _isValidForChannel(String value, String channel) {
    final cleanValue = value.trim();
    if (cleanValue.isEmpty) return false;

    if (channel == 'whatsapp') {
      final digits = cleanValue.replaceAll(RegExp(r'[^\d]'), '');
      return digits.length >= 7 && digits.length <= 15;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,6}$');
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    return emailRegex.hasMatch(cleanValue) || phoneRegex.hasMatch(cleanValue);
  }
}
