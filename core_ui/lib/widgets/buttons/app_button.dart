import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';

enum AppButtonStyle {
  /// Primary action — solid accent fill.
  primary,

  /// Secondary action — light surface + subtle border.
  secondary,

  /// Destructive action — error fill.
  error,

  /// Text only, no background — accent text.
  text,
}

enum AppButtonSize {
  /// 52px
  large,

  /// 48px
  medium,

  /// 42px
  small,
}

/// Universal button. Flat, calm style: solid fills, thin borders, no glow.
class AppButton extends StatefulWidget {
  final AppButtonStyle style;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final bool isExpanded;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final String? text;
  final Widget? icon;
  final Color? textColor;
  final VoidCallback? onPressed;

  const AppButton({
    this.style = AppButtonStyle.primary,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.isDisabled = false,
    this.isExpanded = true,
    this.padding,
    this.margin,
    this.text,
    this.icon,
    this.textColor,
    this.onPressed,
    super.key,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool get _isInteractive => !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (_isInteractive) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_isInteractive) {
      _controller.reverse();
      HapticService.mediumImpact();
      widget.onPressed?.call();
    }
  }

  void _onTapCancel() {
    if (_isInteractive) {
      _controller.reverse();
    }
  }

  double _getHeight() {
    return switch (widget.size) {
      AppButtonSize.large => AppDimens.size52,
      AppButtonSize.medium => AppDimens.size48,
      AppButtonSize.small => AppDimens.size42,
    };
  }

  Color _getBackgroundColor(ColorTokens color) {
    if (widget.style == AppButtonStyle.text) return Colors.transparent;
    if (widget.isDisabled) return color.colorBackgroundSecondary;

    return switch (widget.style) {
      AppButtonStyle.primary => color.colorBrandCoral,
      AppButtonStyle.secondary => color.colorBackgroundSecondary,
      AppButtonStyle.error => color.colorStateError,
      AppButtonStyle.text => Colors.transparent,
    };
  }

  Color _getTextColor(ColorTokens color) {
    if (widget.style == AppButtonStyle.text) {
      return widget.isDisabled ? color.colorTextDisabled : color.colorBrandCoral;
    }
    if (widget.isDisabled) return color.colorTextDisabled;

    return switch (widget.style) {
      // Filled with a dark accent — content is light.
      AppButtonStyle.primary => color.colorTextInverse,
      AppButtonStyle.error => color.colorTextInverse,
      // Light surface — content is dark.
      AppButtonStyle.secondary => color.colorTextPrimary,
      AppButtonStyle.text => color.colorBrandCoral,
    };
  }

  TextStyle _getTextStyle(TextStyleTokens textStyle) {
    return switch (widget.size) {
      AppButtonSize.large => textStyle.button,
      AppButtonSize.medium => textStyle.button,
      AppButtonSize.small => textStyle.button,
    };
  }

  Border? _getBorder(ColorTokens color) {
    if (widget.isDisabled) return null;

    return switch (widget.style) {
      AppButtonStyle.secondary => Border.all(color: color.colorBorderDefault),
      AppButtonStyle.primary => null,
      AppButtonStyle.error => null,
      AppButtonStyle.text => null,
    };
  }

  double _getIconSize() {
    return switch (widget.size) {
      AppButtonSize.large => AppDimens.size24,
      AppButtonSize.medium => AppDimens.size24,
      AppButtonSize.small => AppDimens.size20,
    };
  }

  double _getLoaderSize() {
    return switch (widget.size) {
      AppButtonSize.large => AppDimens.size20,
      AppButtonSize.medium => AppDimens.size20,
      AppButtonSize.small => AppDimens.size16,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ITokens tokens = context.currentTokens;
    final ColorTokens color = tokens.color;
    final TextStyleTokens textStyle = tokens.textStyle;

    final Color contentColor = widget.textColor ?? _getTextColor(color);

    final BorderRadius borderRadius = BorderRadius.circular(AppDimens.borderRadius16);

    final Widget container = Container(
      height: _getHeight(),
      width: widget.isExpanded ? double.infinity : null,
      padding: widget.isExpanded ? null : widget.padding ?? const EdgeInsets.symmetric(horizontal: AppDimens.padding36),
      decoration: BoxDecoration(
        color: _getBackgroundColor(color),
        borderRadius: borderRadius,
        border: _getBorder(color),
      ),
      child: Center(
        child: widget.isLoading
            ? SizedBox(
                width: _getLoaderSize(),
                height: _getLoaderSize(),
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(contentColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (widget.icon != null)
                    IconTheme(
                      data: IconThemeData(color: contentColor, size: _getIconSize()),
                      child: widget.icon!,
                    ),
                  if (widget.icon != null && widget.text != null) const SizedBox(width: AppDimens.padding8),
                  if (widget.text != null)
                    Text(
                      widget.text!,
                      style: _getTextStyle(textStyle).copyWith(color: contentColor),
                    ),
                ],
              ),
      ),
    );

    Widget button = GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: container,
      ),
    );

    if (widget.margin != null) {
      button = Padding(padding: widget.margin!, child: button);
    }

    return button;
  }
}
