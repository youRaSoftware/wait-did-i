import 'dart:ui';

import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

/// Glass card that encourages the user as they check items. Its text changes
/// with progress (good start → almost there → all done).
class BottomHint extends StatelessWidget {
  const BottomHint({super.key, required this.checkedCount, required this.total});

  final int checkedCount;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;
    final int remaining = total - checkedCount;

    final String title = checkedCount >= total
        ? LocaleKeys.home_hintTitleDone.tr()
        : (checkedCount <= 1 ? LocaleKeys.home_hintTitleStart.tr() : LocaleKeys.home_hintTitleAlmost.tr());
    final String sub = remaining <= 0
        ? LocaleKeys.home_hintSubDone.tr()
        : (remaining == 1
              ? LocaleKeys.home_hintSubOne.tr()
              : LocaleKeys.home_hintSubMany.tr(namedArgs: <String, String>{'count': '$remaining'}));

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.colorBackgroundSurface.withValues(alpha: 0.75),
            border: Border.all(color: color.colorBrandPeach.withValues(alpha: 0.15)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.colorStateSuccess,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: color.colorStateSuccess.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.check_rounded, size: 16, color: color.colorBackgroundPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color.colorTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      sub,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: color.colorTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
