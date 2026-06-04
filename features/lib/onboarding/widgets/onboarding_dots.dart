import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

/// Page indicator: the active dot stretches and uses the accent color.
class OnboardingDots extends StatelessWidget {
  final int count;
  final int currentIndex;

  const OnboardingDots({
    required this.count,
    required this.currentIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int i) {
        final bool active = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: AppDimens.size4),
          width: active ? AppDimens.size20 : AppDimens.size8,
          height: AppDimens.size8,
          decoration: BoxDecoration(
            color: active ? color.colorBrandCoral : color.colorBorderDefault,
            borderRadius: BorderRadius.circular(AppDimens.borderRadius8),
          ),
        );
      }),
    );
  }
}
