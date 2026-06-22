import 'dart:ui';

import 'package:flutter/material.dart';

import 'onboarding_colors.dart';

/// Two large blurred radial glows that give the dark onboarding depth.
/// Shared across all slides — drop once into the screen's [Stack].
class OnboardingBackgroundGlow extends StatelessWidget {
  const OnboardingBackgroundGlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            // Bottom-center — the app's primary "light".
            Positioned(
              bottom: -180,
              left: -80,
              right: -80,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(
                  height: 500,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 0.7,
                      colors: <Color>[
                        OnboardingColors.brandBlue.withValues(alpha: 0.35),
                        OnboardingColors.brandBlue.withValues(alpha: 0.10),
                        Colors.transparent,
                      ],
                      stops: const <double>[0.0, 0.35, 0.7],
                    ),
                  ),
                ),
              ),
            ),
            // Top-right — cool highlight.
            Positioned(
              top: -100,
              right: -100,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        OnboardingColors.brandBlueLight.withValues(alpha: 0.20),
                        Colors.transparent,
                      ],
                      stops: const <double>[0.0, 0.6],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
