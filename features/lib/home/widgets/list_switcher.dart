import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

/// Pill-style segment control. A single active pill slides continuously, tracking
/// the [pageController]'s position — so it follows the swipe smoothly, with no
/// per-tab cross-fade flicker. Tapping a tab is handled by the parent (it glides
/// the page over, which the pill then follows).
class ListSwitcher extends StatelessWidget {
  const ListSwitcher({
    super.key,
    required this.lists,
    required this.activeIndex,
    required this.pageController,
    required this.onTap,
  });

  final List<ChecklistModel> lists;
  final int activeIndex;
  final PageController pageController;
  final ValueChanged<int> onTap;

  /// Live (fractional) page position; falls back to [activeIndex] before the
  /// controller is attached.
  double get _page {
    if (pageController.hasClients) {
      final double? page = pageController.page;
      if (page != null) return page.clamp(0.0, (lists.length - 1).toDouble());
    }
    return activeIndex.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;
    final int count = lists.length;

    return Container(
      decoration: BoxDecoration(
        color: color.colorTextPrimary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double pillWidth = constraints.maxWidth / count;
          return AnimatedBuilder(
            animation: pageController,
            builder: (BuildContext context, Widget? child) {
              final double page = _page;
              return Stack(
                children: <Widget>[
                  // Sliding active pill, behind the labels.
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: page * pillWidth,
                    width: pillWidth,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: color.colorBackgroundSurface,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: List<Widget>.generate(count, (int i) {
                      // 1 when the pill sits under this tab, fading to 0 as it slides away.
                      final double t = (1 - (page - i).abs()).clamp(0.0, 1.0);
                      return Expanded(
                        child: AppTappable(
                          haptic: AppHaptic.selection,
                          enableScale: false,
                          onTap: () => onTap(i),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(lists[i].emoji, style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Text(
                                  lists[i].shortName,
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color.lerp(color.colorTextSecondary, color.colorTextPrimary, t),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
