// ==============================================================================
// File: lib/core/routes/app_page_route.dart
// Description: Senior-Spec Smooth Route & Page Transitions Builder
// Framework: Flutter | Architecture: Core Navigation Subsystem
// Design Specifications:
//   - Compliant with design_standards.md Section 6 (Motion):
//     * Transition duration: 240ms (under 300ms hard cap)
//     * Reverse duration: 200ms
//     * Curve: Curves.fastOutSlowIn / Curves.easeInOut
//     * Subtle horizontal slide + alpha fade for fluid, responsive navigation
// ==============================================================================

import 'package:flutter/material.dart';

/// Senior-spec smooth page route transition builder for Leader App.
/// Usable across ThemeData pageTransitionsTheme for automatic global adoption.
class SmoothPageTransitionsBuilder extends PageTransitionsBuilder {
  const SmoothPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _AppTransitionWidget(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

/// Custom PageRoute that enforces smooth 240ms transition duration and curves.
class AppPageRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;

  AppPageRoute({
    required this.builder,
    super.settings,
    super.maintainState = true,
    super.fullscreenDialog = false,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) =>
             builder(context),
         transitionDuration: const Duration(milliseconds: 240),
         reverseTransitionDuration: const Duration(milliseconds: 200),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return _AppTransitionWidget(
             animation: animation,
             secondaryAnimation: secondaryAnimation,
             child: child,
           );
         },
       );
}

class _AppTransitionWidget extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const _AppTransitionWidget({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Primary forward entrance: subtle slide + fade
    final primaryCurved = CurvedAnimation(
      parent: animation,
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeInOut,
    );

    final slideIn = Tween<Offset>(
      begin: const Offset(0.08, 0.0),
      end: Offset.zero,
    ).animate(primaryCurved);

    final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(primaryCurved);

    // Secondary exit (when another screen pushes over this one): subtle push-back
    final secondaryCurved = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeInOut,
    );

    final slideOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.03, 0.0),
    ).animate(secondaryCurved);

    final fadeOut = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(secondaryCurved);

    return SlideTransition(
      position: slideOut,
      child: FadeTransition(
        opacity: fadeOut,
        child: SlideTransition(
          position: slideIn,
          child: FadeTransition(opacity: fadeIn, child: child),
        ),
      ),
    );
  }
}
