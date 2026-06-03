import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';

/// OTP / PIN code input.
class AppCodeInput extends StatefulWidget {
  final int length;
  final bool enabled;
  final bool autofocus;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  const AppCodeInput({
    this.length = 4,
    this.enabled = true,
    this.autofocus = true,
    this.controller,
    this.focusNode,
    this.errorText,
    this.onChanged,
    this.onCompleted,
    super.key,
  });

  @override
  State<AppCodeInput> createState() => _AppCodeInputState();
}

class _AppCodeInputState extends State<AppCodeInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  bool get _isError => widget.errorText != null && widget.errorText!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void didUpdateWidget(covariant AppCodeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _controller.dispose();
      }
      _controller = widget.controller ?? TextEditingController();
    }
    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;
    final TextStyleTokens textStyle = context.currentTokens.textStyle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double totalGap = AppDimens.padding8 * (widget.length - 1);
            final double cellSize = (constraints.maxWidth - totalGap) / widget.length;

            final PinTheme defaultTheme = PinTheme(
              width: cellSize,
              height: cellSize,
              textStyle: textStyle.title.copyWith(color: color.colorTextPrimary),
              decoration: BoxDecoration(
                color: color.colorBackgroundSurface,
                borderRadius: BorderRadius.circular(AppDimens.borderRadius14),
                border: Border.all(color: color.colorBorderDefault),
              ),
            );

            final PinTheme focusedTheme = defaultTheme.copyWith(
              decoration: defaultTheme.decoration!.copyWith(
                border: Border.all(color: _isError ? color.colorStateError : color.colorBorderFocus),
              ),
            );

            final PinTheme submittedTheme = defaultTheme.copyWith(
              decoration: defaultTheme.decoration!.copyWith(
                border: Border.all(color: _isError ? color.colorStateError : color.colorBorderDefault),
              ),
            );

            final PinTheme followingTheme = defaultTheme.copyWith(
              decoration: defaultTheme.decoration!.copyWith(
                border: Border.all(color: _isError ? color.colorStateError : color.colorBorderDefault),
              ),
            );

            final PinTheme errorTheme = defaultTheme.copyWith(
              decoration: defaultTheme.decoration!.copyWith(
                border: Border.all(color: color.colorStateError),
              ),
            );

            return Pinput(
              length: widget.length,
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              keyboardAppearance: Brightness.light,
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              onChanged: widget.onChanged,
              onCompleted: widget.onCompleted,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              defaultPinTheme: defaultTheme,
              focusedPinTheme: focusedTheme,
              submittedPinTheme: submittedTheme,
              followingPinTheme: followingTheme,
              errorPinTheme: errorTheme,
              forceErrorState: _isError,
              showCursor: false,
              separatorBuilder: (int index) => const SizedBox(width: AppDimens.padding8),
            );
          },
        ),
      ],
    );
  }
}
