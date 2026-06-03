import 'package:flutter/material.dart';

import '../../core_ui.dart' show BaseContextMenu;
import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';
import '../widgets.dart' show BaseContextMenu;
import 'base_context_menu.dart' show BaseContextMenu;

/// Visual row for a [BaseContextMenu] entry. Title + optional leading Material
/// icon; [isSelected] adds a trailing checkmark in the accent and
/// [isDestructive] recolours text + icon to the error colour.
class ContextMenuItem extends StatelessWidget {
  final String text;
  final IconData? icon;
  final TextStyle? textStyle;
  final bool isDestructive;
  final bool isSelected;

  const ContextMenuItem({
    required this.text,
    this.icon,
    this.textStyle,
    this.isDestructive = false,
    this.isSelected = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.currentTokens.color;
    final TextStyleTokens textStyles = context.currentTokens.textStyle;

    final Color contentColor = isDestructive
        ? colors.colorStateError
        : (isSelected ? colors.colorBrandCoral : colors.colorTextPrimary);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.size16,
        vertical: AppDimens.size10,
      ),
      child: Row(
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(
              icon,
              size: AppDimens.size20,
              color: contentColor,
            ),
            const SizedBox(width: AppDimens.size12),
          ],
          Expanded(
            child: Text(
              text,
              style: (textStyle ?? textStyles.bodySmall).copyWith(
                color: contentColor,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(left: AppDimens.size8),
              child: Icon(
                Icons.check,
                size: AppDimens.size18,
                color: colors.colorBrandCoral,
              ),
            ),
        ],
      ),
    );
  }
}
