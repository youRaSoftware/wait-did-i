import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';
import '../buttons/app_tappable.dart';

enum AppInputFieldSize {
  /// 42px
  small,

  /// 48px
  medium,

  /// 52px
  large,
}

/// Universal text input field. Flat surface + thin border.
class AppInputField extends StatefulWidget {
  final AppInputFieldSize size;
  final bool enabled;
  final bool showClearButton;
  final bool obscureText;
  final bool autofocus;
  final int maxLines;
  final String? hintText;
  final String? initialValue;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? errorText;
  final Widget? prefixWidget;
  final Widget? suffixWidget;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;

  const AppInputField({
    this.size = AppInputFieldSize.large,
    this.enabled = true,
    this.showClearButton = true,
    this.obscureText = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.hintText,
    this.initialValue,
    this.controller,
    this.focusNode,
    this.errorText,
    this.prefixWidget,
    this.suffixWidget,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    super.key,
  });

  @override
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasFocus = false;
  bool _hasText = false;
  bool _isObscured = true;

  bool get _isError => widget.errorText != null && widget.errorText!.isNotEmpty;

  bool get _shouldShowClearButton => widget.showClearButton && _hasText && _hasFocus && !widget.obscureText;

  bool get _shouldShowPasswordToggle => widget.obscureText;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _hasText = _controller.text.isNotEmpty;
    _hasFocus = _focusNode.hasFocus;
    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant AppInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _controller.removeListener(_onTextChanged);
        _controller.dispose();
      }
      _controller = widget.controller ?? TextEditingController();
      _controller.addListener(_onTextChanged);
      _hasText = _controller.text.isNotEmpty;
    }
    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        _focusNode.removeListener(_onFocusChanged);
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChanged);
      _hasFocus = _focusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  void _onTextChanged() {
    final bool hasText = _controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  Color _getBorderColor(ColorTokens color) {
    if (_isError) return color.colorStateError;
    if (_hasFocus) return color.colorBorderFocus;
    return color.colorBorderDefault;
  }

  double get _height {
    switch (widget.size) {
      case AppInputFieldSize.large:
        return AppDimens.size52;
      case AppInputFieldSize.medium:
        return AppDimens.size48;
      case AppInputFieldSize.small:
        return AppDimens.size42;
    }
  }

  TextStyle _getTextStyle(TextStyleTokens textStyle) {
    switch (widget.size) {
      case AppInputFieldSize.large:
      case AppInputFieldSize.medium:
        return textStyle.body;
      case AppInputFieldSize.small:
        return textStyle.bodySmall;
    }
  }

  bool get _hasSuffix => _shouldShowClearButton || _shouldShowPasswordToggle || widget.suffixWidget != null;

  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;
    final TextStyleTokens textStyle = context.currentTokens.textStyle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: _height,
          decoration: BoxDecoration(
            color: color.colorBackgroundSurface,
            borderRadius: BorderRadius.circular(AppDimens.borderRadius14),
            border: Border.all(color: _getBorderColor(color)),
          ),
          child: Row(
            children: <Widget>[
              if (widget.prefixWidget != null)
                Padding(
                  padding: const EdgeInsets.only(left: AppDimens.padding18),
                  child: widget.prefixWidget,
                ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  obscureText: widget.obscureText && _isObscured,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onChanged: widget.onChanged,
                  onEditingComplete: widget.onEditingComplete,
                  onSubmitted: widget.onSubmitted,
                  autofocus: widget.autofocus,
                  maxLines: widget.maxLines,
                  inputFormatters: widget.inputFormatters,
                  cursorColor: color.colorBrandCoral,
                  cursorWidth: AppDimens.size1,
                  cursorHeight: AppDimens.size24,
                  style: _getTextStyle(textStyle).copyWith(color: color.colorTextPrimary),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: _getTextStyle(textStyle).copyWith(color: color.colorTextTertiary),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                      left: widget.prefixWidget != null ? AppDimens.padding8 : AppDimens.padding18,
                      right: _hasSuffix ? AppDimens.padding8 : AppDimens.padding18,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              if (_shouldShowPasswordToggle)
                AppTappable(
                  haptic: AppHaptic.selection,
                  onTap: _togglePasswordVisibility,
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppDimens.padding14),
                    child: Icon(
                      _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: AppDimens.size20,
                      color: color.colorTextTertiary,
                    ),
                  ),
                )
              else if (_shouldShowClearButton)
                AppTappable(
                  onTap: _clearText,
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppDimens.padding14),
                    child: Icon(
                      Icons.close,
                      size: AppDimens.size20,
                      color: color.colorTextTertiary,
                    ),
                  ),
                )
              else if (widget.suffixWidget != null)
                Padding(
                  padding: const EdgeInsets.only(right: AppDimens.padding14),
                  child: widget.suffixWidget,
                ),
            ],
          ),
        ),
        if (_isError)
          Padding(
            padding: const EdgeInsets.only(top: AppDimens.margin6, left: AppDimens.padding4),
            child: Text(
              widget.errorText!,
              style: textStyle.bodySmall.copyWith(color: color.colorStateError),
            ),
          ),
      ],
    );
  }
}
