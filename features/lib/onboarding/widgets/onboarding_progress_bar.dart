import 'package:flutter/material.dart';

import 'onboarding_colors.dart';
import 'onboarding_motion.dart';

/// Thin top progress bar. [progress] is 0.0..1.0.
class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(2),
      ),
      child: AnimatedFractionallySizedBox(
        duration: const Duration(milliseconds: 600),
        curve: OnboardingMotion.fadeCurve,
        widthFactor: progress.clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[OnboardingColors.brandBlueLight, OnboardingColors.brandBlue],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
