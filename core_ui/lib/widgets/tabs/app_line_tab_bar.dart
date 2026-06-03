import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';

/// Data model for a single line tab item.
class AppLineTabItem {
  final String id;
  final String label;

  const AppLineTabItem({
    required this.id,
    required this.label,
  });
}

/// Horizontally-scrollable tab bar with an animated underline indicator.
///
/// Two modes:
///   * **Internal controller** — pass [selectedId] + [onSelected]. The
///     widget owns a [TabController] and keeps it in sync with [selectedId].
///   * **External controller** — pass [controller] (e.g. shared with a
///     [TabBarView] for swipe gestures); the parent owns state.
class AppLineTabBar extends StatefulWidget {
  final List<AppLineTabItem> items;
  final TabController? controller;
  final String? selectedId;
  final ValueChanged<String>? onSelected;
  final EdgeInsets? padding;

  const AppLineTabBar({
    required this.items,
    this.controller,
    this.selectedId,
    this.onSelected,
    this.padding,
    super.key,
  });

  @override
  State<AppLineTabBar> createState() => _AppLineTabBarState();
}

class _AppLineTabBarState extends State<AppLineTabBar> with TickerProviderStateMixin {
  TabController? _internalController;

  TabController? get _activeController => widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _rebuildInternalController();
    }
  }

  @override
  void didUpdateWidget(covariant AppLineTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool wasExternal = oldWidget.controller != null;
    final bool isExternal = widget.controller != null;

    if (isExternal) {
      if (!wasExternal) {
        _internalController?.dispose();
        _internalController = null;
      }
      return;
    }

    final bool lengthChanged = oldWidget.items.length != widget.items.length;
    if (wasExternal || lengthChanged) {
      _rebuildInternalController();
      return;
    }

    final int newIndex = _resolveIndex(widget.selectedId);
    if (_internalController != null && _internalController!.index != newIndex) {
      _internalController!.animateTo(newIndex);
    }
  }

  void _rebuildInternalController() {
    _internalController?.dispose();
    _internalController = TabController(
      length: widget.items.length,
      vsync: this,
      initialIndex: _resolveIndex(widget.selectedId),
    );
  }

  int _resolveIndex(String? id) {
    if (id == null) return 0;
    final int idx = widget.items.indexWhere((AppLineTabItem i) => i.id == id);
    return idx < 0 ? 0 : idx;
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.currentTokens.color;
    final TextStyleTokens textStyles = context.currentTokens.textStyle;

    final TabController? controller = _activeController;
    if (controller == null || widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: AppDimens.size48,
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: AppDimens.padding12),
        labelPadding: const EdgeInsets.symmetric(horizontal: AppDimens.padding12),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: colors.colorBrandCoral,
        dividerColor: Colors.transparent,
        labelColor: colors.colorBrandCoral,
        unselectedLabelColor: colors.colorTextSecondary,
        labelStyle: textStyles.bodySmall,
        unselectedLabelStyle: textStyles.bodySmall,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        onTap: (int index) {
          HapticService.selectionClick();
          widget.onSelected?.call(widget.items[index].id);
        },
        tabs: widget.items
            .map(
              (AppLineTabItem item) => Tab(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
