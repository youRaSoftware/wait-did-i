import 'package:flutter/cupertino.dart';

import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';
import 'app_input_field.dart';

/// Search field with a cancel button.
class AppSearchField extends StatefulWidget {
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
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  bool _isCancelPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isCancelPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isCancelPressed = false;
    });
    widget.onCancel?.call();
  }

  void _onTapCancel() {
    setState(() {
      _isCancelPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;
    final TextStyleTokens textStyle = context.currentTokens.textStyle;

    return Row(
      children: <Widget>[
        Expanded(
          child: AppInputField(
            size: AppInputFieldSize.medium,
            autofocus: widget.autofocus,
            hintText: widget.hintText,
            controller: widget.controller,
            focusNode: widget.focusNode,
            textInputAction: TextInputAction.search,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
          ),
        ),
        if (widget.onCancel != null) ...<Widget>[
          const SizedBox(width: AppDimens.padding12),
          GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            behavior: HitTestBehavior.opaque,
            child: AnimatedOpacity(
              opacity: _isCancelPressed ? AppDimens.opacity5 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: Text(
                widget.cancelText,
                style: textStyle.button.copyWith(color: color.colorBrandCoral),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
