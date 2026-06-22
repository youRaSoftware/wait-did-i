import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../widgets/onboarding_colors.dart';
import '../widgets/onboarding_motion.dart';
import '../widgets/painters/check_mark_painter.dart';
import '../widgets/painters/polaroid_door_painter.dart';
import 'onboarding_slide_frame.dart';

/// Slide 2 — a polaroid flies in; the photo "develops"; a check-stamp drops on.
class SlidePolaroid extends StatelessWidget {
  const SlidePolaroid({super.key, required this.isActive});

  final bool isActive;

  static double _p(Interval i, double v) => ((v - i.begin) / (i.end - i.begin)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return OnboardingSlideFrame(
      isActive: isActive,
      stageTop: 160,
      stageHeight: 320,
      headline: LocaleKeys.onboarding_slide2Title.tr(),
      subline: LocaleKeys.onboarding_slide2Subtitle.tr(),
      stageBuilder: (BuildContext context, Animation<double> anim) {
        return AnimatedBuilder(
          animation: anim,
          builder: (BuildContext context, Widget? child) {
            final double v = anim.value;

            final double eob = Curves.easeOutBack.transform(_p(OnboardingMotion.polaroid, v));
            final double translateY = -300 * (1 - eob);
            final double rotate = (-25 + 21 * eob) * math.pi / 180;
            final double scale = 0.6 + 0.4 * eob;
            final double wholeOpacity = (_p(OnboardingMotion.polaroid, v) / 0.7).clamp(0.0, 1.0);

            final double photoOp = _p(OnboardingMotion.developPhoto, v);
            final double doorOp = _p(OnboardingMotion.developDoor, v);

            // Stamp: overshoot scale + rotate.
            final double sp = _p(OnboardingMotion.stamp, v);
            final double stampOpacity = (sp / 0.6).clamp(0.0, 1.0);
            final double stampScale = sp < 0.6 ? 2 + (0.85 - 2) * (sp / 0.6) : 0.85 + (1 - 0.85) * ((sp - 0.6) / 0.4);
            final double stampRotDeg = sp < 0.6 ? 20 + (-8 - 20) * (sp / 0.6) : -8 + (-5 - -8) * ((sp - 0.6) / 0.4);

            final double captionP = _p(OnboardingMotion.caption, v);

            return Transform.translate(
              offset: Offset(0, translateY),
              child: Transform.rotate(
                angle: rotate,
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: wholeOpacity,
                    child: _polaroid(
                      photoOp: photoOp,
                      doorOp: doorOp,
                      stampOpacity: stampOpacity,
                      stampScale: stampScale,
                      stampRot: stampRotDeg * math.pi / 180,
                      captionOpacity: captionP,
                      captionDy: 20 * (1 - captionP),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _polaroid({
    required double photoOp,
    required double doorOp,
    required double stampOpacity,
    required double stampScale,
    required double stampRot,
    required double captionOpacity,
    required double captionDy,
  }) {
    return Container(
      width: 220,
      height: 258,
      decoration: BoxDecoration(
        color: OnboardingColors.polaroidPaper,
        borderRadius: BorderRadius.circular(4),
        boxShadow: <BoxShadow>[
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), offset: const Offset(0, 30), blurRadius: 60),
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), offset: const Offset(0, 10), blurRadius: 20),
        ],
      ),
      child: Stack(
        children: <Widget>[
          // Photo (196×196).
          Positioned(
            top: 12,
            left: 12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                width: 196,
                height: 196,
                child: Stack(
                  children: <Widget>[
                    Container(color: OnboardingColors.photoMid),
                    Opacity(
                      opacity: photoOp,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(-0.6, -0.9),
                            end: Alignment(0.6, 0.9),
                            colors: <Color>[Color(0xFF4A5568), OnboardingColors.photoMid, OnboardingColors.bgSecondary],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 58,
                      child: Opacity(
                        opacity: doorOp,
                        child: const CustomPaint(size: Size(80, 130), painter: PolaroidDoorPainter()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Stamp.
          Positioned(
            top: 24,
            right: 22,
            child: Opacity(
              opacity: stampOpacity,
              child: Transform.scale(
                scale: stampScale,
                child: Transform.rotate(
                  angle: stampRot,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: OnboardingColors.stateSuccess,
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: OnboardingColors.stateSuccess.withValues(alpha: 0.4),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: CustomPaint(
                        size: Size(26, 22),
                        painter: CheckMarkPainter(color: OnboardingColors.bgPrimary, strokeWidth: 3.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Caption.
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: captionOpacity,
              child: Transform.translate(
                offset: Offset(0, captionDy),
                child: Text(
                  LocaleKeys.onboarding_slide2PolaroidCaption.tr(),
                  textAlign: TextAlign.center,
                  style: OnboardingText.polaroidCaption,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
