import 'package:flutter/services.dart';

/// Service for haptic feedback across the app.
/// Provides consistent tactile feedback for user interactions.
abstract final class HapticService {
  /// Light impact - for list items, tiles, tabs.
  static Future<void> lightImpact() => HapticFeedback.lightImpact();

  /// Medium impact - for buttons, primary actions.
  static Future<void> mediumImpact() => HapticFeedback.mediumImpact();

  /// Heavy impact - for destructive or important actions.
  static Future<void> heavyImpact() => HapticFeedback.heavyImpact();

  /// Selection click - for toggles, chips, selections.
  static Future<void> selectionClick() => HapticFeedback.selectionClick();
}
