import 'package:flutter/material.dart';

import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';
import '../buttons/app_tappable.dart';

enum ToastType { success, error, warning, info }

/// Flat toast: surface card with a thin border, a colored leading icon and text.
class ToastWidget extends StatelessWidget {
  final String message;
  final ToastType toastType;
  final VoidCallback? onPressed;

  const ToastWidget({
    required this.message,
    this.toastType = ToastType.info,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.currentTokens.color;
    final TextStyleTokens styles = context.currentTokens.textStyle;

    return AppTappable(
      onTap: onPressed,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.size16,
          vertical: AppDimens.size12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.borderRadius16),
          color: colors.colorBackgroundSurface,
          border: Border.all(color: colors.colorBorderDefault),
          boxShadow: context.currentTokens.shadow.shadowElevation2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              _getIcon(),
              size: AppDimens.size24,
              color: _getIconColor(colors),
            ),
            const SizedBox(width: AppDimens.size12),
            Flexible(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: styles.bodySmall.copyWith(color: colors.colorTextPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getIconColor(ColorTokens colors) {
    switch (toastType) {
      case ToastType.success:
        return colors.colorStateSuccess;
      case ToastType.error:
        return colors.colorStateError;
      case ToastType.warning:
        return colors.colorStateWarning;
      case ToastType.info:
        return colors.colorStateInfo;
    }
  }

  IconData _getIcon() {
    switch (toastType) {
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.warning:
        return Icons.warning_amber_rounded;
      case ToastType.info:
        return Icons.info_outline;
    }
  }
}
