import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import '../model/role_model.dart';

/// Contract interface defining UI actions to be implemented by the Login View.
abstract class LoginViewContract {
  /// Invoked when the sign-in submission starts.
  void onLoginLoading();

  /// Invoked when sign-in completes and OTP has been successfully sent.
  void onLoginSuccess();

  /// Invoked when sign-in submission fails.
  void onLoginError(String error);

  /// Invoked when form validation state changes.
  void onValidationChanged(bool isValid);

  /// Invoked when a role auto-fill request is made.
  void onAutoFillRequest(String credentials);
}

/// Presenter coordinating visual actions and inputs for the Sign-in process.
class LoginPresenter {
  /// View contract reference.
  final LoginViewContract view;

  /// BLoC reference.
  final LoginBloc bloc;

  LoginPresenter({required this.view, required this.bloc});

  /// Relays input modifications back to BLoC.
  void onEmailOrPhoneChanged(String value) {
    bloc.add(EmailOrPhoneChanged(value));
  }

  /// Handles role selection auto-fill events.
  void onRoleSelected(RoleModel role) {
    bloc.add(RoleSelected(role));
    view.onAutoFillRequest(role.email);
  }

  /// Requests form submission.
  void submit() {
    bloc.add(const SubmitLogin());
  }

  /// Maps BLoC state changes back to view contract triggers.
  void handleStateChange(LoginState state) {
    view.onValidationChanged(state.isFormValid);

    if (state.isLoading) {
      view.onLoginLoading();
    }

    if (state.isOtpSent) {
      view.onLoginSuccess();
    }

    if (state.errorMessage.isNotEmpty) {
      view.onLoginError(state.errorMessage);
    }
  }
}
