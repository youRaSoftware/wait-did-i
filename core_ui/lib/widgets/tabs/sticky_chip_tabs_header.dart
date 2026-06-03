import 'package:flutter/material.dart';

import '../../theme/app_dimens.dart';
import 'horizontal_chip_tabs.dart';

/// [SliverPersistentHeaderDelegate] that pins a [HorizontalChipTabs] strip
/// to the top of a [CustomScrollView] while content scrolls beneath.
class StickyChipTabsHeader extends SliverPersistentHeaderDelegate {
  final List<ChipTabItem> items;
  final String selectedId;
  final ValueChanged<String> onSelected;
  final Color backgroundColor;

  StickyChipTabsHeader({
    required this.items,
    required this.selectedId,
    required this.onSelected,
    required this.backgroundColor,
  });

  @override
  double get minExtent => AppDimens.size48 + AppDimens.padding8 * 2;

  @override
  double get maxExtent => AppDimens.size48 + AppDimens.padding8 * 2;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: AppDimens.padding8),
      child: HorizontalChipTabs(
        items: items,
        selectedId: selectedId,
        onSelected: onSelected,
      ),
    );
  }

  @override
  bool shouldRebuild(StickyChipTabsHeader old) {
    return old.selectedId != selectedId ||
        old.items.length != items.length ||
        old.backgroundColor != backgroundColor;
  }
}
