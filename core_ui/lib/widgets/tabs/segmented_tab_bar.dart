import 'package:flutter/material.dart';

import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';
import '../buttons/app_tappable.dart';

/// Equal-width segmented tab strip with the active item filled in the accent.
class SegmentedTabBar extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final EdgeInsetsGeometry? margin;

  const SegmentedTabBar({
    required this.labels,
    required this.selectedIndex,
    required this.onTabChanged,
    this.margin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.currentTokens.color;
    final TextStyleTokens textStyles = context.currentTokens.textStyle;

    return Container(
      margin: margin ?? const EdgeInsets.all(AppDimens.size16),
      padding: const EdgeInsets.all(AppDimens.padding4),
      decoration: BoxDecoration(
        color: colors.colorBackgroundSecondary,
        borderRadius: BorderRadius.circular(AppDimens.borderRadius12),
      ),
      child: Row(
        children: List<Widget>.generate(labels.length, (int index) {
          final bool isSelected = selectedIndex == index;
          return Expanded(
            child: AppTappable(
              haptic: AppHaptic.selection,
              enableScale: false,
              onTap: () => onTabChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: AppDimens.padding10),
                decoration: BoxDecoration(
                  color: isSelected ? colors.colorBrandCoral : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimens.borderRadius10),
                ),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: textStyles.bodySmall.copyWith(
                    color: isSelected ? colors.colorTextInverse : colors.colorTextSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
