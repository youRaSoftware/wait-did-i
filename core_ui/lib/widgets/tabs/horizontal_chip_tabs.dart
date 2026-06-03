import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';

/// Data model for a single chip tab item.
class ChipTabItem {
  final String id;
  final String label;

  const ChipTabItem({
    required this.id,
    required this.label,
  });
}

/// Horizontally-scrollable chip tabs.
class HorizontalChipTabs extends StatelessWidget {
  final List<ChipTabItem> items;
  final String? selectedId;
  final ValueChanged<String> onSelected;
  final EdgeInsets? padding;

  const HorizontalChipTabs({
    required this.items,
    required this.selectedId,
    required this.onSelected,
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.currentTokens.color;
    final TextStyleTokens textStyles = context.currentTokens.textStyle;

    return SizedBox(
      height: AppDimens.size48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: AppDimens.size16),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final ChipTabItem item = items[index];
          final bool isSelected = item.id == selectedId;

          return GestureDetector(
            onTap: () {
              HapticService.selectionClick();
              onSelected(item.id);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.padding12,
                vertical: AppDimens.padding8,
              ),
              margin: const EdgeInsets.only(
                right: AppDimens.padding8,
                top: AppDimens.padding4,
                bottom: AppDimens.padding4,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.colorBrandCoral.withValues(alpha: AppDimens.opacity12)
                    : colors.colorBackgroundSecondary,
                borderRadius: BorderRadius.circular(AppDimens.borderRadius20),
                border: Border.all(
                  color: isSelected ? colors.colorBrandCoral : colors.colorBorderDefault,
                ),
              ),
              child: Center(
                child: Text(
                  item.label,
                  style: textStyles.bodySmall.copyWith(
                    color: isSelected ? colors.colorBrandCoral : colors.colorTextSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
