import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_theme.dart';

/// Section title row with an optional coloured dot before the label and an
/// optional trailing widget. Heading for grouped lists.
class SectionHeader extends StatelessWidget {
  final String title;
  final Color? badgeColor;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    required this.title,
    this.badgeColor,
    this.trailing,
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.currentTokens.color;
    final TextStyleTokens textStyles = context.currentTokens.textStyle;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (badgeColor != null) ...<Widget>[
                Container(
                  width: AppDimens.size8,
                  height: AppDimens.size8,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppDimens.size8),
              ],
              Text(
                title,
                style: textStyles.subtitle.copyWith(color: colors.colorTextPrimary),
              ),
            ],
          ),
          ?trailing,
        ],
      ),
    );
  }
}
