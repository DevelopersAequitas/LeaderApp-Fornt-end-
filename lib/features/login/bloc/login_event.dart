/// Base class for all sign-in form events.
abstract class LoginEvent {
  const LoginEvent();
}

/// Event triggered when the user types in the email or phone input field.
class EmailOrPhoneChanged extends LoginEvent {
  final String value;
  const EmailOrPhoneChanged(this.value);
}

/// Event triggered when the user submits the sign-in form.
class SubmitLogin extends LoginEvent {
  const SubmitLogin();
}
