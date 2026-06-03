import 'package:flutter/material.dart';

import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';
import '../buttons/app_circle_button.dart';
import 'context_menu_item.dart';
import 'context_menu_model.dart';

/// Popup context menu rendering [items] as [ContextMenuItem] rows on a flat
/// surface. The trigger defaults to a circular more-icon button; pass
/// [trigger] for a custom one.
class BaseContextMenu extends StatelessWidget {
  final List<ContextMenuModel> items;
  final bool enabled;
  final String? tooltip;
  final Widget? trigger;

  const BaseContextMenu({
    required this.items,
    this.enabled = true,
    this.tooltip,
    this.trigger,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.currentTokens.color;

    return PopupMenuButton<int>(
      enabled: enabled,
      tooltip: tooltip,
      color: colors.colorBackgroundSurface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.colorBorderDefault),
        borderRadius: BorderRadius.circular(AppDimens.borderRadius16),
      ),
      clipBehavior: Clip.hardEdge,
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context) => _buildEntries(),
      child: trigger ??
          const AppCircleButton(
            size: AppCircleButtonSize.medium,
            icon: Icon(Icons.more_horiz),
          ),
    );
  }

  List<PopupMenuEntry<int>> _buildEntries() {
    final List<PopupMenuEntry<int>> entries = <PopupMenuEntry<int>>[];
    for (int i = 0; i < items.length; i++) {
      final ContextMenuModel model = items[i];
      entries.add(
        PopupMenuItem<int>(
          value: i,
          padding: EdgeInsets.zero,
          onTap: model.onTap,
          child: ContextMenuItem(
            text: model.title,
            icon: model.icon,
            textStyle: model.titleStyle,
            isDestructive: model.isDestructive,
            isSelected: model.isSelected,
          ),
        ),
      );
      if (model.showDividerAfter && i < items.length - 1) {
        entries.add(const PopupMenuDivider());
      }
    }
    return entries;
  }
}
