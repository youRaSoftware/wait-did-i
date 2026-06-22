---
name: create-widget
description: "RVACH Flutter project skill for creating a NEW reusable UI widget/component in core_ui/lib/widgets/. Triggers when user asks to: create a widget, make a component, сделать виджет, создать компонент, build a reusable button/card/modal/input/tab bar/label/badge/chip/bottom sheet/search field — for the shared design system. Creates: StatelessWidget or StatefulWidget in core_ui with proper design tokens, composition rules, and barrel export. Do NOT trigger when user asks to create a full feature with screens (use create-feature-ui or create-feature-full), asks for data-layer work (DTO/mapper/repository/Firestore), or asks to fix/modify an existing widget."
argument-hint: "[widget_name] [category]"
---

# Create Reusable Widget

Use when: creating a new reusable UI component in `core_ui/lib/widgets/`.

## REQUIRED READING — do this BEFORE generating any code

Read **`.claude/shared/ui_reference.md`** in full. It contains the design system (colors, typography, spacing, icons), composition rules, localization API, and code style — all of which apply to every widget. Do not skip this step. Do not paraphrase from memory. The file is the source of truth and may have been updated since this skill was last loaded.

## Template

```
Create a reusable widget: {widget_name}
Category: {buttons / input_fields / modals / scaffold / tabs / navigation / match / player_card / achievement / season / competition / context_menu / empty_state / offline / toast}
Description: {what it does, variants, where it's used}

Follow RVACH widget patterns.
```

## Location

`core_ui/lib/widgets/{category}/{widget_name}.dart`

Simple standalone widgets that don't fit an existing category may live directly at `core_ui/lib/widgets/{widget_name}.dart` (existing examples: `stat_card.dart`, `shimmer_box.dart`, `section_header.dart`, `app_image.dart`). Only create a new category folder when 2+ related widgets justify it.

Add an export entry to `core_ui/lib/widgets/widgets.dart`. Reference existing widgets in the same category before introducing a new one — duplicates are easy to create and hard to remove.

## Naming

- Prefix with `App` for general-purpose widgets that consumers compose into screens: `AppButton`, `AppCircleButton`, `AppInputField`, `AppSearchField`, `AppImage`, `AppBottomNavBar`, `AppLineTabBar`.
- Prefix with `Base` for fundamental scaffolding intended to be wrapped: `BaseDialogWidget` (`modals/base_dialog.dart`), `BaseBottomSheet`, `BaseContextMenu`.
- Domain / situation-specific widgets drop the prefix when the name is unambiguous: `MatchPointsBadge`, `PlayerCard`, `MascotMessage`, `StatCard`, `ShimmerBox`, `SegmentedTabBar`.

Enums attached to a widget go in the same file, declared **before** the widget class (see `AppButtonStyle` / `AppButtonSize` in `buttons/app_button.dart`).

## Widget Structure

Fields BEFORE constructor. Parameter order: required → non-nullable with default → nullable → `super.key`. Imports: `package:flutter/material.dart` + relative `../../core_ui.dart` (brings in tokens, `AppDimens`, `AppImage`); `package:core/core.dart` only when you need `LocaleKeys`, `HapticService`, etc.

```dart
/// Visual variant of the stat tile.
enum AppStatTileType {
  /// Standard, full-width tile with rounded corners.
  standard,

  /// Compact tile for dense lists.
  compact,
}

/// Reusable stat tile used across the leaderboard and statistics tabs.
class AppStatTile extends StatelessWidget {
  // === Fields — ALWAYS before constructor ===

  // 1. Required (ordered by significance)
  final String title;
  final VoidCallback onTap;

  // 2. Non-nullable with default (ordered by significance)
  final AppStatTileType type;
  final bool isDisabled;

  // 3. Nullable (ordered by significance)
  final String? subtitle;
  final Color? backgroundColorOverride;

  // Constructor — same order
  const AppStatTile({
    required this.title,
    required this.onTap,
    this.type = AppStatTileType.standard,
    this.isDisabled = false,
    this.subtitle,
    this.backgroundColorOverride,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.currentTokens.color;
    final TextStyleTokens textStyles = context.currentTokens.textStyle;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: EdgeInsets.all(AppDimens.padding16),
        decoration: BoxDecoration(
          color: backgroundColorOverride ?? colors.grey1a,
          borderRadius: BorderRadius.circular(AppDimens.borderRadius16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: textStyles.headings16pxBlack.copyWith(color: isDisabled ? colors.white52 : colors.whiteWhite),
            ),
            if (subtitle != null) ...<Widget>[
              SizedBox(height: AppDimens.size4),
              Text(
                subtitle!,
                style: textStyles.texts12pxRegular.copyWith(color: colors.white52),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

**Gotcha**: `AppDimens` values are flutter_screenutil getters (`16.w`, `8.r`, `16.sp`) — they can NEVER be wrapped in `const`. Write `EdgeInsets.all(AppDimens.padding16)`, `SizedBox(height: AppDimens.size8)` without `const`.

## Design System

See `.claude/shared/ui_reference.md` § 1 — Design System (colors, typography, spacing, icons & images). All widgets MUST:
- Consume colors via `context.currentTokens.color.*` (e.g. `colors.grey1a`, `colors.whiteWhite`, `colors.white52`, `colors.orangeAccentPrimary`, `colors.systemRed`) — never hardcode `Color(0xFF…)` or `Colors.X`.
- Consume typography via `context.currentTokens.textStyle.*` (`headings16pxBlack`, `texts12pxRegular`, …) — never set raw `TextStyle(fontSize:, fontWeight:)` for design-system text.
- Consume spacing/radii via `AppDimens.sizeN / paddingN / borderRadiusN` — never inline pixel literals.
- Wrap raster/vector assets in `AppImage` — never use `SvgPicture.asset()` / `Image.asset()` directly.
- Gradients and shadows also come from tokens: `context.currentTokens.gradient.*`, `context.currentTokens.shadow.*` (see `AppButton`'s primary glow).

The app currently ships a single dark palette (`LightTokens` and `DarkTokens` are identical); still go through tokens only — never bake the palette into the widget.

## SliverPersistentHeaderDelegate (when pinned sliver needed)

When a widget needs to stay pinned at the top of a `CustomScrollView`, create a `SliverPersistentHeaderDelegate` subclass and place it next to the widget it wraps. Real example — `core_ui/lib/widgets/tabs/sticky_chip_tabs_header.dart`, which pins `HorizontalChipTabs`:

```dart
/// [SliverPersistentHeaderDelegate] that pins a [HorizontalChipTabs] strip
/// to the top of a [CustomScrollView] while content scrolls beneath.
class StickyChipTabsHeader extends SliverPersistentHeaderDelegate {
  final List<ChipTabItem> items;
  final String selectedId;
  final ValueChanged<String> onSelected;
  final Color backgroundColor;

  StickyChipTabsHeader({
    required this.items,
    required this.selectedId,
    required this.onSelected,
    required this.backgroundColor,
  });

  @override
  double get minExtent => AppDimens.size48 + AppDimens.padding8 * 2;

  @override
  double get maxExtent => AppDimens.size48 + AppDimens.padding8 * 2;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      padding: EdgeInsets.symmetric(vertical: AppDimens.padding8),
      child: HorizontalChipTabs(items: items, selectedId: selectedId, onSelected: onSelected),
    );
  }

  @override
  bool shouldRebuild(StickyChipTabsHeader old) {
    return old.selectedId != selectedId ||
        old.items.length != items.length ||
        old.backgroundColor != backgroundColor;
  }
}
```

## Widget Type Selection

**`StatelessWidget`** (default) — buttons, cards, decorative layouts, anything driven entirely by props.

**`StatefulWidget`** — only when one of these is required:
- `AnimationController` (with `SingleTickerProviderStateMixin`).
- `TextEditingController` / `FocusNode` / `ScrollController` lifecycle owned by the widget.
- A small local toggle that has no business living in Cubit state (e.g. a transient expansion flag).

### Press-scale animation pattern (used by `AppButton`)

```dart
class _AppStatTileState extends State<AppStatTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // GestureDetector onTapDown → _controller.forward();
  // onTapUp → _controller.reverse() + HapticService.mediumImpact() + onPressed
  // onTapCancel → _controller.reverse(); wrap content in ScaleTransition.
}
```

`HapticService` (tap feedback) lives in `core/lib/service/haptic_service.dart`, exported via `package:core/core.dart`.

### BackdropFilter blur pattern (frosted glass — `AppButton` secondary, `BaseDialogWidget`)

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(AppDimens.borderRadius28),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
    child: container,
  ),
)
```

## Composition Rules

See `.claude/shared/ui_reference.md` § 2 — Composition Rules.

- **One public widget per file.** The filename is the snake_case of the widget name.
- Small **private helper widget classes are allowed** when they're used only by the host widget and stay in the same file (real examples: `_Digit` in `match/match_score_digits.dart`). Don't export them; don't grow them past a screenful.
- **No widget-returning methods** (`Widget _buildHeader()`, `List<Widget> _buildItems()`) — none exist in `core_ui/lib/widgets/`; keep it that way. Inline the tree in `build()` or extract a (private or public) widget class.
- If a piece of widget tree is **reused in 2+ places** → extract it as its own public widget file with a barrel export. Otherwise → inline it or keep it as a co-located private class.
- Put a `///` doc comment on every public widget — existing widgets document purpose and, where known, the Figma Design System name (`/// Universal button (design System name "Primare/Secondary CTA")`).

## UX States

| State    | Implementation                                                                          |
|----------|-----------------------------------------------------------------------------------------|
| Default  | Normal display                                                                          |
| Loading  | `isLoading` → `CircularProgressIndicator.adaptive` (buttons) / `ShimmerBox` (skeletons) |
| Disabled | `isDisabled` → suppress tap + disabled tokens (`white8` bg, `white16`/`white52` content)|
| Error    | `errorText` → border/caption via `colors.systemRed`                                     |

Every interactive widget that takes an `onTap` / `onPressed` MUST support the disabled state — designers expect tap suppression + visual feedback.

## Barrel export

After creating the widget, append an `export` line to `core_ui/lib/widgets/widgets.dart`:

```dart
// Cards
export 'stat_card.dart';
```

The file is organized into `// Category` comment sections in rough alphabetical order — add the export to the matching section or create a new one.

## After Creation

```bash
flutter analyze core_ui
dart format --line-length=120 core_ui/lib/widgets/{category}/
```

No build_runner step — `core_ui` widgets have no codegen (tokens and `AppAssets` are already generated and committed).

If the widget exposes built-in user-visible strings, add the keys to BOTH `core/resources/translations/ru-RU.json` and `en-US.json`, then regenerate:

```bash
cd core && dart run easy_localization:generate -f keys -o locale_keys.g.dart -O lib/localization -S resources/translations
```

## Localization

See `.claude/shared/ui_reference.md` § 3 — Localization. Widgets typically accept text as String props (so the consuming feature controls localization), but when a widget owns built-in copy, use `LocaleKeys` + `.tr()` from `package:core/core.dart` — real example in `match/match_points_badge.dart`:

```dart
label = LocaleKeys.predictions_card_zeroPoints.tr();
```

## Code Style

See `.claude/shared/ui_reference.md` § 4 — Code Style.
