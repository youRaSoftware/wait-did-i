import 'package:flutter/material.dart';

import '../onboarding_colors.dart';

/// The slide-3 night scene. Reference viewBox 320×280 (draw at that aspect).
/// [windowOpacity] fades the warm window in; [starOpacities] (4) drive the twinkle.
class NightHousePainter extends CustomPainter {
  const NightHousePainter({required this.windowOpacity, required this.starOpacities});

  final double windowOpacity;
  final List<double> starOpacities;

  static const List<Offset> _starPos = <Offset>[
    Offset(60, 40),
    Offset(240, 55),
    Offset(280, 90),
    Offset(40, 80),
  ];
  static const List<double> _starRadius = <double>[1.5, 1.2, 1.0, 1.3];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 320, size.height / 280);

    // Stars.
    for (int i = 0; i < _starPos.length; i++) {
      final double o = i < starOpacities.length ? starOpacities[i] : 0.0;
      if (o <= 0) continue;
      canvas.drawCircle(_starPos[i], _starRadius[i], Paint()..color = Colors.white.withValues(alpha: o));
    }

    // Crescent moon (base + subtractive overlay matching the bg).
    canvas.drawCircle(
      const Offset(260, 40),
      20,
      Paint()..color = OnboardingColors.textPrimary.withValues(alpha: 0.85),
    );
    canvas.drawCircle(const Offset(252, 36), 20, Paint()..color = OnboardingColors.bgSecondary);

    // House silhouette.
    final Path house = Path()
      ..moveTo(80, 250)
      ..lineTo(80, 130)
      ..lineTo(160, 70)
      ..lineTo(240, 130)
      ..lineTo(240, 250)
      ..close();
    canvas.drawPath(
      house,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[OnboardingColors.houseTop, OnboardingColors.bgSecondary],
        ).createShader(const Rect.fromLTWH(80, 70, 160, 180)),
    );
    canvas.drawPath(
      house,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = OnboardingColors.brandBlueLight.withValues(alpha: 0.2),
    );

    // Warm window (fades in).
    if (windowOpacity > 0) {
      const Rect windowRect = Rect.fromLTWH(135, 160, 50, 50);
      final RRect windowR = RRect.fromRectAndRadius(windowRect, const Radius.circular(4));
      canvas.drawRRect(
        windowR,
        Paint()
          ..shader = RadialGradient(
            colors: <Color>[
              OnboardingColors.windowGlowTop.withValues(alpha: windowOpacity),
              OnboardingColors.stateWarning.withValues(alpha: windowOpacity),
            ],
          ).createShader(windowRect),
      );
      final Paint mullion = Paint()
        ..color = const Color(0xFF2D3748).withValues(alpha: 0.5 * windowOpacity)
        ..strokeWidth = 1;
      canvas.drawLine(const Offset(160, 160), const Offset(160, 210), mullion);
      canvas.drawLine(const Offset(135, 185), const Offset(185, 185), mullion);
    }

    // Door + handle.
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(148, 215, 24, 35), const Radius.circular(2)),
      Paint()..color = OnboardingColors.bgPrimary,
    );
    canvas.drawCircle(const Offset(167, 232), 1.5, Paint()..color = OnboardingColors.brandBlueLight);

    // Ground line.
    canvas.drawLine(
      const Offset(0, 250),
      const Offset(320, 250),
      Paint()
        ..color = OnboardingColors.brandBlueLight.withValues(alpha: 0.15)
        ..strokeWidth = 1,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(NightHousePainter oldDelegate) =>
      oldDelegate.windowOpacity != windowOpacity || oldDelegate.starOpacities != starOpacities;
}
