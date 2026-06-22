import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

/// One checklist row. The whole card is tappable (you poke it without looking).
/// Checked items soften: green tint, muted name, a timestamp instead of the hint.
class ChecklistItem extends StatelessWidget {
  const ChecklistItem({super.key, required this.item, required this.onTap});

  final ChecklistItemModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;
    final bool checked = item.isChecked;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: checked ? color.colorStateSuccess.withValues(alpha: 0.05) : color.colorBackgroundSurface,
          border: Border.all(
            color: checked
                ? color.colorStateSuccess.withValues(alpha: 0.15)
                : color.colorTextPrimary.withValues(alpha: 0.04),
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: <Widget>[
            _AnimatedCheckbox(isChecked: checked),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: checked ? color.colorTextTertiary : color.colorTextPrimary,
                    ),
                    child: Text(item.name),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _meta(context),
                    style: TextStyle(fontFamily: 'Manrope', fontSize: 12, color: color.colorTextTertiary),
                  ),
                ],
              ),
            ),
            if (item.hasPhoto) ...<Widget>[
              const SizedBox(width: 12),
              _PhotoThumbnail(color: color),
            ],
          ],
        ),
      ),
    );
  }

  String _meta(BuildContext context) {
    if (item.isChecked) {
      final DateTime? at = item.checkedAt;
      if (at == null) return '';
      final String time = TimeOfDay.fromDateTime(at).format(context);
      return item.hasPhoto ? '$time · ${LocaleKeys.home_withPhoto.tr()}' : time;
    }
    if (item.photoRecommended) return LocaleKeys.home_metaPhotoRecommended.tr();
    return LocaleKeys.home_tapToCheck.tr();
  }
}

class _AnimatedCheckbox extends StatelessWidget {
  const _AnimatedCheckbox({required this.isChecked});

  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;
    // NOTE: keep a non-overshoot curve here — this container animates a boxShadow,
    // and easeOutBack's <0 / >1 values make BoxShadow.lerp produce a negative blur
    // radius (runtime assertion). The "stamp" feel comes from the check icon fade.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isChecked ? color.colorStateSuccess : color.colorTextPrimary.withValues(alpha: 0.04),
        border: isChecked ? null : Border.all(color: color.colorTextPrimary.withValues(alpha: 0.22), width: 1.5),
        boxShadow: isChecked
            ? <BoxShadow>[
                BoxShadow(
                  color: color.colorStateSuccess.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isChecked ? 1 : 0,
        child: Icon(Icons.check_rounded, size: 16, color: color.colorBackgroundPrimary),
      ),
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  const _PhotoThumbnail({required this.color});

  final ColorTokens color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.colorBackgroundSecondary,
        border: Border.all(color: color.colorBrandPeach.withValues(alpha: 0.1)),
      ),
      child: Icon(Icons.photo_camera_outlined, size: 16, color: color.colorBrandPeach),
    );
  }
}
