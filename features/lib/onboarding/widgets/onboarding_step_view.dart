import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

/// Per-step content descriptor: placeholder icon + localization keys.
class OnboardingStepData {
  final String icon;
  final String titleKey;
  final String subtitleKey;

  const OnboardingStepData({
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
  });
}

/// A single onboarding page: placeholder illustration, title and subtitle.
class OnboardingStepView extends StatelessWidget {
  final OnboardingStepData step;

  const OnboardingStepView({required this.step, super.key});

  @override
  Widget build(BuildContext context) {
    final ITokens tokens = context.currentTokens;
    final ColorTokens color = tokens.color;
    final TextStyleTokens textStyle = tokens.textStyle;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: AppDimens.size120,
          height: AppDimens.size120,
          decoration: BoxDecoration(
            color: color.colorBackgroundSecondary,
            borderRadius: BorderRadius.circular(AppDimens.borderRadius28),
          ),
          alignment: Alignment.center,
          child: AppImage(
            image: step.icon,
            width: AppDimens.size56,
            height: AppDimens.size56,
            color: color.colorBrandCoral,
          ),
        ),
        const SizedBox(height: AppDimens.size32),
        Text(
          step.titleKey.tr(),
          textAlign: TextAlign.center,
          style: textStyle.headline.copyWith(color: color.colorTextPrimary),
        ),
        const SizedBox(height: AppDimens.size12),
        Text(
          step.subtitleKey.tr(),
          textAlign: TextAlign.center,
          style: textStyle.body.copyWith(color: color.colorTextSecondary),
        ),
      ],
    );
  }
}
