import 'dart:ui';

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

/// Two soft brand glows behind the home content. Lower opacity than onboarding —
/// the user spends a lot of time here, so the atmosphere stays calm. Theme-aware.
class HomeBackgroundGlow extends StatelessWidget {
  const HomeBackgroundGlow({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              top: -120,
              right: -120,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[color.colorBrandPeach.withValues(alpha: 0.20), Colors.transparent],
                      stops: const <double>[0.0, 0.6],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -200,
              left: -100,
              right: -100,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(
                  height: 500,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 0.7,
                      colors: <Color>[color.colorBrandCoral.withValues(alpha: 0.15), Colors.transparent],
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
