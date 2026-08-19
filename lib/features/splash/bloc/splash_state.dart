import '../model/splash_model.dart';

/// Base class for all states emitted by the SplashBloc.
abstract class SplashState {
  const SplashState();
}

/// Initial state of the Splash Screen.
class SplashInitial extends SplashState {
  const SplashInitial();
}

/// State indicating that the Splash Screen processes are loading (e.g. animations/timer/initialization).
class SplashLoading extends SplashState {
  const SplashLoading();
}

/// State indicating that the Splash Screen initialization was completed successfully.
class SplashLoadSuccess extends SplashState {
  /// The initialized data model containing version and branding info.
  final SplashModel model;

  const SplashLoadSuccess(this.model);
}

/// State indicating that the Splash Screen initialization encountered an error.
class SplashLoadFailure extends SplashState {
  /// Explanation of what went wrong.
  final String errorMessage;

  const SplashLoadFailure(this.errorMessage);
}
