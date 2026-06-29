import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Haptic intensity fired when an [AppTappable] is tapped.
enum AppHaptic {
  /// No haptic feedback.
  none,

  /// Light impact — list items, tiles, icon buttons.
  light,

  /// Medium impact — primary buttons / actions.
  medium,

  /// Heavy impact — destructive or important actions.
  heavy,

  /// Selection click — toggles, tabs, segmented controls.
  selection,
}

/// Wraps any widget with the app's standard tap response: a light press-in
/// scale ("squeeze") animation plus haptic feedback.
///
/// This is the single source of truth for tap feedback across the app — use it
/// instead of a bare [GestureDetector] for anything tappable.
///
/// * Pass `onTap: null` to disable it: no scale, no haptic, no callback.
/// * For selection controls (tabs, segmented bars) that run their own selection
///   animation, set [enableScale] to `false` and use [AppHaptic.selection] so
///   the press scale doesn't fight that animation.
class AppTappable extends StatefulWidget {
  /// Widget made tappable.
  final Widget child;

  /// Tap callback. When `null`, the widget is disabled (no feedback, no call).
  final VoidCallback? onTap;

  /// Haptic intensity fired on tap.
  final AppHaptic haptic;

  /// Whether to play the press-in scale animation. Disable for selection
  /// controls that animate their own selection state.
  final bool enableScale;

  /// Scale applied while pressed (1.0 == no shrink).
  final double pressedScale;

  /// Press/release animation duration.
  final Duration duration;

  /// Press/release animation curve.
  final Curve curve;

  /// Hit-test behavior of the underlying [GestureDetector].
  final HitTestBehavior behavior;

  const AppTappable({
    required this.child,
    this.onTap,
    this.haptic = AppHaptic.light,
    this.enableScale = true,
    this.pressedScale = 0.95,
    this.duration = const Duration(milliseconds: 100),
    this.curve = Curves.easeOut,
    this.behavior = HitTestBehavior.opaque,
    super.key,
  });

  bool get _isEnabled => onTap != null;

  @override
  State<AppTappable> createState() => _AppTappableState();
}

class _AppTappableState extends State<AppTappable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enableScale || !widget._isEnabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleTap() {
    if (!widget._isEnabled) return;
    switch (widget.haptic) {
      case AppHaptic.none:
        break;
      case AppHaptic.light:
        HapticService.lightImpact();
      case AppHaptic.medium:
        HapticService.mediumImpact();
      case AppHaptic.heavy:
        HapticService.heavyImpact();
      case AppHaptic.selection:
        HapticService.selectionClick();
    }
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;

    if (widget.enableScale) {
      child = AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: widget.duration,
        curve: widget.curve,
        child: child,
      );
    }

    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget._isEnabled ? _handleTap : null,
      child: child,
    );
  }
}
