import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../cubit/settings_cubit.dart';

class SettingsForm extends StatelessWidget {
  const SettingsForm({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;
    final TextStyleTokens textStyle = context.currentTokens.textStyle;
    final ThemeModeEnum currentMode = context.themeMode;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (BuildContext context, SettingsState state) {
        final SettingsCubit cubit = context.read<SettingsCubit>();

        return AppScaffold(
          applyTopPadding: true,
          title: Text(
            LocaleKeys.settings_title.tr(),
            style: textStyle.title.copyWith(color: color.colorTextPrimary),
          ),
          onBack: cubit.onBackPressed,
          body: ListView(
            padding: const EdgeInsets.all(AppDimens.padding16),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: AppDimens.padding4, bottom: AppDimens.padding8),
                child: Text(
                  LocaleKeys.settings_theme.tr(),
                  style: textStyle.bodySmall.copyWith(color: color.colorTextSecondary),
                ),
              ),
              SettingsTileSection(
                children: <Widget>[
                  for (final ThemeModeEnum mode in ThemeModeEnum.values)
                    SettingsTile(
                      title: mode.localeKey.tr(),
                      trailing: currentMode == mode
                          ? Icon(Icons.check_rounded, color: color.colorBrandCoral, size: AppDimens.size20)
                          : null,
                      onTap: () => context.setThemeMode(mode),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
