import 'package:flutter/cupertino.dart';

import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';
import '../buttons/app_tappable.dart';
import 'app_input_field.dart';

/// Search field with a cancel button.
class AppSearchField extends StatelessWidget {
  final bool autofocus;
  final String? hintText;
  final String cancelText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onCancel;

  const AppSearchField({
    this.autofocus = false,
    this.hintText,
    this.cancelText = 'Cancel',
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;
    final TextStyleTokens textStyle = context.currentTokens.textStyle;

    return Row(
      children: <Widget>[
        Expanded(
          child: AppInputField(
            size: AppInputFieldSize.medium,
            autofocus: autofocus,
            hintText: hintText,
            controller: controller,
            focusNode: focusNode,
            textInputAction: TextInputAction.search,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ),
        if (onCancel != null) ...<Widget>[
          const SizedBox(width: AppDimens.padding12),
          AppTappable(
            onTap: onCancel,
            child: Text(
              cancelText,
              style: textStyle.button.copyWith(color: color.colorBrandCoral),
            ),
          ),
        ],
      ],
    );
  }
}
