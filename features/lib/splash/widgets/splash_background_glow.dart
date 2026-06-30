import 'dart:ui';

import 'package:flutter/material.dart';

import 'splash_colors.dart';

/// A soft brand glow centered behind the wordmark, giving the dark splash depth.
class SplashBackgroundGlow extends StatelessWidget {
  const SplashBackgroundGlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    SplashColors.brandBlue.withValues(alpha: 0.30),
                    SplashColors.brandBlue.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const <double>[0.0, 0.45, 0.8],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
