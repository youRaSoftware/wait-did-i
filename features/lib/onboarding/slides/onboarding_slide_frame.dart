import 'package:flutter/material.dart';

import '../widgets/onboarding_colors.dart';
import '../widgets/onboarding_motion.dart';

/// Shared layout + lifecycle for an onboarding slide: a centered "stage" area
/// and a bottom text block whose headline/subline fade-and-rise in sequence.
///
/// Owns the single [AnimationController] that drives the slide. The intro
/// **replays** every time the slide becomes active (swipe back returns to it).
class OnboardingSlideFrame extends StatefulWidget {
  const OnboardingSlideFrame({
    super.key,
    required this.isActive,
    required this.stageTop,
    required this.stageHeight,
    required this.headline,
    required this.subline,
    required this.stageBuilder,
  });

  final bool isActive;
  final double stageTop;
  final double stageHeight;
  final String headline;
  final String subline;
  final Widget Function(BuildContext context, Animation<double> anim) stageBuilder;

  @override
  State<OnboardingSlideFrame> createState() => _OnboardingSlideFrameState();
}

class _OnboardingSlideFrameState extends State<OnboardingSlideFrame> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: OnboardingMotion.slideDuration,
  );

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _controller.forward(from: 0);
  }

  @override
  void didUpdateWidget(OnboardingSlideFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: widget.stageTop,
          left: 0,
          right: 0,
          height: widget.stageHeight,
          child: Center(child: widget.stageBuilder(context, _controller)),
        ),
        Positioned(
          bottom: 180,
          left: 28,
          right: 28,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _RisingText(
                anim: _controller,
                interval: OnboardingMotion.title,
                child: Text(widget.headline, style: OnboardingText.headline),
              ),
              const SizedBox(height: 14),
              _RisingText(
                anim: _controller,
                interval: OnboardingMotion.subtitle,
                child: Text(widget.subline, style: OnboardingText.subline),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Fade + translateY(20→0) driven by a sub-[interval] of the slide controller.
class _RisingText extends StatelessWidget {
  const _RisingText({required this.anim, required this.interval, required this.child});

  final Animation<double> anim;
  final Interval interval;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (BuildContext context, Widget? c) {
        final double t = interval.transform(anim.value).clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 20 * (1 - t)), child: c),
        );
      },
      child: child,
    );
  }
}
