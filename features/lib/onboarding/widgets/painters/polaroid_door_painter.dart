import 'package:flutter/material.dart';

import '../onboarding_colors.dart';

/// The "developed" door illustration inside the polaroid. Reference viewBox 80×130.
/// Draw inside a box with the same aspect ratio (80:130).
class PolaroidDoorPainter extends CustomPainter {
  const PolaroidDoorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 80, size.height / 130);

    final Path door = Path()
      ..moveTo(12, 130)
      ..lineTo(12, 36)
      ..cubicTo(12, 18, 22, 8, 40, 8)
      ..cubicTo(58, 8, 68, 18, 68, 36)
      ..lineTo(68, 130)
      ..close();

    final Paint doorPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xCC7BB0DD), Color(0x994F86C6)], // brandBlueLight .8 / brandBlueDeep .6
      ).createShader(const Rect.fromLTWH(0, 0, 80, 130));
    canvas.drawPath(door, doorPaint);

    final Paint lockPaint = Paint()..color = OnboardingColors.polaroidPaper;
    canvas.drawCircle(const Offset(55, 78), 5, lockPaint);
    canvas.drawRect(const Rect.fromLTWH(53, 80, 4, 10), lockPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(PolaroidDoorPainter oldDelegate) => false;
}
