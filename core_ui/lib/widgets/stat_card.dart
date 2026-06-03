import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_theme.dart';

/// Compact stat card: optional icon chip, a value and a title. Flat surface
/// with a thin border. When [accentColor] is set, the icon and value are
/// tinted with it.
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;
  final IconData? icon;
  final Color? accentColor;

  const StatCard({
    required this.title,
    required this.value,
    this.valueColor,
    this.icon,
    this.accentColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.currentTokens.color;
    final TextStyleTokens textStyles = context.currentTokens.textStyle;

    final Color accent = accentColor ?? colors.colorBrandCoral;
    final Color resolvedValueColor = valueColor ?? accentColor ?? colors.colorTextPrimary;

    return Container(
      padding: const EdgeInsets.all(AppDimens.size16),
      decoration: BoxDecoration(
        color: colors.colorBackgroundSurface,
        borderRadius: BorderRadius.circular(AppDimens.borderRadius16),
        border: Border.all(color: colors.colorBorderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Container(
              padding: const EdgeInsets.all(AppDimens.size6),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: AppDimens.opacity12),
                borderRadius: BorderRadius.circular(AppDimens.borderRadius8),
              ),
              child: Icon(
                icon,
                size: AppDimens.size16,
                color: accent,
              ),
            ),
            const SizedBox(height: AppDimens.size8),
          ],
          SizedBox(
            height: AppDimens.size32,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: textStyles.headline.copyWith(color: resolvedValueColor),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.size4),
          Text(
            title,
            style: textStyles.caption.copyWith(color: colors.colorTextSecondary),
          ),
        ],
      ),
    );
  }
}
