import 'package:flutter/material.dart';

import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';

/// Multiline bio/notes field with a character counter.
class AppBioField extends StatefulWidget {
  final int maxLength;
  final bool enabled;
  final bool autofocus;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  const AppBioField({
    this.maxLength = 150,
    this.enabled = true,
    this.autofocus = true,
    this.hintText,
    this.controller,
    this.focusNode,
    this.onChanged,
    super.key,
  });

  @override
  State<AppBioField> createState() => _AppBioFieldState();
}

class _AppBioFieldState extends State<AppBioField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  int _textLength = 0;
  bool _hasFocus = false;

  int get _remaining => widget.maxLength - _textLength;

  bool get _isOverLimit => _remaining < 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _textLength = _controller.text.length;
    _hasFocus = _focusNode.hasFocus;
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant AppBioField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_onTextChanged);
      if (oldWidget.controller == null) {
        _controller.dispose();
      }
      _controller = widget.controller ?? TextEditingController();
      _textLength = _controller.text.length;
      _controller.addListener(_onTextChanged);
    }
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_onFocusChanged);
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChanged);
      _hasFocus = _focusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _textLength = _controller.text.length;
    });
  }

  void _onFocusChanged() {
    if (_hasFocus == _focusNode.hasFocus) return;
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;
    final TextStyleTokens textStyle = context.currentTokens.textStyle;

    final Color dividerColor = _hasFocus ? color.colorBorderFocus : color.colorBorderDefault;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            cursorColor: color.colorBrandCoral,
            cursorWidth: AppDimens.size1,
            style: textStyle.body.copyWith(color: color.colorTextPrimary),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: textStyle.body.copyWith(color: color.colorTextTertiary),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            onChanged: widget.onChanged,
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          height: AppDimens.size1,
          color: dividerColor,
        ),
        Padding(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$_remaining',
              style: textStyle.body.copyWith(
                color: _isOverLimit ? color.colorStateError : color.colorTextSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
