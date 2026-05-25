// ignore_for_file: unintended_html_in_doc_comment

import 'package:flutter/material.dart';

import 'locale_keys.g.dart';

export 'locale_keys.g.dart';

/// In case if you need more locales just create another
/// enum value and add created locale to [supportedLocales]
/// also you may need to get locale from local store that was
/// previously set so here is an example how you can update [fallbackLocale] :
/// appLocator<AppSettingsService>().getLanguage() ?? AppLocalizationEnum.ru
enum AppLocalizationEnum {
  ru(
    locale: Locale('ru', 'RU'),
    localeKey: LocaleKeys.common_russian,
    languageDisplayName: 'Русский',
  ),
  en(
    locale: Locale('en', 'US'),
    localeKey: LocaleKeys.common_english,
    languageDisplayName: 'English',
  );

  final Locale locale;
  final String localeKey;
  final String languageDisplayName;

  const AppLocalizationEnum({
    required this.locale,
    required this.localeKey,
    required this.languageDisplayName,
  });

  static const String langFolderPath = 'packages/core/resources/translations';

  static Locale get fallbackLocale => ru.locale;

  static String get fallbackLocaleName => '${fallbackLocale.languageCode}-${fallbackLocale.countryCode}';

  static List<Locale> get supportedLocales => <Locale>[
    ru.locale,
    en.locale,
  ];
}
