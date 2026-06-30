import 'package:flutter/material.dart';

/// Self-contained palette for the launch splash.
///
/// Like the onboarding, the splash is intentionally DARK-ONLY (regardless of the
/// app theme) so the wordmark animation always reads the same on first launch.
/// These mirror the onboarding's brand values — a deliberate, documented
/// exception to the "always use tokens" rule.
abstract final class SplashColors {
  static const Color bg = Color(0xFF0F1419);

  static const Color textPrimary = Color(0xFFF7FAFC);
  static const Color brandBlue = Color(0xFF5A9BD4);
  static const Color brandBlueLight = Color(0xFF7BB0DD);
}
