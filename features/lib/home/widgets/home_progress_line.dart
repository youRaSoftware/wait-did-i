import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

/// Thin checklist progress bar. [progress] is 0.0..1.0; the fill animates.
class HomeProgressLine extends StatelessWidget {
  const HomeProgressLine({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: color.colorTextPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(2),
      ),
      child: AnimatedFractionallySizedBox(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        widthFactor: progress.clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: <Color>[color.colorBrandPeach, color.colorBrandCoral]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
