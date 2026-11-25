import 'dart:async';

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Wraps any list card, table row, or queue entry to highlight it **exactly three
/// times** when [activeTargetId] matches [itemId], then clears styling and
/// invokes [onHighlightCompleted]. Respects reduced-motion accessibility settings.
class NotificationHighlightWrapper extends StatefulWidget {
  final String itemId;
  final String? activeTargetId;
  final VoidCallback? onHighlightCompleted;
  final Widget child;
  final BorderRadius borderRadius;
  final Color highlightColor;

  /// Exposed for deterministic widget tests to assert exact 3-pulse execution.
  final ValueChanged<int>? onPulseCountChanged;

  const NotificationHighlightWrapper({
    super.key,
    required this.itemId,
    required this.activeTargetId,
    required this.child,
    this.onHighlightCompleted,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.highlightColor = AppColors.primaryBlue,
    this.onPulseCountChanged,
  });

  @override
  State<NotificationHighlightWrapper> createState() =>
      _NotificationHighlightWrapperState();
}

class _NotificationHighlightWrapperState
    extends State<NotificationHighlightWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;
  Timer? _reducedMotionTimer;
  bool _hasAnimatedForCurrentTarget = false;
  bool _reducedMotionActive = false;
  int _completedPulses = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _pulseAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeTrigger();
    });
  }

  @override
  void didUpdateWidget(covariant NotificationHighlightWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeTargetId != oldWidget.activeTargetId) {
      if (widget.activeTargetId != widget.itemId) {
        _hasAnimatedForCurrentTarget = false;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maybeTrigger();
      });
    }
  }

  bool get _isTarget =>
      widget.activeTargetId != null &&
      widget.activeTargetId!.isNotEmpty &&
      widget.activeTargetId == widget.itemId;

  Future<void> _maybeTrigger() async {
    if (!mounted || !_isTarget || _hasAnimatedForCurrentTarget) return;
    _hasAnimatedForCurrentTarget = true;

    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    if (disableAnimations) {
      setState(() => _reducedMotionActive = true);
      _completedPulses = 1;
      widget.onPulseCountChanged?.call(1);
      _reducedMotionTimer?.cancel();
      _reducedMotionTimer = Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() => _reducedMotionActive = false);
        widget.onHighlightCompleted?.call();
      });
      return;
    }

    _completedPulses = 0;
    for (var i = 0; i < 3; i++) {
      if (!mounted) return;
      await _controller.forward();
      if (!mounted) return;
      await _controller.reverse();
      _completedPulses = i + 1;
      widget.onPulseCountChanged?.call(_completedPulses);
    }

    if (!mounted) return;
    _controller.reset();
    widget.onHighlightCompleted?.call();
  }

  @override
  void dispose() {
    _reducedMotionTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_reducedMotionActive) {
      return DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          border: Border.all(color: widget.highlightColor, width: 2.0),
          color: widget.highlightColor.withValues(alpha: 0.08),
        ),
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final v = _pulseAnimation.value;
        if (v <= 0.001) {
          return child!;
        }
        return DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            border: Border.all(
              color: widget.highlightColor.withValues(alpha: 0.9 * v),
              width: 2.0,
            ),
            color: widget.highlightColor.withValues(alpha: 0.12 * v),
            boxShadow: [
              BoxShadow(
                color: widget.highlightColor.withValues(alpha: 0.22 * v),
                blurRadius: 12 * v,
                spreadRadius: 1 * v,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
