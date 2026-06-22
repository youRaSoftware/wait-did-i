import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Draws a check mark scaled to fill the given size. Used by the done-card
/// check and the polaroid stamp.
class CheckMarkPainter extends CustomPainter {
  const CheckMarkPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path path = Path()
      ..moveTo(size.width * 0.14, size.height * 0.54)
      ..lineTo(size.width * 0.40, size.height * 0.80)
      ..lineTo(size.width * 0.88, size.height * 0.20);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CheckMarkPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Dashed circular border for a "pending" checklist item.
class DashedCirclePainter extends CustomPainter {
  const DashedCirclePainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashLength = 3,
    this.gapLength = 3,
  });

  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (size.shortestSide - strokeWidth) / 2;
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final double circumference = 2 * math.pi * radius;
    final double step = dashLength + gapLength;
    final int dashes = (circumference / step).floor().clamp(1, 1000);
    final double sweep = (dashLength / circumference) * 2 * math.pi;
    final double gap = (step / circumference) * 2 * math.pi;

    for (int i = 0; i < dashes; i++) {
      final double start = i * gap;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DashedCirclePainter oldDelegate) => oldDelegate.color != color;
}
