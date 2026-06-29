import 'package:flutter/material.dart';

import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';
import '../buttons/app_tappable.dart';

/// Navigation bar with optional back button, centered title and actions.
class CustomAppBar extends StatelessWidget {
  final bool showBackButton;
  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  const CustomAppBar({
    this.showBackButton = true,
    this.leading,
    this.title,
    this.actions,
    this.onBack,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding16,
      ).copyWith(bottom: AppDimens.padding16),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          title ?? const SizedBox.shrink(),
          Row(
            children: <Widget>[
              leading ??
                  (showBackButton
                      ? AppTappable(
                          onTap: onBack ?? () => Navigator.of(context).pop(),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: AppDimens.size24,
                            color: color.colorTextPrimary,
                          ),
                        )
                      : const SizedBox.shrink()),
              const Spacer(),
              if (actions != null && actions!.isNotEmpty)
                ...actions!
                    .expand<Widget>(
                      (Widget action) => <Widget>[
                        const SizedBox(width: AppDimens.padding16),
                        action,
                      ],
                    )
                    .skip(1),
            ],
          ),
        ],
      ),
    );
  }
}
