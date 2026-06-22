# Wait, Did I? — UI / Architecture Reference

Single source of truth for design tokens, composition rules, localization and code style,
read by the `create-feature-full`, `create-feature-ui` and `create-widget` skills.

> **Product guardrails first.** This is a calm **memory-aid** utility (see `PLAN.md`). UI must
> stay flat and quiet: NO glow / blur / gradients / neon, NO alarming red, NO gamification.
> Max "warning" is a soft yellow ("worth a look"). Microinteractions short and gentle.

---

## § 1 — Design System

### 1.1 Colors

Tokens are generated from Figma JSON and accessed via theme context:

```dart
final ColorTokens color = context.currentTokens.color;
```

**Files:** `core_ui/lib/theme/generate/tokens.g.dart` (auto-generated, do not edit by hand) —
source JSON in `core_ui/lib/theme/generate/tokens/`. Provider: `core_ui/lib/theme/theme_provider.dart`
(re-exported via `app_theme.dart`) — implements `AppTheme.of(context)` and the
`context.currentTokens` extension. Convention: pull `context.currentTokens.color` into a local
at the top of `build()`.

**Palette: «спокойный голубой» (calm blue).** Light + dark are real, separate themes.

**Color token names (real, from `ColorTokens`):**

| Group | Tokens | Note |
|---|---|---|
| Background | `colorBackgroundPrimary` (scaffold), `colorBackgroundSurface` (cards), `colorBackgroundSecondary`, `colorBackgroundElevated` | light: bg `#F4F7F9`, card `#FFFFFF` |
| Brand | `colorBrandCoral` (the **accent**, `#5A9BD4` blue), `colorBrandMint`, `colorBrandLavender`, `colorBrandOcean`, `colorBrandPeach` | ⚠️ names are legacy slots; **`colorBrandCoral` is the calm-blue accent**, not coral |
| State | `colorStateSuccess` (`#68C58F`), `colorStateWarning` (soft yellow `#E8B860`), `colorStateInfo`, `colorStateError` (muted `#E07A7A`) | error is intentionally soft — never alarm-red |
| Text | `colorTextPrimary` (`#2D3748`), `colorTextSecondary` (`#718096`), `colorTextTertiary`, `colorTextDisabled`, `colorTextInverse` | inverse = text on accent fills |
| Border / glass | `colorBorderDefault` (`#E2E8F0`), `colorBorderFocus`, `colorBorderGlass`, `colorGlassSurface`, `colorGlassBorder` | flat style ⇒ thin borders instead of shadows |

Other groups on `ITokens`: `textStyle` (`TextStyleTokens`, § 1.2) and `shadow` (`ShadowTokens` —
use sparingly; the design favours a thin 0.5px border over shadow).

**Rule:** NEVER hardcode `Color(0xFF…)` or `Colors.X` in widgets — always go through `ColorTokens`.
A missing semantic colour is added in the token JSON + regenerated, not patched into `.g.dart`.

### 1.2 Typography

```dart
final TextStyleTokens textStyle = context.currentTokens.textStyle;
Text('Готово', style: textStyle.body.copyWith(color: color.colorTextSecondary));
```

**Token names (real, from `TextStyleTokens`):**
`displayXl`, `display`, `headline`, `title`, `subtitle`, `bodyLarge`, `body`, `bodySmall`,
`caption`, `overline`, `button`.

**Fonts:** root `pubspec.yaml` bundles **Playfair Display** (600/700, display/headings) and
**Manrope** (400/500/600, body) from `core/resources/fonts/`. Do not set `fontFamily` manually in
features — consume `TextStyleTokens`; font is baked into the token styles.

### 1.3 Spacing — `AppDimens`

**File:** `core_ui/lib/theme/app_dimens.dart`. Plain **`const double`** constants — **NOT**
`flutter_screenutil` (no `.w/.r/.sp`, no `designSize`). Fixed logical pixels.

```dart
SizedBox(height: AppDimens.size16)
EdgeInsets.symmetric(horizontal: AppDimens.padding24)
BorderRadius.circular(AppDimens.borderRadius14)   // cards ~13–14
```

Families: `size0…size800` (incl. `size0_5`), `borderRadius0…borderRadius100`, `padding0…padding48`,
`margin4…margin24`, `opacity04…opacity8`, `thickness0_5/1/2`, `maxLines2/3`.

**Rule:** NEVER hardcode pixel literals (`16.0`, `EdgeInsets.all(24)`). Use `AppDimens`. Off-grid
value needed → add a constant following the existing naming, don't inline.

### 1.4 Icons & Images

**Wrap everything in `AppImage`** — don't use `SvgPicture.asset` / `Image.asset` directly.

```dart
AppImage(
  image: AppAssets.resourcesIconsOutlineGear,
  width: AppDimens.size24,
  height: AppDimens.size24,
  color: color.colorTextPrimary,   // becomes ColorFilter srcIn
)
```

`AppImage` (`core_ui/lib/widgets/app_image.dart`) auto-detects SVG/raster/network/file; supports
`color`, `borderRadius`, `fit`, `loader`. Asset constants live in `AppAssets`
(`core_ui/lib/assets_gen/assets.gen.dart`, FlutterGen, re-exported by `core_ui.dart`). Icons are a
single **outline** set (`AppAssets.resourcesIconsOutline…` — e.g. `…OutlineGear`, `…OutlinePlus`,
`…OutlineHouse`). One contour set, one weight — do not mix outline + filled. Regenerate with
`fluttergen` after adding assets to `core/resources/icons/`.

### 1.5 Available UI primitives

Everything in `core_ui/lib/widgets/` (barrel: `widgets/widgets.dart`, re-exported by `core_ui.dart`).
This kit was ported from a sibling project and **flattened to our calm style** — it is GENERIC only.
There are **no domain widgets** (no match/player-card/achievement/season/medal/premium/mascot).

| Widget | File | Notes |
|---|---|---|
| `AppScaffold` | `scaffold/app_scaffold.dart` | `body`, `title`, `actions`, `leading`, `showBackButton` (default true), `showAppBar`, `onBack`, `backgroundColor`, `bottomNavigationBar`, `floatingActionButton`, `floatingActionButtonLocation` |
| `CustomAppBar` | `scaffold/custom_app_bar.dart` | rendered by `AppScaffold` |
| `AppButton` | `buttons/app_button.dart` | `style` (`AppButtonStyle {primary, secondary, error, text}`), `size` (`AppButtonSize {large 52, medium 48, small 42}`), `text`, `icon`, `isLoading`, `isDisabled`, `isExpanded`, `onPressed` |
| `AppCircleButton` | `buttons/app_circle_button.dart` | `style` (`AppCircleButtonStyle.primary`…), `icon`, `onPressed` — used as FAB |
| `AppInputField` | `input_fields/app_input_field.dart` | controller, hint, error, clear button, prefix/suffix |
| `AppSearchField` | `input_fields/app_search_field.dart` | dedicated search input (use this, not InputField + icon) |
| `AppBioField` | `input_fields/app_bio_field.dart` | multiline |
| `AppCodeInput` | `input_fields/app_code_input.dart` | OTP/PIN (pinput) |
| `BaseBottomSheet` | `modals/base_bottom_sheet.dart` | rounded-top sheet + drag handle (flat, no blur) |
| `BaseDialogWidget` | `modals/base_dialog.dart` | `title`, `subTitle`, `content`, `actionButtons` (flat surface, no blur) |
| `SegmentedTabBar` / `AppLineTabBar` / `HorizontalChipTabs` / `StickyChipTabsHeader` | `tabs/` | tab bars; tab models simplified to id + label |
| `AppBottomNavBar` | `navigation/app_bottom_nav_bar.dart` | simplified — `AppBottomNavItem` on `IconData`, **no animated center FAB** |
| `ToastWidget` | `toast/toast_widget.dart` | `ToastType {success, error, warning, info}` |
| `BaseContextMenu` (+ `ContextMenuItem`, `ContextMenuModel`) | `context_menu/` | on Material `PopupMenuButton` |
| `SectionHeader`, `SettingsTile`, `SettingsTileSection` | root | settings/list building blocks |
| `StatCard` | `stat_card.dart` | flat (no gradient / animated count) |
| `ShimmerBox` | `shimmer_box.dart` | skeleton primitive |
| `AppLoader`, `BouncingDotsLoader` | root | loaders |
| `AppImage` | `app_image.dart` | see § 1.4 |

Also in `core`: `HapticService` (`package:core/core.dart` → `service/haptic_service.dart`) for
gentle haptic feedback on taps.

**Empty / error UX** — there is no shared mascot/empty-state widget. Build a small, calm centred
block (icon in a soft `colorBackgroundSecondary` tile + title + subtitle) — see
`features/lib/home/widgets/home_empty_state.dart` as the reference. No alarm colours.

### 1.6 Theme + light/dark

`AppThemeProvider` (`theme_provider.dart`) holds the current `ITokens`; boots with `LightTokens()`
in `lib/app.dart`. `LightTokens` and `DarkTokens` are **distinct real themes**.

```dart
context.currentTokens;        // ITokens (.color / .textStyle / .shadow)
context.isDarkTheme;          // bool
context.toggleTheme();        // flip light↔dark
context.switchTheme(true);    // force dark
```

For 1.0 the product ships **light only** (dark exists in tokens, optional). Always consume tokens,
never hardcode, so dark lands without touching widgets.

---

## § 2 — Composition Rules

### 2.1 Screen → Form split (with constructor-injected deps)

Every feature screen is two files. The **Screen** is a thin `BlocProvider` shell that resolves
dependencies from `appLocator` and passes them into the **cubit constructor**; the **Form** owns
layout. (This is the project convention — see `CLAUDE.md`. Deps are NOT pulled via `Service.instance`
inside the cubit.)

```dart
// features/lib/onboarding/screen/onboarding_screen.dart (real code)
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingCubit>(
      create: (BuildContext context) => OnboardingCubit(
        onboardingService: appLocator<OnboardingService>(),
      ),
      child: const OnboardingForm(),
    );
  }
}
```

A cubit with no deps is just `create: (_) => HomeCubit()..init()`. No route annotations on screens —
routing lives in `navigation/` (§ 4.7).

### 2.2 Form owns layout under a `BlocBuilder`

```dart
// *_form.dart
class HomeForm extends StatelessWidget {
  const HomeForm({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;
    final TextStyleTokens textStyle = context.currentTokens.textStyle;

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (BuildContext context, HomeState state) {
        final HomeCubit cubit = context.read<HomeCubit>();
        return AppScaffold(
          title: Text(LocaleKeys.home_greeting.tr(),
              style: textStyle.title.copyWith(color: color.colorTextPrimary)),
          body: /* … */,
        );
      },
    );
  }
}
```

Use `BlocConsumer` / `BlocListener` only for one-shot side effects.

### 2.3 Widget files & extraction

- **One public widget per file.** Small private helpers may co-locate when used only there.
- Short private `Widget _buildX(...)` helpers inside a Form are acceptable (see `home_form._buildBody`).
  Once a sub-tree is reused or the Form gets hard to scan → extract a widget into the feature's
  `widgets/` folder.
- **Feature-local** widgets → `features/lib/{feature}/widgets/`.
- **Shared / design-system** widgets → `core_ui/lib/widgets/`, exported from the `widgets.dart` barrel.

### 2.4 Feature folder structure (REQUIRED)

```
features/lib/{name}/
├── cubit/
│   ├── {name}_cubit.dart        # Cubit<State>, deps via constructor, part '{name}_state.dart';
│   └── {name}_state.dart        # part of …; Equatable + copyWith + props
├── screen/
│   ├── {name}_screen.dart       # StatelessWidget + BlocProvider, resolves appLocator<Dep>()
│   └── {name}_form.dart         # layout under BlocBuilder
└── widgets/                     # optional, feature-local pieces
```

Export the new `*_screen.dart` from `features/lib/features.dart` (alphabetical) — `navigation/`
imports screens through it. Real features today: `onboarding`, `home`, `settings`, `example`
(scaffold reference), `showcase` (dev-only core_ui gallery).

### 2.5 Child widgets & cubit access

Child widgets read the cubit inside their own `build()` via `context.read<Cubit>()` /
`BlocBuilder`. Don't thread `cubit`/`state` through constructors when the child is under the same
`BlocProvider`. Pure `core_ui` widgets take plain data + callbacks instead.

---

## § 3 — Localization (REQUIRED)

`easy_localization` (re-exported by `package:core/core.dart`), two locales: `en-US` and `ru-RU`.

- **No hardcoded user-facing strings** — even placeholders. Every visible string is
  `LocaleKeys.<key>.tr()`.
- Keys are generated and type-safe in `core/lib/localization/locale_keys.g.dart`. Namespace by
  feature: `onboarding.*`, `home.*`, `settings.*`, shared in `common.*`.
- Add each key to **BOTH** `core/resources/translations/en-US.json` AND `ru-RU.json`, then regenerate:

```bash
cd core && dart run easy_localization:generate \
  -f keys -o locale_keys.g.dart -O lib/localization -S resources/translations
```

```dart
import 'package:core/core.dart';
Text(LocaleKeys.home_emptyTitle.tr())
```

**Tone in copy** — follow the product voice (calm, conversational, light exhale): «Готово, дверь
отмечена», «Осталось глянуть 2 пункта». No «anxiety», no medical wording (see `STORE_CONTENT_BRIEF.md`).

---

## § 4 — Code Style

### 4.1 Hard rules
- **Explicit types everywhere** (`always_specify_types: true`) — `final ColorTokens color = …;`,
  `children: <Widget>[…]`, `(BuildContext context) =>`.
- **Named parameters** for any class with 2+ params; all fields named.
- **Comments / logs / exceptions in English.**
- **Line width 120**, `trailing_commas: preserve`.
- **Relative imports** within a module; `package:` imports across modules
  (`package:core/core.dart`, `package:core_ui/core_ui.dart`).
- **File suffixes:** `*_model.dart`, `*_dto.dart`, `*_mapper.dart`, `*_state.dart`,
  `*_cubit.dart`, `*_screen.dart`, `*_form.dart`.

### 4.2 Models (`domain/lib/models/{feature}/`)

Freezed, `*Model` suffix, immutable.

```dart
@freezed
abstract class ChecklistModel with _$ChecklistModel {
  const factory ChecklistModel({
    required String id,
    required String title,
    @Default(<ChecklistItemModel>[]) List<ChecklistItemModel> items,
    DateTime? createdAt,
  }) = _ChecklistModel;

  const ChecklistModel._();   // add only when the model needs methods/getters

  factory ChecklistModel.fromJson(Map<String, dynamic> json) => _$ChecklistModelFromJson(json);
}
```

### 4.3 DTOs (`data/lib/dto/{feature}/`)

Freezed + json_serializable, `*Dto` suffix, **plain `fromJson`** (this app is local-first — there
is **no `fromFirestore`**). Use `@Default(...)` only for non-nullable fields. See
`data/lib/dto/example/example_dto.dart` as the reference.

### 4.4 BLoC State (`*_state.dart` as `part of '*_cubit.dart'`)

`extends Equatable`, manual `copyWith`, `props` lists **all** fields. Loading is plain bool flags
(`isLoading`) — no status enums. Derived values are computed getters. Non-nullable simple fields get
defaults; complex models are `required`.

```dart
class HomeState extends Equatable {
  final bool isLoading;
  final List<ChecklistModel> lists;
  const HomeState({this.isLoading = false, this.lists = const <ChecklistModel>[]});
  bool get hasLists => lists.isNotEmpty;
  HomeState copyWith({bool? isLoading, List<ChecklistModel>? lists}) => HomeState(
        isLoading: isLoading ?? this.isLoading,
        lists: lists ?? this.lists,
      );
  @override
  List<Object?> get props => <Object?>[isLoading, lists];
}
```

### 4.5 Cubits — constructor injection, navigation via router

```dart
class HomeCubit extends Cubit<HomeState> {
  final ChecklistService _service;
  HomeCubit({required ChecklistService service}) : _service = service, super(const HomeState());

  void onSettingsPressed() =>
      appLocator<AppRouter>().router.push(RouterConstants.settingsRoute);
}
```

- Dependencies (services/repositories) come in through the **constructor**; the Screen resolves them
  from `appLocator<Dep>()` (§ 2.1).
- Navigation goes through `appLocator<AppRouter>().router` — **never** `BuildContext` navigation,
  no router stored as a field at module level.

### 4.6 Data access — LOCAL-FIRST (no Firestore / Cloud Functions)

This app keeps everything **on-device**. Target persistence for 1.0 is **Hive** (+
`flutter_secure_storage` for sensitive bits). There is **no Firestore, no Cloud Functions, no
GraphQL**. The layered pattern (mirrors the `example` feature):

```
provider (data/lib/providers/…)  →  repository impl (data/lib/repositories/…)  →  mapper  →  model
        interface in domain/lib/repositories/ ; service in domain/lib/service/
```

- **Providers** wrap a concrete source (local store / Hive box; the bundled `example` uses a Dio
  `ApiProvider` placeholder — do not assume a network backend exists).
- **Repositories**: interface in `domain/lib/repositories/`, impl in `data/lib/repositories/`,
  return domain models, throw a domain `AppException`.
- **Mappers**: `abstract class … { static Model toModel(Dto dto) … }` — pure functions, no state
  (`data/lib/mappers/{name}_mapper.dart`).
- **DI**: register interface→impl (and the domain service) in `data/lib/di/data_di.dart` via the
  GetIt `appLocator`. App-wide DI/scopes live in `core/lib/di/app_di.dart`.

> ⚠️ Any code that sends data off the device requires explicit discussion (privacy by default — see
> `PLAN.md`). Don't add a network/cloud layer casually.

### 4.7 Navigation — go_router (NO codegen)

Router in `navigation/lib/src/app_router/` — `AppRouter` wraps a `GoRouter`. Paths/names are
constants in `RouterConstants` (`RouterConstants.homeRoute = '/home'`, `onboardingRoute`,
`settingsRoute`, …). First-run gate redirects to `/onboarding` until `OnboardingService` flag is set.

```dart
appLocator<AppRouter>().router.go(RouterConstants.homeRoute);
appLocator<AppRouter>().router.push(RouterConstants.settingsRoute);
appLocator<AppRouter>().router.pop();
```

Add a route: add a constant to `RouterConstants` + a `GoRoute` in `app_router.dart`. No `.gr.dart`,
no build_runner for routing.

### 4.8 Codegen, analyze, format

```bash
# freezed / json_serializable / hive — run in each affected module (domain, data, core)
dart run build_runner build --delete-conflicting-outputs
fluttergen                      # after adding assets to core/resources/
# localization keys — see § 3
flutter analyze
dart format --line-length=120 core core_ui data domain features lib navigation
```

No FVM — the project uses Dart workspaces (FVM doesn't support them); use plain `flutter` / `dart`.
Both `analyze` and `format` must pass before commit.
