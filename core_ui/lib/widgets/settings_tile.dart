import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_theme.dart';
import 'buttons/app_tappable.dart';

/// Single tile for use inside SettingsTileSection.
class SettingsTile extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    required this.title,
    this.titleColor,
    this.leading,
    this.trailing,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.currentTokens.color;
    final TextStyleTokens textStyles = context.currentTokens.textStyle;

    return AppTappable(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          if (leading != null) ...<Widget>[
            leading!,
            const SizedBox(width: AppDimens.size12),
          ],
          Expanded(
            child: Text(
              title,
              style: textStyles.body.copyWith(
                color: titleColor ?? colors.colorTextPrimary,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
