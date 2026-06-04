import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../cubit/settings_cubit.dart';

class SettingsForm extends StatelessWidget {
  const SettingsForm({super.key});

  @override
  Widget build(BuildContext context) {
    final ITokens tokens = context.currentTokens;
    final ColorTokens color = tokens.color;
    final TextStyleTokens textStyle = tokens.textStyle;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (BuildContext context, SettingsState state) {
        final SettingsCubit cubit = context.read<SettingsCubit>();

        return AppScaffold(
          title: Text(
            LocaleKeys.settings_title.tr(),
            style: textStyle.title.copyWith(color: color.colorTextPrimary),
          ),
          onBack: cubit.onBackPressed,
          body: Center(
            child: Text(
              LocaleKeys.settings_soon.tr(),
              style: textStyle.body.copyWith(color: color.colorTextSecondary),
            ),
          ),
        );
      },
    );
  }
}
