import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';

/// Contract interface defining UI actions to be implemented by the View.
abstract class SplashViewContract {
  /// Invoked when initialization starts.
  void onSplashLoading();

  /// Invoked when initialization completes successfully.
  void onSplashLoaded(String appVersion, String brandingText);

  /// Invoked when an initialization error occurs.
  void onSplashError(String message);

  /// Requests the view to navigate to the home screen.
  void navigateToHome();
}

/// Presenter class coordinating between the Splash BLoC and the Splash View.
class SplashPresenter {  
  /// The view contract interface.
  final SplashViewContract view;

  /// The BLoC managing the state.
  final SplashBloc bloc;

  SplashPresenter({required this.view, required this.bloc});

  /// Starts the splash screen initialization tasks.
  void initialize() {
    bloc.add(const InitializeSplash());
  }

  /// Handles BLoC state changes, translating them into View actions.
  void handleStateChange(SplashState state) {
    if (state is SplashLoading) {
      view.onSplashLoading();
    } else if (state is SplashLoadSuccess) {
      view.onSplashLoaded(state.model.appVersion, state.model.brandingText);
      view.navigateToHome();
    } else if (state is SplashLoadFailure) {
      view.onSplashError(state.errorMessage);
    }
  }
}
