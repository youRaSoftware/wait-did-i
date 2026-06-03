import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Animated shimmer placeholder: a solid base block plus a soft highlight band
/// that diagonally sweeps across. Compose these to build skeleton screens.
class ShimmerBox extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerBox({
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
    super.key,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.currentTokens.color;
    final Color base = widget.baseColor ?? colors.colorBackgroundSecondary;
    final Color highlight = widget.highlightColor ?? colors.colorBackgroundSurface;
    final BorderRadius radius = widget.borderRadius ?? BorderRadius.zero;

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(color: base),
              child: const SizedBox.expand(),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, _) {
                final double t = _controller.value;
                final double position = -1.4 + 3.8 * t;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(position - 0.6, -0.5),
                      end: Alignment(position + 0.6, 0.5),
                      colors: <Color>[
                        Colors.transparent,
                        Colors.transparent,
                        highlight,
                        Colors.transparent,
                        Colors.transparent,
                      ],
                      stops: const <double>[0.0, 0.35, 0.5, 0.65, 1.0],
                    ),
                  ),
                  child: const SizedBox.expand(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
