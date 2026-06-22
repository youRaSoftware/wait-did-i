import 'dart:math' as math;
import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../widgets/onboarding_colors.dart';
import '../widgets/onboarding_motion.dart';
import '../widgets/painters/check_mark_painter.dart';
import 'onboarding_slide_frame.dart';

/// Slide 1 — three checklist cards fall from the top and settle into a stack.
class SlideFallingCards extends StatelessWidget {
  const SlideFallingCards({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return OnboardingSlideFrame(
      isActive: isActive,
      stageTop: 160,
      stageHeight: 280,
      headline: LocaleKeys.onboarding_slide1Title.tr(),
      subline: LocaleKeys.onboarding_slide1Subtitle.tr(),
      stageBuilder: (BuildContext context, Animation<double> anim) {
        return SizedBox(
          width: 280,
          height: 240,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              _FallingCard(
                anim: anim,
                interval: OnboardingMotion.card1,
                top: 10,
                left: 10,
                startRotDeg: -15,
                endRotDeg: -3,
                done: false,
                text: 'Front door',
                muted: true,
              ),
              _FallingCard(
                anim: anim,
                interval: OnboardingMotion.card2,
                top: 75,
                left: 18,
                startRotDeg: 8,
                endRotDeg: 0,
                done: true,
                text: 'Stove off',
                hasPhoto: true,
              ),
              _FallingCard(
                anim: anim,
                interval: OnboardingMotion.card3,
                top: 140,
                left: 6,
                startRotDeg: -10,
                endRotDeg: 2.5,
                done: true,
                text: 'Windows closed',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FallingCard extends StatelessWidget {
  const _FallingCard({
    required this.anim,
    required this.interval,
    required this.top,
    required this.left,
    required this.startRotDeg,
    required this.endRotDeg,
    required this.done,
    required this.text,
    this.muted = false,
    this.hasPhoto = false,
  });

  final Animation<double> anim;
  final Interval interval;
  final double top;
  final double left;
  final double startRotDeg;
  final double endRotDeg;
  final bool done;
  final String text;
  final bool muted;
  final bool hasPhoto;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: AnimatedBuilder(
        animation: anim,
        builder: (BuildContext context, Widget? child) {
          final double span = interval.end - interval.begin;
          final double p = ((anim.value - interval.begin) / span).clamp(0.0, 1.0);
          final double eob = Curves.easeOutBack.transform(p);
          final double y = -400 * (1 - eob);
          final double rot = (startRotDeg + (endRotDeg - startRotDeg) * eob) * math.pi / 180;
          final double opacity = (p / 0.6).clamp(0.0, 1.0);
          return Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, y),
              child: Transform.rotate(angle: rot, alignment: Alignment.topCenter, child: child),
            ),
          );
        },
        child: _cardBody(),
      ),
    );
  }

  Widget _cardBody() {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[
          BoxShadow(color: Colors.black.withValues(alpha: 0.4), offset: const Offset(0, 24), blurRadius: 48),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: OnboardingColors.bgSurface.withValues(alpha: 0.7),
              border: Border.all(color: OnboardingColors.brandBlueLight.withValues(alpha: 0.15)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: <Widget>[
                _CardCheck(done: done),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      fontWeight: muted ? FontWeight.w400 : FontWeight.w500,
                      color: muted ? OnboardingColors.textSecondary : OnboardingColors.textPrimary,
                    ),
                  ),
                ),
                if (hasPhoto)
                  const Opacity(
                    opacity: 0.5,
                    child: Text('📷', style: TextStyle(fontSize: 14)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardCheck extends StatelessWidget {
  const _CardCheck({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    if (done) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(color: OnboardingColors.stateSuccess, shape: BoxShape.circle),
        child: const Center(
          child: CustomPaint(
            size: Size(13, 11),
            painter: CheckMarkPainter(color: OnboardingColors.bgPrimary, strokeWidth: 2),
          ),
        ),
      );
    }
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        foregroundPainter: DashedCirclePainter(color: Colors.white.withValues(alpha: 0.25)),
        child: Container(
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), shape: BoxShape.circle),
        ),
      ),
    );
  }
}
