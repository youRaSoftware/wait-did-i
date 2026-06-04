import 'package:shared_preferences/shared_preferences.dart';

/// Persists whether the user has finished the first-launch onboarding.
///
/// Backed by [SharedPreferences] so the flag survives restarts. The router
/// reads [isCompleted] to decide between `/onboarding` and `/home`.
class OnboardingService {
  static const String _completedKey = 'onboarding_completed';

  final SharedPreferences _prefs;

  OnboardingService(this._prefs);

  /// True once the user has gone through (or skipped) onboarding.
  bool get isCompleted => _prefs.getBool(_completedKey) ?? false;

  /// Marks onboarding as done. Called on "Начать" / "Пропустить".
  Future<void> complete() => _prefs.setBool(_completedKey, true);

  /// Resets the flag — handy for QA / a "show onboarding again" debug action.
  Future<void> reset() => _prefs.remove(_completedKey);
}
