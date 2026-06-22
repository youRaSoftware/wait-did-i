import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

/// Brand-gradient FAB that opens the (future) add-list flow.
class AddFab extends StatelessWidget {
  const AddFab({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;
    return GestureDetector(
      onTap: () {
        HapticService.lightImpact();
        onTap();
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[color.colorBrandPeach, color.colorBrandOcean],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(color: color.colorBrandCoral.withValues(alpha: 0.4), blurRadius: 28, offset: const Offset(0, 12)),
          ],
        ),
        child: const Icon(Icons.add, size: 24, color: Colors.white),
      ),
    );
  }
}
