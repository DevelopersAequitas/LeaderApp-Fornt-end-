/// Base class for all events related to the Splash Screen.
abstract class SplashEvent {
  const SplashEvent();
}

/// Event indicating that the Splash Screen initialization process has started.
class InitializeSplash extends SplashEvent {
  const InitializeSplash();
}
