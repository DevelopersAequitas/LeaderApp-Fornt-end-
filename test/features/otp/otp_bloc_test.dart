import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/core/network/api_exception.dart';
import 'package:leaderapp/core/network/api_response.dart';
import 'package:leaderapp/data/datasources/remote/auth_remote_datasource.dart';
import 'package:leaderapp/data/repositories/auth_repository.dart';
import 'package:leaderapp/features/otp/bloc/otp_bloc.dart';
import 'package:leaderapp/features/otp/bloc/otp_event.dart';

/// Fake repository: the OTP screen uses `verifyOtp` and `sendOtp` (resend).
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    this.onVerify,
    this.onSend,
  });

  Future<ApiResponse<AuthVerifyResult>> Function(String id, String otp)? onVerify;
  Future<ApiResponse<Map<String, dynamic>>> Function(String id)? onSend;
  final List<String> verified = [];
  int sends = 0;

  @override
  Future<ApiResponse<AuthVerifyResult>> verifyOtp(String emailOrPhone, String otp) {
    verified.add(otp);
    return onVerify!(emailOrPhone, otp);
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> sendOtp(String emailOrPhone) {
    sends++;
    return onSend!(emailOrPhone);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not used by OTP');
}

Future<void> _settle() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

OtpBloc _bloc(_FakeAuthRepository repo) {
  final bloc = OtpBloc(emailOrPhone: 'leader@example.com', authRepository: repo);
  addTearDown(bloc.close); // also cancels the 30 s countdown timer
  return bloc;
}

void main() {
  group('OTP input and validation', () {
    test('starts locked with a 30 s resend countdown', () {
      final bloc = _bloc(_FakeAuthRepository());
      expect(bloc.state.canResend, isFalse);
      expect(bloc.state.resendCountdown, 30);
      expect(bloc.state.isFormValid, isFalse);
    });

    test('only a full 6-digit code is valid', () async {
      final bloc = _bloc(_FakeAuthRepository());
      bloc.add(const OtpInputChanged('12345'));
      await _settle();
      expect(bloc.state.isFormValid, isFalse);
      bloc.add(const OtpInputChanged('123456'));
      await _settle();
      expect(bloc.state.isFormValid, isTrue);
      expect(bloc.state.otpCode, '123456');
    });

    test('submitting an incomplete code shows a message and never calls the API',
        () async {
      final repo = _FakeAuthRepository();
      final bloc = _bloc(repo);
      bloc.add(const OtpInputChanged('123'));
      bloc.add(const SubmitOtpVerification());
      await _settle();
      expect(bloc.state.errorMessage, 'Please enter the 6-digit verification code.');
      expect(repo.verified, isEmpty);
      expect(bloc.state.isSuccess, isFalse);
    });
  });

  group('OTP verification outcomes', () {
    Future<OtpBloc> submit(_FakeAuthRepository repo) async {
      final bloc = _bloc(repo);
      bloc.add(const OtpInputChanged('654321'));
      bloc.add(const SubmitOtpVerification());
      await _settle();
      await _settle();
      return bloc;
    }

    test('success flags isSuccess and sends the typed code', () async {
      final repo = _FakeAuthRepository(
        onVerify: (_, _) async => const ApiResponse<AuthVerifyResult>(success: true),
      );
      final bloc = await submit(repo);
      expect(repo.verified, ['654321']);
      expect(bloc.state.isSuccess, isTrue);
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.errorMessage, isEmpty);
    });

    test('a wrong code surfaces the server message and stays on the screen',
        () async {
      final repo = _FakeAuthRepository(
        onVerify: (_, _) async => const ApiResponse<AuthVerifyResult>(
          success: false,
          message: 'Invalid OTP',
        ),
      );
      final bloc = await submit(repo);
      expect(bloc.state.isSuccess, isFalse);
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.errorMessage, isNotEmpty);
    });

    test('a non-leader account gets the dedicated notice, not an error', () async {
      final repo = _FakeAuthRepository(
        onVerify: (_, _) async => const ApiResponse<AuthVerifyResult>(
          success: false,
          message: 'You do not hold an assigned leadership role.',
        ),
      );
      final bloc = await submit(repo);
      expect(bloc.state.isNotLeader, isTrue);
      expect(bloc.state.errorMessage, isEmpty);
      expect(bloc.state.isSuccess, isFalse);
    });

    test('NOT_A_LEADER and HTTP 403 exceptions both map to the notice', () async {
      for (final ex in [
        const ApiException(message: 'x', errorCode: 'NOT_A_LEADER'),
        const ApiException(message: 'Forbidden', statusCode: 403),
      ]) {
        final repo = _FakeAuthRepository(onVerify: (_, _) async => throw ex);
        final bloc = await submit(repo);
        expect(bloc.state.isNotLeader, isTrue, reason: '$ex');
      }
      // NOTE (audit finding): *every* 403 is treated as "not a leader", even a
      // 403 for another reason such as a blocked or rate-limited account.
    });

    test('a thrown network error shows a message and stops loading', () async {
      final repo = _FakeAuthRepository(
        onVerify: (_, _) async => throw Exception('socket closed'),
      );
      final bloc = await submit(repo);
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.isNotLeader, isFalse);
      expect(bloc.state.errorMessage, isNotEmpty);
    });
  });

  group('OTP resend', () {
    test('resend is ignored while the countdown is running', () async {
      final repo = _FakeAuthRepository(
        onSend: (_) async => const ApiResponse<Map<String, dynamic>>(success: true),
      );
      final bloc = _bloc(repo);
      bloc.add(const ResendOtpRequested());
      await _settle();
      expect(repo.sends, 0);
    });

    test('after the countdown a resend succeeds and the delay grows', () async {
      final repo = _FakeAuthRepository(
        onSend: (_) async => const ApiResponse<Map<String, dynamic>>(success: true),
      );
      final bloc = _bloc(repo);

      bloc.add(const TimerTicked(0)); // countdown reached zero
      await _settle();
      expect(bloc.state.canResend, isTrue);

      bloc.add(const ResendOtpRequested());
      await _settle();
      await _settle();
      expect(repo.sends, 1);
      expect(bloc.state.resendAttempt, 1);
      expect(bloc.state.resendCountdown, 30);
      expect(bloc.state.canResend, isFalse);
      expect(bloc.state.resendSuccessMessage, 'New verification code sent!');

      bloc.add(const TimerTicked(0));
      await _settle();
      bloc.add(const ResendOtpRequested());
      await _settle();
      await _settle();
      expect(bloc.state.resendAttempt, 2);
      expect(bloc.state.resendCountdown, 60); // progressive back-off
    });

    test('a failed resend re-enables the button and reports the error', () async {
      final repo = _FakeAuthRepository(
        onSend: (_) async => throw Exception('offline'),
      );
      final bloc = _bloc(repo);
      bloc.add(const TimerTicked(0));
      await _settle();
      bloc.add(const ResendOtpRequested());
      await _settle();
      await _settle();
      expect(bloc.state.canResend, isTrue);
      expect(bloc.state.errorMessage, isNotEmpty);
      expect(bloc.state.resendAttempt, 0);
    });
  });
}
