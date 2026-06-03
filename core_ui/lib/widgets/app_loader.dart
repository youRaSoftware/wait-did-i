import 'package:flutter/material.dart';

import 'bouncing_dots_loader.dart';

/// Centered loading indicator for the app. Uses [BouncingDotsLoader].
class AppLoader extends StatelessWidget {
  final Color? color;
  final double dotSize;

  const AppLoader({
    this.color,
    this.dotSize = 12,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BouncingDotsLoader(
        color: color,
        dotSize: dotSize,
      ),
    );
  }
}
