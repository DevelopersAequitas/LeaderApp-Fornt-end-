import 'package:flutter/material.dart';

/// Bottom footer displaying app version and system badge on white theme.
class SplashFooterVersion extends StatelessWidget {
  final String appVersion;
  final Animation<double> fadeAnimation;

  const SplashFooterVersion({
    super.key,
    required this.appVersion,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
            ),
            child: Text(
              appVersion.isNotEmpty ? 'v$appVersion' : '',
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
