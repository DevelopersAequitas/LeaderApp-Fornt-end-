import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Smooth, gentle character-by-character text reveal where each letter slides up from its baseline.
class SplashAnimatedTitle extends StatefulWidget {
  final VoidCallback? onCompleted;

  const SplashAnimatedTitle({super.key, this.onCompleted});

  @override
  State<SplashAnimatedTitle> createState() => _SplashAnimatedTitleState();
}

class _SplashAnimatedTitleState extends State<SplashAnimatedTitle>
    with SingleTickerProviderStateMixin {
  static const String _fullText = 'PEERS GLOBAL';

  late final AnimationController _controller;
  late final List<Animation<Offset>> _charSlideAnimations;
  late final List<Animation<double>> _charFadeAnimations;

  @override
  void initState() {
    super.initState();

    // Slower, highly fluid duration for smooth character cascade (2200ms)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    final totalChars = _fullText.length;
    _charSlideAnimations = [];
    _charFadeAnimations = [];

    for (int i = 0; i < totalChars; i++) {
      // Staggered interval with extended easing window for each letter
      final start = (i * 0.042).clamp(0.0, 0.55);
      final end = (start + 0.45).clamp(0.0, 1.0);

      _charSlideAnimations.add(
        Tween<Offset>(
          begin: const Offset(0.0, 1.15),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        ),
      );

      _charFadeAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              start,
              (start + 0.32).clamp(0.0, 1.0),
              curve: Curves.easeOut,
            ),
          ),
        ),
      );
    }

    _controller.forward().then((_) {
      widget.onCompleted?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(_fullText.length, (index) {
        final char = _fullText[index];

        if (char == ' ') {
          return const SizedBox(width: 10);
        }

        return ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FractionalTranslation(
                translation: _charSlideAnimations[index].value,
                child: Opacity(
                  opacity: _charFadeAnimations[index].value,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5, vertical: 2.0),
              child: Text(
                char,
                style: const TextStyle(
                  color: AppColors.text, // Deep Navy / Dark (#102640)
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
