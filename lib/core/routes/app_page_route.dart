// ==============================================================================
// File: lib/core/routes/app_page_route.dart
// Description: Crisp Native Executive Route & Page Transitions Subsystem
// Framework: Flutter | Architecture: Core Navigation Subsystem
// ==============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_motion.dart';

/// Semantic transition styles so root swaps and drill-down pushes use
/// appropriate motion instead of applying one uniform effect everywhere.
enum AppRouteTransitionStyle {
  /// Standard drill-down screen push:
  /// - iOS/macOS: native [CupertinoPageTransitionsBuilder] (1:1 edge swipe-back).
  /// - Android/other: crisp 220ms/180ms executive horizontal glide with subtle
  ///   parallax and no full-screen alpha flicker, plus predictive-back support.
  platformPush,

  /// Clean in-place crossfade for root transitions (Splash -> Home / Login,
  /// Maintenance gate) where a sideways push would feel spatially wrong.
  rootFade,
}

/// Executive page transition builder for [ThemeData.pageTransitionsTheme].
///
/// Replaces the previous flickery 0.08-slide + full-alpha fade with a solid,
/// directional glide (220ms in / 180ms out) that:
/// - keeps the outgoing screen opaque (no dark/blank background seam),
/// - applies a subtle depth scrim behind the incoming page,
/// - defers to Flutter's [PredictiveBackPageTransitionsBuilder] during an
///   active Android predictive-back gesture, and
/// - snaps instantly when system reduced motion is enabled.
class SmoothPageTransitionsBuilder extends PageTransitionsBuilder {
  const SmoothPageTransitionsBuilder();

  static const PredictiveBackPageTransitionsBuilder _predictiveBack =
      PredictiveBackPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (AppMotion.reduceMotion(context)) {
      return child;
    }

    // Preserve native Android 14+ predictive back gestures while dragging.
    if (route.popGestureInProgress) {
      return _predictiveBack.buildTransitions(
        route,
        context,
        animation,
        secondaryAnimation,
        child,
      );
    }

    return _ExecutiveSlideTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

/// Primary route used across [AppRoutes.onGenerateRoute].
///
/// Extends [MaterialPageRoute] rather than [PageRouteBuilder] so native
/// interactive pop gestures (iOS edge swipe-back, Android predictive back) and
/// semantic route traits continue working seamlessly.
class AppPageRoute<T> extends MaterialPageRoute<T> {
  final AppRouteTransitionStyle transitionStyle;

  AppPageRoute({
    required super.builder,
    super.settings,
    super.maintainState = true,
    super.fullscreenDialog = false,
    this.transitionStyle = AppRouteTransitionStyle.platformPush,
  });

  @override
  Duration get transitionDuration =>
      transitionStyle == AppRouteTransitionStyle.rootFade
      ? AppMotion.rootFade
      : AppMotion.pageForward;

  @override
  Duration get reverseTransitionDuration =>
      transitionStyle == AppRouteTransitionStyle.rootFade
      ? AppMotion.rootFade
      : AppMotion.pageReverse;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (AppMotion.reduceMotion(context)) {
      return child;
    }

    if (transitionStyle == AppRouteTransitionStyle.rootFade) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.easeOut,
        reverseCurve: AppMotion.easeIn,
      );
      return FadeTransition(opacity: curved, child: child);
    }

    // On Apple platforms, delegate to native Cupertino transition for true 1:1
    // interactive edge-swipe back with parallax.
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return const CupertinoPageTransitionsBuilder().buildTransitions<T>(
        this,
        context,
        animation,
        secondaryAnimation,
        child,
      );
    }

    return const SmoothPageTransitionsBuilder().buildTransitions<T>(
      this,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}

class _ExecutiveSlideTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const _ExecutiveSlideTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final primary = CurvedAnimation(
      parent: animation,
      curve: AppMotion.easeOut,
      reverseCurve: AppMotion.easeIn,
    );

    final secondary = CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppMotion.easeOut,
      reverseCurve: AppMotion.easeIn,
    );

    // Incoming screen glides cleanly from right with a fast opacity settle
    // (0.85 -> 1.0 over the first 45%) so it never ghosts or flickers.
    final slideIn = Tween<Offset>(
      begin: const Offset(0.14, 0.0),
      end: Offset.zero,
    ).animate(primary);

    final fadeIn = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
        reverseCurve: const Interval(0.55, 1.0, curve: Curves.easeIn),
      ),
    );

    // Outgoing screen stays 100% opaque (zero dark background seam!) while
    // shifting subtly left and gaining a gentle 6% depth scrim.
    final slideOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.05, 0.0),
    ).animate(secondary);

    return SlideTransition(
      position: slideOut,
      child: SlideTransition(
        position: slideIn,
        child: FadeTransition(
          opacity: fadeIn,
          child: AnimatedBuilder(
            animation: secondary,
            builder: (context, inner) {
              final scrimAlpha = 0.06 * secondary.value;
              if (scrimAlpha <= 0.001) return inner!;
              return ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: scrimAlpha),
                  BlendMode.srcATop,
                ),
                child: inner,
              );
            },
            child: child,
          ),
        ),
      ),
    );
  }
}
