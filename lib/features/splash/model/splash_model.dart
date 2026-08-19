/// Data model representing the state/metadata of the Splash Screen.
class SplashModel {
  /// The current app version.
  final String appVersion;

  /// The branding/tagline text shown on splash.
  final String brandingText;

  /// Minimum duration for the splash animation in milliseconds.
  final int minDurationMs;

  const SplashModel({
    required this.appVersion,
    required this.brandingText,
    this.minDurationMs = 2000,
  });
}
