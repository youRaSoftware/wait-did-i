import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Three dots bouncing in sequence — a calm loading indicator.
class BouncingDotsLoader extends StatefulWidget {
  final Color? color;
  final double dotSize;
  final double bounceHeight;
  final Duration duration;

  const BouncingDotsLoader({
    this.color,
    this.dotSize = 12,
    this.bounceHeight = 8,
    this.duration = const Duration(milliseconds: 1200),
    super.key,
  });

  @override
  State<BouncingDotsLoader> createState() => _BouncingDotsLoaderState();
}

class _BouncingDotsLoaderState extends State<BouncingDotsLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _animations = List<Animation<double>>.generate(3, (int index) {
      final double start = index * 0.2;
      final double end = start + 0.4;
      return TweenSequence<double>(<TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0, end: -widget.bounceHeight).chain(CurveTween(curve: Curves.easeOut)),
          weight: 50,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: -widget.bounceHeight, end: 0).chain(CurveTween(curve: Curves.easeIn)),
          weight: 50,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end.clamp(0.0, 1.0)),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color dotColor = widget.color ?? context.currentTokens.color.colorBrandCoral;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(3, (int index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (BuildContext context, Widget? child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.dotSize * 0.3),
              child: Transform.translate(
                offset: Offset(0, _animations[index].value),
                child: child,
              ),
            );
          },
          child: Container(
            width: widget.dotSize,
            height: widget.dotSize,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
