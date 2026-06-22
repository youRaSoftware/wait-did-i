import 'package:shared_preferences/shared_preferences.dart';

import '../enums/theme_mode_enum.dart';

/// Persists the user's theme choice (System / Light / Dark). Defaults to Dark
/// (the product's primary theme) until the user changes it.
class ThemeService {
  static const String _key = 'theme_mode';

  final SharedPreferences _prefs;

  ThemeService(this._prefs);

  ThemeModeEnum get mode {
    final int? id = _prefs.getInt(_key);
    return id == null ? ThemeModeEnum.dark : ThemeModeEnum.fromIdt(id);
  }

  Future<void> setMode(ThemeModeEnum mode) => _prefs.setInt(_key, mode.id);
}
