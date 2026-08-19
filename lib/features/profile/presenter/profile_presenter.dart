import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

/// Contract interface defining profile view actions.
abstract class ProfileViewContract {
  /// Invoked when loading/signout begins.
  void onProfileLoading();

  /// Invoked when profile details are successfully loaded.
  void onProfileLoaded();

  /// Invoked when loading/signout fails.
  void onProfileError(String error);

  /// Invoked when user successfully signs out.
  void onSignedOut();
}

/// Presenter coordinating presentation logic for Profile screen.
class ProfilePresenter {
  /// View contract reference.
  final ProfileViewContract view;

  /// BLoC reference.
  final ProfileBloc bloc;

  ProfilePresenter({required this.view, required this.bloc});

  /// Relays data fetch trigger.
  void load() {
    bloc.add(const LoadProfileData());
  }

  /// Relays sign out trigger.
  void signOut() {
    bloc.add(const TriggerSignOut());
  }

  /// Maps BLoC state changes back to view contract triggers.
  void handleStateChange(ProfileState state) {
    if (state.isLoading) {
      view.onProfileLoading();
    } else if (state.userProfile != null) {
      view.onProfileLoaded();
    }

    if (state.isSignedOut) {
      view.onSignedOut();
    }

    if (state.errorMessage.isNotEmpty) {
      view.onProfileError(state.errorMessage);
    }
  }
}
