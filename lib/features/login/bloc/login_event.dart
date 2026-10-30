/// Base class for all sign-in form events.
abstract class LoginEvent {
  const LoginEvent();
}

/// Event triggered when the user types in the email or phone input field.
class EmailOrPhoneChanged extends LoginEvent {
  final String value;
  const EmailOrPhoneChanged(this.value);
}

/// Event triggered when the user switches the OTP delivery channel ('email' or 'whatsapp').
class LoginChannelChanged extends LoginEvent {
  final String channel;
  const LoginChannelChanged(this.channel);
}

/// Event triggered when the user selects a country dial code and flag.
class LoginCountryChanged extends LoginEvent {
  final String dialCode;
  final String flag;
  const LoginCountryChanged({required this.dialCode, required this.flag});
}

/// Event triggered when the user submits the sign-in form.
class SubmitLogin extends LoginEvent {
  final String? identifier;
  const SubmitLogin({this.identifier});
}

/// Event triggered when the user dismisses the persistent non-leader card.
class DismissNotLeaderNotice extends LoginEvent {
  const DismissNotLeaderNotice();
}
