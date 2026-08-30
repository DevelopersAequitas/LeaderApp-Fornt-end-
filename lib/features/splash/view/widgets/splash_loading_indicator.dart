import 'package:flutter/material.dart';

/// Linear modern progress indicator with status message for splash sequence.
class SplashLoadingIndicator extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const SplashLoadingIndicator({
    super.key,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sleek Progress Track
          Container(
            width: 140,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: const LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Initializing Workspace...',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
