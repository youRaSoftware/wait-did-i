import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../widgets/onboarding_motion.dart';
import '../widgets/painters/night_house_painter.dart';
import 'onboarding_slide_frame.dart';

/// Slide 3 — a night house with a warm glowing window, crescent moon and
/// twinkling stars. The most "poetic" slide.
class SlideNightHouse extends StatefulWidget {
  const SlideNightHouse({super.key, required this.isActive});

  final bool isActive;

  @override
  State<SlideNightHouse> createState() => _SlideNightHouseState();
}

class _SlideNightHouseState extends State<SlideNightHouse> with SingleTickerProviderStateMixin {
  late final AnimationController _twinkle = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  static double _p(Interval i, double v) => ((v - i.begin) / (i.end - i.begin)).clamp(0.0, 1.0);

  @override
  void dispose() {
    _twinkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingSlideFrame(
      isActive: widget.isActive,
      stageTop: 140,
      stageHeight: 320,
      headline: LocaleKeys.onboarding_slide3Title.tr(),
      subline: LocaleKeys.onboarding_slide3Subtitle.tr(),
      stageBuilder: (BuildContext context, Animation<double> anim) {
        return AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[anim, _twinkle]),
          builder: (BuildContext context, Widget? child) {
            final double v = anim.value;
            final double sceneOp = OnboardingMotion.scene.transform(v).clamp(0.0, 1.0);
            final double sceneScale = 0.9 + 0.1 * sceneOp;
            final double windowOpacity = OnboardingMotion.window.transform(v).clamp(0.0, 1.0) * 0.96;

            final List<double> starOpacities = List<double>.generate(4, (int i) {
              final double appear = _p(OnboardingMotion.starsAppear[i], v);
              final double shimmer = 0.65 + 0.35 * math.sin(_twinkle.value * 2 * math.pi + i * 0.8);
              return appear * shimmer.clamp(0.0, 1.0);
            });

            return Opacity(
              opacity: sceneOp,
              child: Transform.scale(
                scale: sceneScale,
                child: CustomPaint(
                  size: const Size(320, 280),
                  painter: NightHousePainter(windowOpacity: windowOpacity, starOpacities: starOpacities),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
