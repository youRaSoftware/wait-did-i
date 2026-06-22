import 'package:flutter/material.dart';

/// Self-contained palette + text styles for the onboarding experience.
///
/// Onboarding is intentionally DARK-ONLY (regardless of the app theme) and uses
/// a few bespoke values that are not part of the app's semantic design tokens
/// (the warm polaroid paper, the scene's window gradient). The reference
/// `.claude/specs/onboarding/reference.html` is pixel-final, so these constants mirror it exactly.
/// This is a deliberate, documented exception to the "always use tokens" rule.
abstract final class OnboardingColors {
  // Backgrounds
  static const Color bgPrimary = Color(0xFF0F1419);
  static const Color bgSecondary = Color(0xFF1A202C);
  static const Color bgSurface = Color(0xFF1E2530);

  // Text
  static const Color textPrimary = Color(0xFFF7FAFC);
  static const Color textSecondary = Color(0xFFB4C0CE);
  static const Color textTertiary = Color(0xFF718096);

  // Brand
  static const Color brandBlue = Color(0xFF5A9BD4);
  static const Color brandBlueLight = Color(0xFF7BB0DD);
  static const Color brandBlueDeep = Color(0xFF4F86C6);

  // State
  static const Color stateSuccess = Color(0xFF68C58F);
  static const Color stateWarning = Color(0xFFE8B860);
  static const Color windowGlowTop = Color(0xFFFFE4A0);

  // Scene house
  static const Color houseTop = Color(0xFF2A3441);

  // Polaroid (warm sub-palette)
  static const Color polaroidPaper = Color(0xFFF7FAFC);
  static const Color polaroidText = Color(0xFF4A5568);
  static const Color photoMid = Color(0xFF2D3748);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[brandBlueLight, brandBlueDeep],
  );
}

/// Onboarding text styles (Manrope). Sizes/weights transcribed from the reference.
abstract final class OnboardingText {
  static const String _family = 'Manrope';

  static const TextStyle headline = TextStyle(
    fontFamily: _family,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.5,
    color: OnboardingColors.textPrimary,
  );

  static const TextStyle subline = TextStyle(
    fontFamily: _family,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.55,
    color: OnboardingColors.textSecondary,
  );

  static const TextStyle cta = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: OnboardingColors.bgPrimary,
  );

  static const TextStyle skip = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: OnboardingColors.textTertiary,
  );

  static const TextStyle polaroidCaption = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: OnboardingColors.polaroidText,
  );
}
