import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

/// Top bar: a big greeting + sub-line (driven by time of day and checklist
/// state) and a settings button.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    super.key,
    required this.list,
    required this.allDoneFlash,
    required this.onSettings,
  });

  final ChecklistModel? list;
  final bool allDoneFlash;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;
    final (String greeting, String sub) = _texts();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                greeting,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  height: 1.1,
                  color: color.colorTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sub,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: color.colorTextTertiary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        AppTappable(
          onTap: onSettings,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.colorTextPrimary.withValues(alpha: 0.05),
              border: Border.all(color: color.colorTextPrimary.withValues(alpha: 0.08)),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: AppImage(
              image: AppAssets.resourcesIconsOutlineGear,
              width: 18,
              height: 18,
              color: color.colorTextSecondary,
            ),
          ),
        ),
      ],
    );
  }

  (String, String) _texts() {
    final ChecklistModel? l = list;
    if (l == null) {
      return (LocaleKeys.home_greetEmpty.tr(), LocaleKeys.home_subEmpty.tr());
    }
    if (allDoneFlash && l.allDone) {
      return (LocaleKeys.home_greetAllClear.tr(), LocaleKeys.home_subAllClear.tr());
    }
    if (l.isChecking) {
      return (LocaleKeys.home_greetChecking.tr(), LocaleKeys.home_subChecking.tr());
    }
    final int hour = DateTime.now().hour;
    if (hour >= 22 || hour < 5) {
      return (LocaleKeys.home_greetNight.tr(), LocaleKeys.home_subNight.tr());
    }
    if (hour < 12) {
      return (LocaleKeys.home_greetMorning.tr(), LocaleKeys.home_subMorning.tr());
    }
    if (hour < 17) {
      return (LocaleKeys.home_greetAfternoon.tr(), LocaleKeys.home_subAfternoon.tr());
    }
    return (LocaleKeys.home_greetEvening.tr(), LocaleKeys.home_subEvening.tr());
  }
}
