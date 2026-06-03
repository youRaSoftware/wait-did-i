import 'package:flutter/material.dart';

import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';

/// Flat dialog with an optional title, subtitle, custom content and actions.
class BaseDialogWidget extends StatelessWidget {
  final List<Widget> actionButtons;
  final String? title;
  final TextStyle? titleStyle;
  final String? subTitle;
  final Widget? content;
  final EdgeInsets? innerPadding;

  const BaseDialogWidget({
    this.actionButtons = const <Widget>[],
    this.title,
    this.titleStyle,
    this.subTitle,
    this.content,
    this.innerPadding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.currentTokens.color;
    final TextStyleTokens textStyle = context.currentTokens.textStyle;

    final TextStyle titleTextStyle = textStyle.title.copyWith(
      color: colors.colorTextPrimary,
    );

    final TextStyle subtitleTextStyle = textStyle.body.copyWith(
      color: colors.colorTextSecondary,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.borderRadius24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: AppDimens.padding20),
      child: Container(
        decoration: BoxDecoration(
          color: colors.colorBackgroundSurface,
          borderRadius: BorderRadius.circular(AppDimens.borderRadius24),
          border: Border.all(color: colors.colorBorderDefault),
        ),
        padding: innerPadding ?? const EdgeInsets.all(AppDimens.padding20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (title != null) Text(title!, style: titleStyle ?? titleTextStyle, textAlign: TextAlign.start),
            if (subTitle != null) ...<Widget>[
              const SizedBox(height: AppDimens.size8),
              Text(subTitle!, style: subtitleTextStyle, textAlign: TextAlign.start),
            ],
            ?content,
            if (actionButtons.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppDimens.size12),
              Column(mainAxisSize: MainAxisSize.min, spacing: AppDimens.size8, children: actionButtons),
            ],
          ],
        ),
      ),
    );
  }
}
