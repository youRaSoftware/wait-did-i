import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';

/// Data class for a bottom nav item.
class AppBottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const AppBottomNavItem({
    required this.icon,
    required this.label,
    this.activeIcon,
  });
}

/// Flat bottom navigation bar: equal-width tabs, accent for the selected one.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomNavItem> items;

  const AppBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    super.key,
  }) : assert(items.length >= 2, 'AppBottomNavBar requires at least 2 items');

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.currentTokens.color;
    final TextStyleTokens textStyles = context.currentTokens.textStyle;
    final EdgeInsets padding = MediaQuery.of(context).padding;

    return Container(
      padding: EdgeInsets.only(bottom: padding.bottom),
      decoration: BoxDecoration(
        color: colors.colorBackgroundSurface,
        border: Border(top: BorderSide(color: colors.colorBorderDefault)),
      ),
      child: SizedBox(
        height: AppDimens.size56,
        child: Row(
          children: <Widget>[
            for (int i = 0; i < items.length; i++)
              Expanded(
                child: _AppNavItem(
                  item: items[i],
                  isSelected: currentIndex == i,
                  onTap: () => onTap(i),
                  colors: colors,
                  textStyles: textStyles,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AppNavItem extends StatelessWidget {
  final AppBottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorTokens colors;
  final TextStyleTokens textStyles;

  const _AppNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.colors,
    required this.textStyles,
  });

  @override
  Widget build(BuildContext context) {
    final Color tint = isSelected ? colors.colorBrandCoral : colors.colorTextSecondary;

    return GestureDetector(
      onTap: () {
        HapticService.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            isSelected ? (item.activeIcon ?? item.icon) : item.icon,
            size: AppDimens.size24,
            color: tint,
          ),
          const SizedBox(height: AppDimens.size4),
          Text(
            item.label,
            style: textStyles.overline.copyWith(color: tint),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
