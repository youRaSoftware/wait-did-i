import 'package:flutter/animation.dart';

/// Animation curves + timings for the onboarding, transcribed from
/// `.claude/specs/onboarding/reference.html`. Each slide runs one [AnimationController] of
/// [slideDuration]; individual elements play on [Interval]s of it.
abstract final class OnboardingMotion {
  /// Spring with overshoot — cards, polaroid, stamp, dots. The character curve.
  static const Curve dropCurve = Curves.easeOutBack;

  /// Smooth fade / translate — text, progress, scene.
  static const Curve fadeCurve = Curves.easeOutCubic;

  /// Total length of a single slide's intro animation.
  static const Duration slideDuration = Duration(milliseconds: 2500);

  static const Duration pageTransition = Duration(milliseconds: 500);

  /// Build an [Interval] from absolute seconds (start + duration) over [slideDuration].
  static Interval _at(double startSec, double durSec, {Curve curve = Curves.linear}) {
    const double total = 2.5;
    final double begin = (startSec / total).clamp(0.0, 1.0);
    final double end = ((startSec + durSec) / total).clamp(0.0, 1.0);
    return Interval(begin, end, curve: curve);
  }

  // Shared text-area timings (all slides).
  static final Interval title = _at(1.2, 0.6, curve: fadeCurve);
  static final Interval subtitle = _at(1.4, 0.6, curve: fadeCurve);

  // Slide 1 — falling cards.
  static final Interval card1 = _at(0.3, 0.7, curve: dropCurve);
  static final Interval card2 = _at(0.5, 0.7, curve: dropCurve);
  static final Interval card3 = _at(0.7, 0.7, curve: dropCurve);

  // Slide 2 — polaroid.
  static final Interval polaroid = _at(0.4, 0.9, curve: dropCurve);
  static final Interval developPhoto = _at(1.0, 1.0, curve: fadeCurve);
  static final Interval developDoor = _at(1.2, 1.0, curve: fadeCurve);
  static final Interval stamp = _at(1.5, 0.4); // shaped by TweenSequence in the slide
  static final Interval caption = _at(1.7, 0.5, curve: fadeCurve);

  // Slide 3 — night house.
  static final Interval scene = _at(0.3, 1.0, curve: fadeCurve);
  static final Interval window = _at(1.0, 1.5, curve: fadeCurve);
  static final List<Interval> starsAppear = <Interval>[
    _at(0.8, 0.5),
    _at(1.0, 0.5),
    _at(1.2, 0.5),
    _at(1.4, 0.5),
  ];
}
