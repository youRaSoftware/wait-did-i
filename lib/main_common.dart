import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'app.dart';

Future<void> mainCommon(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  // final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  await setupUnAuthScope(flavor);

  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await EasyLocalization.ensureInitialized();
  runApp(const _MainAppWidget());
}

class _MainAppWidget extends StatelessWidget {
  const _MainAppWidget();

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: AppLocalizationEnum.supportedLocales,
      fallbackLocale: AppLocalizationEnum.fallbackLocale,
      path: AppLocalizationEnum.langFolderPath,
      child: App(),
    );
  }
}
