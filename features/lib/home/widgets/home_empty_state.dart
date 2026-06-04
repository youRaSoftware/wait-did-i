import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

/// Shown when the user has no lists yet — the first thing a new user sees.
class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final ITokens tokens = context.currentTokens;
    final ColorTokens color = tokens.color;
    final TextStyleTokens textStyle = tokens.textStyle;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.padding24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                image: AppAssets.resourcesIconsOutlineHouse,
                width: AppDimens.size56,
                height: AppDimens.size56,
                color: color.colorBrandCoral,
              ),
            ),
            const SizedBox(height: AppDimens.size24),
            Text(
              LocaleKeys.home_emptyTitle.tr(),
              textAlign: TextAlign.center,
              style: textStyle.title.copyWith(color: color.colorTextPrimary),
            ),
            const SizedBox(height: AppDimens.size8),
            Text(
              LocaleKeys.home_emptySubtitle.tr(),
              textAlign: TextAlign.center,
              style: textStyle.body.copyWith(color: color.colorTextSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
