import 'package:flutter/material.dart';

import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';

/// Bottom sheet container with a grabber handle and rounded top corners.
class BaseBottomSheet extends StatelessWidget {
  final Widget contentWidget;
  final Color? backgroundColor;

  const BaseBottomSheet({
    required this.contentWidget,
    this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.currentTokens.color;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.colorBackgroundSurface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimens.borderRadius24),
          topRight: Radius.circular(AppDimens.borderRadius24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: AppDimens.size8),
            Container(
              width: AppDimens.size50,
              height: AppDimens.size4,
              decoration: BoxDecoration(
                color: colors.colorBorderDefault,
                borderRadius: BorderRadius.circular(AppDimens.borderRadius100),
              ),
            ),
            const SizedBox(height: AppDimens.size12),
            Flexible(
              child: SafeArea(
                bottom: false,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.93),
                  child: contentWidget,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
