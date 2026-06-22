import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import 'checklist_item.dart';
import 'home_progress_line.dart';

/// The body of the active list: title, status line, an (animated-in) progress
/// bar once something is checked, and the scrollable items.
class ChecklistView extends StatelessWidget {
  const ChecklistView({super.key, required this.list, required this.onItemTap});

  final ChecklistModel list;
  final ValueChanged<String> onItemTap;

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;
    final bool checking = list.checkedCount > 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 22),
          Text(
            list.name,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: color.colorTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _status(),
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color.colorTextSecondary,
            ),
          ),
          const SizedBox(height: 22),
          // Progress bar grows in on the first check.
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: checking
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: HomeProgressLine(progress: list.progress),
                  )
                : const SizedBox(width: double.infinity),
          ),
          ...list.items.map(
            (ChecklistItemModel item) => ChecklistItem(item: item, onTap: () => onItemTap(item.id)),
          ),
          const SizedBox(height: 140),
        ],
      ),
    );
  }

  String _status() {
    if (list.checkedCount > 0) {
      return LocaleKeys.home_checkedCount.tr(
        namedArgs: <String, String>{'done': '${list.checkedCount}', 'total': '${list.total}'},
      );
    }
    final DateTime? at = list.lastChecked;
    if (at == null) return LocaleKeys.home_notCheckedYet.tr();
    return LocaleKeys.home_lastChecked.tr(namedArgs: <String, String>{'time': _relative(at)});
  }

  String _relative(DateTime at) {
    final Duration d = DateTime.now().difference(at);
    if (d.inMinutes < 1) return LocaleKeys.home_justNow.tr();
    if (d.inMinutes < 60) {
      return LocaleKeys.home_minutesAgo.tr(namedArgs: <String, String>{'count': '${d.inMinutes}'});
    }
    if (d.inHours < 24) {
      return LocaleKeys.home_hoursAgo.tr(namedArgs: <String, String>{'count': '${d.inHours}'});
    }
    return LocaleKeys.home_daysAgo.tr(namedArgs: <String, String>{'count': '${d.inDays}'});
  }
}
