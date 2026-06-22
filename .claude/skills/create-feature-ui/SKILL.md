---
name: create-feature-ui
description: "RVACH Flutter project skill for creating a UI feature with mock data when backend is NOT ready. Triggers when user asks to: build screens/UI, create a new feature, scaffold a feature, набросать экраны, создать фичу, сделать UI — AND there is no real data source mentioned (no Firestore collections / Cloud Functions / repositories) or user says backend is not ready / на моках / mock data / бэк не готов / API пока нет. Creates: domain model with mocks, state, cubit, screen, form, go_router route. Do NOT trigger when user asks to wire real data — Firestore collections, Cloud Functions, repositories (use create-feature-full instead), asks for a reusable widget (use create-widget), or asks to fix/refactor existing code."
argument-hint: "[feature_name] [description] [screens]"
---

# Create UI Feature (Mock Data)

Use when: backend is NOT ready (no Firestore collection, no Cloud Function, no repository yet) — build UI screens with mock data baked into domain models. When the real data lands, the cubit's `init()` switches from `Model.mocks` to a domain service and everything else stays.

## REQUIRED READING — do this BEFORE generating any code

Read **`.claude/shared/ui_reference.md`** in full. It contains the design system (colors, typography, spacing, icons), composition rules, localization API, and code style — all of which apply to every screen, form, and widget in this feature. Do not skip this step. Do not paraphrase from memory. The file is the source of truth and may have been updated since this skill was last loaded.

## Template

```
Create UI feature: {feature_name}
Description: {what it does}
Screens: {list of screens}

Follow RVACH UI feature patterns.
```

## 1. Domain Model (`domain/lib/models/{feature}/`)

`@freezed abstract class` named `*Model`, with `static const List<Model> mocks` embedded in the class. Requires `const Model._();` to enable static members and computed getters. No `fromJson`/`.g.dart` until the backend exists — only the `.freezed.dart` part.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'feature_item_model.freezed.dart';

@freezed
abstract class FeatureItemModel with _$FeatureItemModel {
  const factory FeatureItemModel({
    required String id,
    required String title,
    String? subtitle,
    String? imageUrl,
    @Default(false) bool isActive,
    @Default(0) int points,
  }) = _FeatureItemModel;

  const FeatureItemModel._();

  static const List<FeatureItemModel> mocks = <FeatureItemModel>[
    FeatureItemModel(id: '1', title: 'Item 1', subtitle: 'Description 1', points: 3),
    FeatureItemModel(id: '2', title: 'Item 2', subtitle: 'Description 2', isActive: true),
    // ...
  ];
}
```

Export from `domain/lib/models/models.dart` (it groups exports by feature with a `// Feature` comment header — follow the existing layout, e.g. `export 'season/season.dart';`).

## 2. State (`features/lib/{name}/cubit/{name}_state.dart`)

State is `part of '{name}_cubit.dart'`. Single Equatable class (no sealed states, no status enum) with boolean flags + manual `copyWith()`, `ValueGetter<T?>?` for nullable fields, all fields in `props`. The error field is named `errorMessage` (see `features/lib/statistics/cubit/statistics_state.dart`).

```dart
part of 'feature_cubit.dart';

class FeatureState extends Equatable {
  final bool isLoading;
  final List<FeatureItemModel> items;
  final String? errorMessage;

  const FeatureState({
    this.isLoading = false,
    this.items = const <FeatureItemModel>[],
    this.errorMessage,
  });

  FeatureState copyWith({
    bool? isLoading,
    List<FeatureItemModel>? items,
    ValueGetter<String?>? errorMessage,
  }) {
    return FeatureState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[isLoading, items, errorMessage];
}
```

Computed getters (filtered lists, totals, percentages) live on the state, not in the cubit — see `StatisticsState` for the canonical example.

## 3. Cubit (`features/lib/{name}/cubit/{name}_cubit.dart`)

**No router field, no constructor injection of services.** Route params come in as plain constructor fields; the initial state is `super(const FeatureState())`; data loads in `init()` (the screen calls `FeatureCubit(...)..init()`). Every cubit defines a `_safeEmit` guard against emit-after-close.

### Navigation patterns

- **Push / go / pop — `appLocator<AppRouter>().router`:** the go_router instance is resolved from GetIt at the call site, never stored as a field. `router.push('/match/$id')`, `router.go(RouterConstants.authRoute)`, `router.pop()` (real examples: `features/lib/leagues/cubit/leagues_cubit.dart`, `features/lib/statistics/cubit/statistics_cubit.dart:227`).
- **Dialogs — `showFullScreenDialog<T>()`:** extension on `AppRouter` in `navigation/lib/src/app_router/dialog.dart`. Takes `widget:`; the dialog widget composes `BaseDialogWidget` and closes itself via `appLocator<AppRouter>().pop(result)`.
- **Bottom sheets — `showBottomSheet<T>()`:** extension on `AppRouter` in `navigation/lib/src/app_router/bottom_sheet.dart`. Takes `contentWidget:`; the content widget wraps itself in `BaseBottomSheet` (see `features/lib/profile/widgets/language_bottom_sheet.dart`).
- From widgets, the plain go_router context API is also fine: `context.push('/match/${match.id}')` (see `features/lib/predictions/widgets/match_card.dart`).

`package:core/core.dart` re-exports flutter_bloc, equatable, `appLocator`, `AppRouter`, `RouterConstants` and `LocaleKeys` — one import covers all of them.

```dart
import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';

part 'feature_state.dart';

class FeatureCubit extends Cubit<FeatureState> {
  final String itemId; // route param, if the screen has one

  FeatureCubit({required this.itemId}) : super(const FeatureState());

  void _safeEmit(FeatureState next) {
    if (isClosed) return;
    emit(next);
  }

  Future<void> init() async {
    _safeEmit(state.copyWith(isLoading: true));

    // TODO(mock): replace with a domain service once Firestore/Functions are ready.
    await Future<void>.delayed(const Duration(milliseconds: 400));

    _safeEmit(state.copyWith(isLoading: false, items: FeatureItemModel.mocks));
  }

  void onItemTap(FeatureItemModel item) {
    appLocator<AppRouter>().router.push('/feature/${item.id}');
  }

  void onLikeChanged({required int index, required bool isLiked}) {
    final List<FeatureItemModel> updated = List<FeatureItemModel>.of(state.items);
    updated[index] = updated[index].copyWith(isActive: isLiked);
    _safeEmit(state.copyWith(items: updated));
  }

  Future<void> onDeleteTap(FeatureItemModel item) async {
    final bool? confirmed = await appLocator<AppRouter>().showFullScreenDialog<bool>(
      widget: const ConfirmDeleteDialog(),
    );
    if (confirmed != true) return;

    final List<FeatureItemModel> updated = List<FeatureItemModel>.of(state.items)..remove(item);
    _safeEmit(state.copyWith(items: updated));
  }

  void onBack() {
    appLocator<AppRouter>().router.pop();
  }
}
```

Later, when the backend lands, `init()` subscribes to a domain service stream and the cubit registers with `FirestoreLifecycleManager` — see `features/lib/statistics/cubit/statistics_cubit.dart` for that next step. Not needed at the mock stage.

## 4. Screen (`features/lib/{name}/screen/{name}_screen.dart`)

Plain `StatelessWidget` — **no annotations** (RVACH uses go_router, there is no `@RoutePage()` or codegen). Route params are public final fields. `BlocProvider` builds the cubit and kicks off `init()`.

```dart
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'feature_form.dart';

class FeatureScreen extends StatelessWidget {
  final String itemId;

  const FeatureScreen({
    required this.itemId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FeatureCubit>(
      create: (BuildContext context) => FeatureCubit(itemId: itemId)..init(),
      child: const FeatureForm(),
    );
  }
}
```

Real references: `features/lib/statistics/screen/statistics_screen.dart` (no params), `features/lib/tournament_detail/screen/tournament_detail_screen.dart` (with `leagueId` param).

## 5. Form (`features/lib/{name}/screen/{name}_form.dart`)

Tokens pulled at the top of `build`, `AppScaffold` shell, `BlocBuilder` body. Loading / error / empty / content states.

### 5a. Default — `StatelessWidget`

```dart
import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../widgets/feature_item_card.dart';

class FeatureForm extends StatelessWidget {
  const FeatureForm({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.currentTokens.color;
    final TextStyleTokens textStyles = context.currentTokens.textStyle;

    return AppScaffold(
      title: Text(
        context.tr(LocaleKeys.featureName_title),
        style: textStyles.headings18pxBlack.copyWith(color: colors.whiteWhite),
      ),
      applyTopPadding: true,
      onBack: context.read<FeatureCubit>().onBack,
      body: BlocBuilder<FeatureCubit, FeatureState>(
        builder: (BuildContext context, FeatureState state) {
          if (state.isLoading) {
            return const AppLoader();
          }

          final FeatureCubit cubit = context.read<FeatureCubit>();

          if (state.errorMessage != null) {
            return MascotMessage(
              mascotAsset: AppAssets.coreResourcesIconsWebpRvachMascotSad,
              message: state.errorMessage ?? context.tr(LocaleKeys.common_error),
              primaryAction: AppButton(
                onPressed: cubit.init,
                text: context.tr(LocaleKeys.common_retry),
              ),
            );
          }

          if (state.items.isEmpty) {
            return MascotMessage(
              mascotAsset: AppAssets.coreResourcesIconsWebpRvachMascotNoTournaments,
              message: context.tr(LocaleKeys.featureName_empty),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(AppDimens.size16),
            itemCount: state.items.length,
            separatorBuilder: (BuildContext context, int index) => SizedBox(height: AppDimens.size12),
            itemBuilder: (BuildContext context, int index) {
              final FeatureItemModel item = state.items[index];
              return FeatureItemCard(
                item: item,
                onTap: () => cubit.onItemTap(item),
              );
            },
          );
        },
      ),
    );
  }
}
```

Notes:
- `AppScaffold` (`core_ui/lib/widgets/scaffold/app_scaffold.dart`) params: `title` is a **Widget**, plus `showAppBar`, `showBackButton`, `applyTopPadding`, `onBack`, `actions`, `leading`, `backgroundColor`. The app-bar visibility switch is `showAppBar` (default `true`).
- Loading = `AppLoader` or a feature skeleton built from `ShimmerBox` (see `features/lib/predictions/widgets/match_list_skeleton.dart`) — keep the skeleton up until data lands to avoid empty-state flashes.
- Empty / error = `MascotMessage` (`core_ui/lib/widgets/empty_state/mascot_message.dart`): mascot webp + message + optional `AppButton` actions. Mascots: `AppAssets.coreResourcesIconsWebpRvachMascotSad|Prediction|NoTournaments|...`.
- Tab-root forms (screens that live in a `StatefulShellBranch`) may use a plain `Scaffold` + `SafeArea` instead of `AppScaffold` — see `features/lib/predictions/screen/predictions_form.dart`.
- `AppDimens` values are getters (screenutil-scaled), so **no `const`** in front of `EdgeInsets.all(AppDimens.size16)`.

### 5b. `StatefulWidget` — when the form owns a controller

Use this variant only when the form owns `TextEditingController`, `FocusNode`, `ScrollController`, `TabController`, or `AnimationController`. Otherwise stay `StatelessWidget`.

```dart
class FeatureForm extends StatefulWidget {
  const FeatureForm({super.key});

  @override
  State<FeatureForm> createState() => _FeatureFormState();
}

class _FeatureFormState extends State<FeatureForm> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FeatureCubit cubit = context.read<FeatureCubit>();

    return AppScaffold(
      applyTopPadding: true,
      showBackButton: false,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(AppDimens.size16),
            child: AppSearchField(
              controller: _searchController,
              hintText: context.tr(LocaleKeys.featureName_searchHint),
              onChanged: cubit.onSearchChanged,
            ),
          ),
          Expanded(
            child: BlocBuilder<FeatureCubit, FeatureState>(
              builder: (BuildContext context, FeatureState state) {
                // list / empty / skeleton — same as 5a
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

Input widgets live in `core_ui/lib/widgets/input_fields/`: `AppInputField` (universal text field), `AppSearchField` (search with cancel button), `AppBioField`, `AppCodeInput`. There is no `isSearch:` flag — search is its own widget.

## 6. Folder structure

The features module is **flat** — every feature is a top-level folder `features/lib/{feature_name}/`, whether it's a tab root (`predictions`, `leaderboard`, `leagues`, `profile`), a nested screen (`statistics`, `prediction_history`, `tournament_detail`) or a standalone flow (`auth`, `onboarding`, `team_selection`). There is no `tabs/` directory.

```
features/lib/{feature_name}/
├── cubit/
│   ├── {feature_name}_cubit.dart
│   └── {feature_name}_state.dart
├── screen/
│   ├── {feature_name}_form.dart
│   └── {feature_name}_screen.dart
└── widgets/
```

Example real paths: `features/lib/statistics/`, `features/lib/tournament_detail/`, `features/lib/quick_predictions/`.

Register the new screen + cubit in the barrel `features/lib/features.dart` (a `// Feature Name` comment followed by both exports, like the existing entries) — the router reaches screens through this barrel.

## 7. Widgets (`features/lib/{name}/widgets/`)

**Rule of thumb — one public widget per file, flat folder.** RVACH keeps `widgets/` flat (no subfolders, even at 15+ files — see `features/lib/predictions/widgets/`) and prefixes files with the feature name: `tournament_card.dart`, `prediction_match_card_header.dart`, `match_list_skeleton.dart`.

Extract to a separate file in `widgets/` when:
- the widget is reused in 2+ places inside the feature (reused **across** features → `core_ui/lib/widgets/` + barrel `widgets.dart`);
- the form grows past a screenful of distinct sections — the form should read as a composition of named sections (see `features/lib/statistics/screen/statistics_form.dart`: `StatisticsMainStatsRow`, `StatisticsPointsDistribution`, ...);
- the widget is a dialog/sheet content shown via `showFullScreenDialog`/`showBottomSheet` — those always get their own file (`logout_dialog.dart`, `language_bottom_sheet.dart`).

Small private helper widgets (`_Card`, `_SectionLabel`, `_EmptyState`) **may be co-located** in the same file below the public widget — that's the codebase norm (`statistics_form.dart`, `match_score_digits.dart`). Don't create a file for a 15-line helper.

### Data flow into child widgets

The dominant pattern: the form's `BlocBuilder` destructures state and passes **plain values + callbacks** into section widgets:

```dart
StatisticsMainStatsRow(
  totalPoints: state.totalPoints,
  accuracyPercentage: state.accuracyPercentage,
  averagePoints: state.averagePoints,
),
```

Widgets deeper in the tree that need cubit access may use `context.read<FeatureCubit>()` directly instead of threading callbacks. Controllers owned by a `StatefulWidget` parent are passed via constructor.

## 7a. Enums for tabs / filters (`domain/lib/enums/`)

When a feature has tabs or filter categories, create a plain enum in `domain/lib/enums/{name}.dart` and export it from `domain/lib/enums/enums.dart`:

```dart
enum FeatureTabType { all, active, archived }
```

Labels are resolved in the form via `switch` + `context.tr(...)` — RVACH does not store locale keys on enums (real example: `TournamentTabType` in `domain/lib/enums/tournament_tab_type.dart`, labelled in `features/lib/tournament_detail/screen/tournament_detail_form.dart`):

```dart
String tabLabel(FeatureTabType tab) {
  switch (tab) {
    case FeatureTabType.all:
      return context.tr(LocaleKeys.featureName_tabs_all);
    case FeatureTabType.active:
      return context.tr(LocaleKeys.featureName_tabs_active);
    case FeatureTabType.archived:
      return context.tr(LocaleKeys.featureName_tabs_archived);
  }
}
```

## 7b. Tabs

Tab widgets live in `core_ui/lib/widgets/tabs/` — pick by design:

- `SegmentedTabBar` — equal-width segmented strip (`labels` / `selectedIndex` / `onTabChanged`), for 2–3-way toggles;
- `AppLineTabBar` + `AppLineTabItem(id:, label:)` — underline tabs driven by a `TabController`;
- `HorizontalChipTabs` (+ `ChipTabItem`) — scrollable chips;
- `StickyChipTabsHeader` — a `SliverPersistentHeaderDelegate` for pinning chip tabs inside a `CustomScrollView`/`NestedScrollView`.

There is no `CustomTabBar` and no `tab_bar/` folder.

For swipeable tabs: the form is a `StatefulWidget` with `TickerProviderStateMixin` owning the `TabController`; the controller listener calls `cubit.onTabChanged(index)`, and the `BlocBuilder` re-syncs the controller (`animateTo`) when `state.selectedTabIndex` changes from the cubit side. Canonical implementations: `features/lib/predictions/screen/predictions_form.dart`, `features/lib/prediction_history/screen/prediction_history_form.dart`.

```dart
AppLineTabBar(
  controller: _tabController,
  items: <AppLineTabItem>[
    AppLineTabItem(id: 'all', label: context.tr(LocaleKeys.featureName_tabs_all)),
    AppLineTabItem(id: 'active', label: context.tr(LocaleKeys.featureName_tabs_active)),
  ],
),
Expanded(
  child: TabBarView(
    controller: _tabController,
    children: <Widget>[ /* one widget from widgets/ per tab */ ],
  ),
),
```

## 8. Route (go_router — no codegen)

Two files, both in `navigation/lib/src/app_router/`:

**a) Path constant** in `router_constants.dart`:

```dart
class RouterConstants {
  // ...
  static const String featureRoute = '/feature';
  static const String featureDetailRoute = '/feature/:itemId';
}
```

**b) `GoRoute`** in `app_router.dart`. Top-level (full-screen, outside the bottom-nav shell):

```dart
GoRoute(
  path: RouterConstants.featureDetailRoute,
  name: RouterConstants.featureDetailRoute,
  builder: (BuildContext context, GoRouterState state) {
    final String itemId = state.pathParameters['itemId']!;
    return FeatureDetailScreen(itemId: itemId);
  },
),
```

Or nested under a tab — add to the `routes:` of that branch's root `GoRoute` inside `StatefulShellRoute.indexedStack` with a **relative** path (pattern: `/profile/statistics`, `/leagues/:leagueId`):

```dart
GoRoute(
  path: 'feature', // resolves to /profile/feature
  name: RouterConstants.profileFeatureRoute,
  builder: (BuildContext context, GoRouterState state) => const FeatureScreen(),
),
```

Optional data goes through query params: `state.uri.queryParameters['name']` (see the team-detail route). That's it — no `.gr.dart`, nothing to regenerate.

## After Creation

```bash
# freezed codegen — domain only (features and navigation have no generated code)
cd domain && dart run build_runner build --delete-conflicting-outputs
```

If new locale keys were added — add them to BOTH `core/resources/translations/ru-RU.json` AND `en-US.json`, then regenerate:

```bash
cd core && dart run easy_localization:generate -f keys -o locale_keys.g.dart -O lib/localization -S resources/translations
```

Then:

```bash
flutter analyze features/lib/{feature_name}
dart format --line-length=120 features/lib/{feature_name} domain/lib/models/{feature_name} navigation/lib
```

Plain `flutter`/`dart` — the project is a Dart workspace, FVM is not supported here (see README "FVM Compatibility").

## Design System

See `.claude/shared/ui_reference.md` § 1 — Design System (colors, typography, spacing, icons & images). All UI MUST consume tokens via `context.currentTokens.color` / `context.currentTokens.textStyle` and sizes via `AppDimens.*`. NEVER use `SvgPicture.asset()` or `Image.asset()` directly — always wrap in `AppImage` with `AppAssets.*` constants.

## Composition Rules

See `.claude/shared/ui_reference.md` § 2 — Composition Rules. RVACH-specific summary:

- **One public widget per file**, file named after the widget, prefixed with the feature name.
- Small private helper widgets (`_Card`, `_EmptyState`) co-located below the public widget are fine — that's the codebase norm.
- Section-sized sub-trees, anything reused, and all dialog/sheet contents go to `widgets/` (flat, no subfolders). Cross-feature widgets go to `core_ui/lib/widgets/` + barrel export.
- The form should read as a composition of named sections fed plain values from `state`, not a monolithic 400-line `build()`.

## Localization

See `.claude/shared/ui_reference.md` § 3 — Localization. Use the feature's name as the JSON namespace in `ru-RU.json`/`en-US.json` (`"featureName": { "title": ... }` → `LocaleKeys.featureName_title`). RU is the primary/fallback locale — never add a key to only one file. Usage: `context.tr(LocaleKeys.featureName_title)` in widgets, `LocaleKeys.x.tr(args: ...)` in cubits.

## Code Style

See `.claude/shared/ui_reference.md` § 4 — Code Style.
