import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_theme.dart';

/// Rounded card that groups children with thin dividers between them.
class SettingsTileSection extends StatelessWidget {
  final List<Widget> children;

  const SettingsTileSection({
    required this.children,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorTokens colorTokens = context.currentTokens.color;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorTokens.colorBackgroundSurface,
        borderRadius: BorderRadius.circular(AppDimens.borderRadius16),
        border: Border.all(color: colorTokens.colorBorderDefault),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.borderRadius16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(children.length * 2 - 1, (int i) {
            if (i.isOdd) {
              return Divider(
                height: AppDimens.size1,
                thickness: AppDimens.size1,
                color: colorTokens.colorBorderDefault,
                indent: AppDimens.padding18,
                endIndent: AppDimens.padding18,
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.padding18,
                vertical: AppDimens.padding12,
              ),
              child: children[i ~/ 2],
            );
          }),
        ),
      ),
    );
  }
}
