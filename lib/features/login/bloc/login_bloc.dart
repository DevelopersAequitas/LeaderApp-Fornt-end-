import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/formatting/phone_number_helper.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/error_formatter.dart';
import '../../../data/repositories/auth_repository.dart';
import '../model/send_otp_result_model.dart';
import 'login_event.dart';
import 'login_state.dart';

/// Business Logic Component for managing user sign-in forms with real API integration.
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc({
    AuthRepository? authRepository,
    String? initialCountryCode,
  })  : _authRepository = authRepository ?? AuthRepositoryImpl(),
        super(_initialState(initialCountryCode)) {
    on<EmailOrPhoneChanged>(_onEmailOrPhoneChanged);
    on<LoginChannelChanged>(_onChannelChanged);
    on<LoginCountryChanged>(_onCountryChanged);
    on<SubmitLogin>(_onSubmitLogin);
    on<DismissNotLeaderNotice>(_onDismissNotLeaderNotice);
  }

  static LoginState _initialState(String? initialCountryCode) {
    final country = PhoneNumberHelper.resolveCountry(
      countryIso: initialCountryCode,
    );
    return LoginState(
      countryCode: country.countryCode,
      dialCode: '+${country.phoneCode}',
      flag: country.flagEmoji,
    );
  }

  void _onEmailOrPhoneChanged(
    EmailOrPhoneChanged event,
    Emitter<LoginState> emit,
  ) {
    final value = event.value;
    emit(
      state.copyWith(
        emailOrPhone: value,
        isFormValid: _isValidForChannel(
          value,
          state.channel,
          countryCode: state.countryCode,
        ),
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
        isFormValid: _isValidForChannel(
          state.emailOrPhone,
          event.channel,
          countryCode: state.countryCode,
        ),
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
    final resolvedIso = event.countryCode?.trim().toUpperCase() ??
        PhoneNumberHelper.isoCodeFromDialCode(event.dialCode) ??
        state.countryCode;
    emit(
      state.copyWith(
        countryCode: resolvedIso,
        dialCode: event.dialCode,
        flag: event.flag,
        isFormValid: _isValidForChannel(
          state.emailOrPhone,
          state.channel,
          countryCode: resolvedIso,
        ),
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
    final rawIdentifier = (event.identifier ?? state.emailOrPhone).trim();
    String identifierToSubmit = rawIdentifier;

    if (state.channel == 'whatsapp') {
      final phoneResult = PhoneNumberHelper.validate(
        rawIdentifier,
        countryIso: state.countryCode,
        dialCode: state.dialCode,
      );
      if (!phoneResult.isValid || phoneResult.e164 == null) {
        emit(
          state.copyWith(
            errorMessage: phoneResult.errorMessage ??
                'Please enter a valid mobile number.',
            isOtpSent: false,
            isNotLeader: false,
            isAccountUnregistered: false,
          ),
        );
        return;
      }
      // Backend contract (`POST /leader/auth/send-otp` & `verify-otp`) expects
      // E.164 format (`+<countryCode><nsn>`).
      identifierToSubmit = phoneResult.e164!;
    } else {
      if (rawIdentifier.isEmpty ||
          !_isValidForChannel(
            rawIdentifier,
            state.channel,
            countryCode: state.countryCode,
          )) {
        emit(
          state.copyWith(
            errorMessage: 'Please enter a valid email address.',
            isOtpSent: false,
            isNotLeader: false,
            isAccountUnregistered: false,
          ),
        );
        return;
      }
    }

    emit(
      state.copyWith(
        emailOrPhone: identifierToSubmit,
        isLoading: true,
        errorMessage: '',
        successMessage: '',
        isOtpSent: false,
        isNotLeader: false,
        isAccountUnregistered: false,
      ),
    );

    try {
      final response = await _authRepository.sendOtp(identifierToSubmit);
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
  bool _isValidForChannel(
    String value,
    String channel, {
    required String countryCode,
  }) {
    final cleanValue = value.trim();
    if (cleanValue.isEmpty) return false;

    if (channel == 'whatsapp') {
      return PhoneNumberHelper.validate(
        cleanValue,
        countryIso: countryCode,
      ).isValid;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,6}$');
    if (emailRegex.hasMatch(cleanValue)) return true;

    // Also allow international phone entry when user explicitly provides '+'.
    if (cleanValue.startsWith('+')) {
      return PhoneNumberHelper.validate(
        cleanValue,
        countryIso: countryCode,
      ).isValid;
    }
    return false;
  }
}
