import 'package:flutter/material.dart';

/// Centralized motion tokens for crisp, native executive navigation and UI
/// feedback across the Leader App.
///
/// Every transition respects [MediaQuery.disableAnimationsOf] so users with
/// system reduced-motion enabled get instant, zero-motion state changes.
abstract final class AppMotion {
  /// Forward drill-down page push duration (crisp executive glide).
  static const Duration pageForward = Duration(milliseconds: 220);

  /// Reverse pop duration (slightly snappier exit than entrance).
  static const Duration pageReverse = Duration(milliseconds: 180);

  /// Root-level route swap (e.g. Splash -> Home/Login).
  static const Duration rootFade = Duration(milliseconds: 180);

  /// Bottom-nav tab switch crossfade (in-place, zero carousel flash).
  static const Duration tabSwitch = Duration(milliseconds: 150);

  /// Active pill / segmented control indicator transition.
  static const Duration indicator = Duration(milliseconds: 180);

  /// Tactile press-down micro-interaction.
  static const Duration press = Duration(milliseconds: 110);

  /// Bottom sheet entrance & exit durations.
  static const Duration sheetOpen = Duration(milliseconds: 220);
  static const Duration sheetClose = Duration(milliseconds: 180);

  /// Standard executive deceleration curve (fast initial response, calm settle).
  static const Curve easeOut = Curves.easeOutCubic;

  /// Snappy exit curve.
  static const Curve easeIn = Curves.easeInCubic;

  /// Returns `true` when the user has enabled system reduced motion.
  static bool reduceMotion(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// Returns [Duration.zero] when reduced motion is enabled, else [normal].
  static Duration duration(BuildContext context, Duration normal) =>
      reduceMotion(context) ? Duration.zero : normal;
}
