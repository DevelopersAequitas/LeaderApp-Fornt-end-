import 'package:flutter/material.dart';

/// Clean, crisp white background with subtle ambient depth.
class SplashBackgroundAmbience extends StatelessWidget {
  const SplashBackgroundAmbience({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0xFFF8FAFC),
          ],
        ),
      ),
    );
  }
}
