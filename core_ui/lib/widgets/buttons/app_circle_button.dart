import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';

enum AppCircleButtonStyle {
  /// Primary action — accent fill.
  primary,

  /// Secondary action — light surface fill.
  secondary,

  /// Stroke action — surface fill + thin border.
  stroke,
}

enum AppCircleButtonSize {
  /// 64px
  extraLarge,

  /// 52px
  large,

  /// 48px
  medium,

  /// 42px
  small,
}

/// Circle button with an icon. Flat, calm style.
class AppCircleButton extends StatefulWidget {
  final AppCircleButtonStyle style;
  final AppCircleButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final Widget icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  const AppCircleButton({
    this.style = AppCircleButtonStyle.secondary,
    this.size = AppCircleButtonSize.large,
    this.isLoading = false,
    this.isDisabled = false,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    super.key,
  });

  @override
  State<AppCircleButton> createState() => _AppCircleButtonState();
}

class _AppCircleButtonState extends State<AppCircleButton> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _loadingController;

  bool get _isInteractive => !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut));
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isLoading) {
      _loadingController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AppCircleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      widget.isLoading ? _loadingController.repeat() : _loadingController.stop();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (_isInteractive) {
      _scaleController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_isInteractive) {
      _scaleController.reverse();
      HapticService.mediumImpact();
      widget.onPressed?.call();
    }
  }

  void _onTapCancel() {
    if (_isInteractive) {
      _scaleController.reverse();
    }
  }

  double _getSize() {
    return switch (widget.size) {
      AppCircleButtonSize.extraLarge => AppDimens.size64,
      AppCircleButtonSize.large => AppDimens.size52,
      AppCircleButtonSize.medium => AppDimens.size48,
      AppCircleButtonSize.small => AppDimens.size42,
    };
  }

  Color _getBackgroundColor(ColorTokens color) {
    if (widget.isDisabled) return color.colorBackgroundSecondary;
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    return switch (widget.style) {
      AppCircleButtonStyle.primary => color.colorBrandCoral,
      AppCircleButtonStyle.secondary => color.colorBackgroundSecondary,
      AppCircleButtonStyle.stroke => color.colorBackgroundSurface,
    };
  }

  Color _getIconColor(ColorTokens color) {
    if (widget.isDisabled) return color.colorTextDisabled;
    return switch (widget.style) {
      AppCircleButtonStyle.primary => color.colorTextInverse,
      AppCircleButtonStyle.secondary => color.colorTextPrimary,
      AppCircleButtonStyle.stroke => color.colorTextPrimary,
    };
  }

  Border? _getBorder(ColorTokens color) {
    if (widget.isDisabled || widget.isLoading) return null;
    return switch (widget.style) {
      AppCircleButtonStyle.primary => null,
      AppCircleButtonStyle.secondary => null,
      AppCircleButtonStyle.stroke => Border.all(color: color.colorBorderDefault),
    };
  }

  double _getIconSize() {
    return switch (widget.size) {
      AppCircleButtonSize.extraLarge => AppDimens.size24,
      AppCircleButtonSize.large => AppDimens.size24,
      AppCircleButtonSize.medium => AppDimens.size24,
      AppCircleButtonSize.small => AppDimens.size20,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;
    final double circleSize = _getSize();

    final Widget circle = Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getBackgroundColor(color),
        border: _getBorder(color),
      ),
      child: Center(
        child: IconTheme(
          data: IconThemeData(color: _getIconColor(color), size: _getIconSize()),
          child: widget.icon,
        ),
      ),
    );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: circleSize,
          height: circleSize,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              if (widget.isLoading)
                RotationTransition(
                  turns: _loadingController,
                  child: CustomPaint(
                    size: Size(circleSize, circleSize),
                    painter: _LoadingArcPainter(color: color.colorBrandCoral),
                  ),
                ),
              circle,
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingArcPainter extends CustomPainter {
  final Color color;
  static const double _strokeWidth = 2.0;

  _LoadingArcPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Rect rect = Rect.fromLTWH(
      _strokeWidth / 2,
      _strokeWidth / 2,
      size.width - _strokeWidth,
      size.height - _strokeWidth,
    );

    // 270° sweep = 3π/2 radians, starting from top (-π/2)
    canvas.drawArc(rect, -pi / 2, 3 * pi / 2, false, paint);
  }

  @override
  bool shouldRepaint(covariant _LoadingArcPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
