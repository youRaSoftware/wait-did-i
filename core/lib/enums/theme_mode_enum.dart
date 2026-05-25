import '../core.dart';

enum ThemeModeEnum {
  system(id: 0, localeKey: LocaleKeys.common_system),
  light(id: 1, localeKey: LocaleKeys.common_light),
  dark(id: 2, localeKey: LocaleKeys.common_dark);

  final int id;
  final String localeKey;

  const ThemeModeEnum({
    required this.id,
    required this.localeKey,
  });

  static ThemeModeEnum fromIdt(int value) {
    return ThemeModeEnum.values.firstWhere(
      (ThemeModeEnum language) => language.id == value,
      orElse: () => ThemeModeEnum.system,
    );
  }

  static int toId(ThemeModeEnum value) => value.id;
}
