import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'onboarding_colors.dart';

/// White high-contrast CTA pill with a trailing arrow. Light press-scale + haptic.
class OnboardingCtaButton extends StatefulWidget {
  const OnboardingCtaButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<OnboardingCtaButton> createState() => _OnboardingCtaButtonState();
}

class _OnboardingCtaButtonState extends State<OnboardingCtaButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: () {
        HapticService.mediumImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            color: OnboardingColors.textPrimary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(widget.label, style: OnboardingText.cta),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 16, color: OnboardingColors.bgPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
