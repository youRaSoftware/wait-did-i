import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'splash_colors.dart';

/// The "WAIT, DID I..?" wordmark that assembles, holds, then scatters.
///
/// Driven by a single [progress] in [0,1] (the splash controller's value):
///  - 0.00–0.30  letters fade + drop into place, staggered left→right
///  - 0.30–0.45  hold, fully assembled
///  - 0.45–1.00  each glyph flies off on its own vector, spins and fades out
class SplashWordmark extends StatelessWidget {
  const SplashWordmark({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final List<String> chars = LocaleKeys.splash_wordmark.tr().split('');
    final Size screen = MediaQuery.sizeOf(context);
    // Far enough that every glyph clears the screen before it fades.
    final double travel = screen.longestSide * 1.15;

    final int glyphCount = chars.where((String c) => c.trim().isNotEmpty).length;

    int order = -1;
    final List<Widget> letters = <Widget>[];
    for (int i = 0; i < chars.length; i++) {
      final String char = chars[i];
      if (char.trim().isEmpty) {
        letters.add(const SizedBox(width: 16));
        continue;
      }
      order++;
      letters.add(
        _SplashLetter(
          char: char,
          order: order,
          glyphCount: glyphCount,
          progress: progress,
          travel: travel,
          // The trailing "..?" glows in brand blue for a touch of personality.
          accent: i >= chars.length - 3,
        ),
      );
    }

    return Row(mainAxisSize: MainAxisSize.min, children: letters);
  }
}

/// A single glyph that computes its own assemble + scatter transform from
/// [progress]. Pure function of (progress, order) — deterministic, no random,
/// so the burst looks identical every launch.
class _SplashLetter extends StatelessWidget {
  const _SplashLetter({
    required this.char,
    required this.order,
    required this.glyphCount,
    required this.progress,
    required this.travel,
    required this.accent,
  });

  final String char;
  final int order;
  final int glyphCount;
  final double progress;
  final double travel;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final int denom = math.max(glyphCount - 1, 1);
    final double frac = order / denom; // 0 (leftmost) .. 1 (rightmost)

    // --- Assemble (≈0.00 → 0.31), staggered left→right. ---
    final double appearStart = frac * 0.15;
    final double appearEnd = appearStart + 0.16;
    final double aRaw = ((progress - appearStart) / (appearEnd - appearStart)).clamp(0.0, 1.0);
    final double aFade = Curves.easeOutCubic.transform(aRaw);
    final double aPop = Curves.easeOutBack.transform(aRaw);
    final double dropY = (1 - aFade) * 26.0; // drops into place from above

    // --- Scatter (≈0.45 → 1.00), tiny per-glyph ripple. ---
    final double scatterStart = 0.45 + frac * 0.05;
    final double sRaw = ((progress - scatterStart) / (1 - scatterStart)).clamp(0.0, 1.0);
    final double sAccel = sRaw * sRaw; // accelerate outward
    final double sFade = Curves.easeIn.transform(((sRaw - 0.05) / 0.7).clamp(0.0, 1.0));

    // Per-glyph direction: outward horizontally, varied vertically.
    final double dirX = (frac - 0.5) * 2.0; // -1 (left) .. 1 (right)
    final double dirY = math.cos(order * 1.9) * 0.85 - 0.25; // mostly up, some down
    final double len = math.sqrt(dirX * dirX + dirY * dirY) + 1e-4;
    final double speed = 0.85 + _frac01(order * 0.37) * 0.6; // some travel farther
    final double dist = sAccel * travel * speed;
    final Offset scatter = Offset(dirX / len * dist, dirY / len * dist);

    final double angle = (dirX * 0.9 + dirY * 0.5) * sAccel * 1.4;
    final double scale = (0.7 + aPop * 0.3) * (1 + sAccel * 0.35);
    final double opacity = (aFade * (1 - sFade)).clamp(0.0, 1.0);

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(scatter.dx, scatter.dy + dropY),
        child: Transform.rotate(
          angle: angle,
          child: Transform.scale(
            scale: scale,
            child: Text(
              char,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 40,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1.0,
                color: accent ? SplashColors.brandBlueLight : SplashColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

double _frac01(double x) => x - x.floorToDouble();
