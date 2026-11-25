import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/core/network/api_response.dart';
import 'package:leaderapp/data/repositories/auth_repository.dart';
import 'package:leaderapp/features/login/bloc/login_bloc.dart';
import 'package:leaderapp/features/login/bloc/login_event.dart';

/// Fake repository: only `sendOtp` is used by the login screen.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this._onSendOtp);

  final Future<ApiResponse<Map<String, dynamic>>> Function(String id)
  _onSendOtp;
  final List<String> sentTo = [];

  @override
  Future<ApiResponse<Map<String, dynamic>>> sendOtp(String emailOrPhone) {
    sentTo.add(emailOrPhone);
    return _onSendOtp(emailOrPhone);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not used by login');
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('LoginBloc validation', () {
    test(
      'email channel accepts a valid email and rejects an invalid one',
      () async {
        final bloc = LoginBloc(
          authRepository: _FakeAuthRepository(
            (_) async => const ApiResponse(success: true),
          ),
        );
        addTearDown(bloc.close);

        bloc.add(const EmailOrPhoneChanged('not-an-email'));
        await _settle();
        expect(bloc.state.isFormValid, isFalse);

        bloc.add(const EmailOrPhoneChanged('leader@example.com'));
        await _settle();
        expect(bloc.state.isFormValid, isTrue);
      },
    );

    test(
      'whatsapp channel validates per selected country (IN, US, GB)',
      () async {
        final bloc = LoginBloc(
          initialCountryCode: 'IN',
          authRepository: _FakeAuthRepository(
            (_) async => const ApiResponse(success: true),
          ),
        );
        addTearDown(bloc.close);

        bloc.add(const LoginChannelChanged('whatsapp'));
        bloc.add(const EmailOrPhoneChanged('12345'));
        await _settle();
        expect(bloc.state.isFormValid, isFalse);

        // Valid Indian mobile
        bloc.add(const EmailOrPhoneChanged('9876543210'));
        await _settle();
        expect(bloc.state.isFormValid, isTrue);

        // Switching country to US re-validates the existing digits -> invalid in US
        bloc.add(
          const LoginCountryChanged(
            countryCode: 'US',
            dialCode: '+1',
            flag: '🇺🇸',
          ),
        );
        await _settle();
        expect(bloc.state.countryCode, 'US');
        expect(bloc.state.isFormValid, isFalse);

        // Valid US number
        bloc.add(const EmailOrPhoneChanged('(415) 555-2671'));
        await _settle();
        expect(bloc.state.isFormValid, isTrue);

        // Switch to UK and enter 11-digit national number with leading trunk 0
        bloc.add(
          const LoginCountryChanged(
            countryCode: 'GB',
            dialCode: '+44',
            flag: '🇬🇧',
          ),
        );
        bloc.add(const EmailOrPhoneChanged('07400 123456'));
        await _settle();
        expect(bloc.state.countryCode, 'GB');
        expect(bloc.state.isFormValid, isTrue);
      },
    );

    test(
      'submitting an invalid email shows an error and never calls the API',
      () async {
        final repo = _FakeAuthRepository(
          (_) async => const ApiResponse(success: true),
        );
        final bloc = LoginBloc(authRepository: repo);
        addTearDown(bloc.close);

        bloc.add(const SubmitLogin(identifier: 'oops'));
        await _settle();

        expect(bloc.state.errorMessage, 'Please enter a valid email address.');
        expect(bloc.state.isLoading, isFalse);
        expect(bloc.state.isOtpSent, isFalse);
        expect(repo.sentTo, isEmpty);
      },
    );

    test(
      'submitting empty or invalid WhatsApp phone never calls the API',
      () async {
        final repo = _FakeAuthRepository(
          (_) async => const ApiResponse(success: true),
        );
        final bloc = LoginBloc(initialCountryCode: 'GB', authRepository: repo);
        addTearDown(bloc.close);

        bloc.add(const LoginChannelChanged('whatsapp'));
        bloc.add(const SubmitLogin(identifier: ''));
        await _settle();
        expect(bloc.state.errorMessage, 'Please enter a phone number.');
        expect(repo.sentTo, isEmpty);

        bloc.add(const SubmitLogin(identifier: '12345'));
        await _settle();
        expect(bloc.state.errorMessage, contains('United Kingdom'));
        expect(repo.sentTo, isEmpty);
      },
    );
  });

  group('LoginBloc international E.164 payload compatibility', () {
    test(
      'normalizes IN, US, and GB phone inputs to E.164 for sendOtp',
      () async {
        final repo = _FakeAuthRepository(
          (_) async => const ApiResponse(
            success: true,
            data: {
              'is_registered': true,
              'is_leader': true,
              'channel': 'whatsapp',
              'otp_expiry_seconds': 300,
            },
          ),
        );
        final bloc = LoginBloc(initialCountryCode: 'IN', authRepository: repo);
        addTearDown(bloc.close);

        bloc.add(const LoginChannelChanged('whatsapp'));
        bloc.add(const SubmitLogin(identifier: '98765 43210'));
        await _settle();
        await _settle();
        expect(repo.sentTo.last, '+919876543210');
        expect(bloc.state.emailOrPhone, '+919876543210');

        bloc.add(
          const LoginCountryChanged(
            countryCode: 'US',
            dialCode: '+1',
            flag: '🇺🇸',
          ),
        );
        bloc.add(const SubmitLogin(identifier: '(415) 555-2671'));
        await _settle();
        await _settle();
        expect(repo.sentTo.last, '+14155552671');
        expect(bloc.state.emailOrPhone, '+14155552671');

        bloc.add(
          const LoginCountryChanged(
            countryCode: 'GB',
            dialCode: '+44',
            flag: '🇬🇧',
          ),
        );
        bloc.add(const SubmitLogin(identifier: '07400 123456'));
        await _settle();
        await _settle();
        expect(repo.sentTo.last, '+447400123456');
        expect(bloc.state.emailOrPhone, '+447400123456');
      },
    );
  });

  group('LoginBloc send-OTP outcomes', () {
    test('success marks the OTP as sent and carries the expiry', () async {
      final repo = _FakeAuthRepository(
        (_) async => const ApiResponse(
          success: true,
          data: {
            'is_registered': true,
            'is_leader': true,
            'channel': 'email',
            'otp_expiry_seconds': 120,
          },
        ),
      );
      final bloc = LoginBloc(authRepository: repo);
      addTearDown(bloc.close);

      bloc.add(const SubmitLogin(identifier: 'leader@example.com'));
      await _settle();
      await _settle();

      expect(repo.sentTo, ['leader@example.com']);
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.isOtpSent, isTrue);
      expect(bloc.state.otpExpirySeconds, 120);
      expect(bloc.state.isNotLeader, isFalse);
    });

    test(
      'NOT_A_LEADER shows the persistent notice instead of an error',
      () async {
        final repo = _FakeAuthRepository(
          (_) async =>
              const ApiResponse(success: false, errorCode: 'NOT_A_LEADER'),
        );
        final bloc = LoginBloc(authRepository: repo);
        addTearDown(bloc.close);

        bloc.add(const SubmitLogin(identifier: 'peer@example.com'));
        await _settle();
        await _settle();

        expect(bloc.state.isNotLeader, isTrue);
        expect(bloc.state.isAccountUnregistered, isFalse);
        expect(bloc.state.isOtpSent, isFalse);
        expect(bloc.state.errorMessage, isEmpty);
      },
    );

    test('USER_NOT_FOUND flags the account as unregistered', () async {
      final repo = _FakeAuthRepository(
        (_) async =>
            const ApiResponse(success: false, errorCode: 'USER_NOT_FOUND'),
      );
      final bloc = LoginBloc(authRepository: repo);
      addTearDown(bloc.close);

      bloc.add(const SubmitLogin(identifier: 'new@example.com'));
      await _settle();
      await _settle();

      expect(bloc.state.isNotLeader, isTrue);
      expect(bloc.state.isAccountUnregistered, isTrue);
    });

    test('a generic failure surfaces a message and stops loading', () async {
      final repo = _FakeAuthRepository(
        (_) async => const ApiResponse(success: false, message: 'Server busy'),
      );
      final bloc = LoginBloc(authRepository: repo);
      addTearDown(bloc.close);

      bloc.add(const SubmitLogin(identifier: 'leader@example.com'));
      await _settle();
      await _settle();

      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.isOtpSent, isFalse);
      expect(bloc.state.errorMessage, isNotEmpty);
    });

    test('a thrown exception surfaces a message and stops loading', () async {
      final repo = _FakeAuthRepository(
        (_) async => throw Exception('socket closed'),
      );
      final bloc = LoginBloc(authRepository: repo);
      addTearDown(bloc.close);

      bloc.add(const SubmitLogin(identifier: 'leader@example.com'));
      await _settle();
      await _settle();

      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.isOtpSent, isFalse);
      expect(bloc.state.errorMessage, isNotEmpty);
    });
  });
}
