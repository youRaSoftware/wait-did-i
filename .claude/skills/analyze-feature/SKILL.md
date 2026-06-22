---
name: analyze-feature
description: "RVACH Flutter project skill for deep-diving into an existing feature and producing a comprehensive architecture document. Triggers when user asks to: analyze a feature, проанализируй фичу, document feature architecture, создай документацию по фиче, опиши архитектуру, сделай полное описание фичи, describe what's implemented, what's the current state of feature X, расскажи что сделано в фиче, restore context for a feature, нужен контекст по фиче. The output is a detailed markdown file saved to .claude/my_docs/{feature_name}.md that serves as a complete context restoration document. Use this skill whenever the user wants to understand the current state of any feature, even if they don't say 'analyze' explicitly — phrases like 'what do we have for predictions?', 'напомни что там с лидербордом', 'что сейчас в лигах?', 'расскажи про матчи' or 'что там с профилем?' should also trigger this skill."
argument-hint: "[feature_name]"
---

# Analyze Feature — Generate Architecture Document

This skill produces a comprehensive markdown document describing every layer of an existing feature in the codebase. The document serves as a **context restoration tool** — anyone reading it should be able to fully understand the feature's current state, architecture decisions, and what remains to be done.

## Why this matters

When working on a feature across multiple sessions, context is lost. These documents eliminate that problem — they capture the exact state of implementation with file paths, field names, widget props, Firestore collections, and user flows so that work can resume instantly.

## Process

### Step 1: Identify the feature scope

Ask the user if unclear, or infer from the feature name. Determine:
- The feature's root directory in `features/lib/` (e.g., `features/lib/predictions/`, `features/lib/leaderboard/`, `features/lib/leagues/`)
- Related domain models in `domain/lib/models/{feature}/`
- Related data layer files (DTOs, mappers, repository impls, Hive providers)
- Any shared widgets in `core_ui/` (see `.claude/shared/ui_reference.md` for the widget/token inventory)

### Step 2: Systematically scan all layers

Read files in this order — this ensures you build understanding bottom-up:

**Domain layer:**
- `domain/lib/models/{feature}/` — all freezed model files, note every field, defaults, business logic methods declared in the freezed class body (private-constructor pattern), e.g. `PredictionModel.calculatePoints`
- `domain/lib/models/enums/` — enums with values and serialization pattern
- `domain/lib/repositories/` — repository interfaces for this feature (`Future` getters + `Stream watch...` methods)
- `domain/lib/service/` — singleton service facades (`XService.instance`, `ValueNotifier` caches, cross-cubit shared state)

**Data layer:**
- `data/lib/dto/{feature}/` — freezed DTOs, note `@Default()`, `@JsonKey`, the `fromFirestore` factory, `@TimestampConverter()` and `sanitizeFirestoreNumbers` usage (`data/lib/dto/converters/`)
- `data/lib/mappers/{name}_mapper.dart` — static `toModel` / `toDto` / `toFirestore` methods
- `data/lib/repositories/{name}_repository_impl.dart` — Firestore collections/queries, real-time `snapshots()` streams, `package:http` calls to Cloud Functions (`https://europe-west1-rvach-app.cloudfunctions.net/...`), `AppException` mapping, `retryOnTransientFirestoreError` usage
- `data/lib/providers/hive/` — hive_ce providers if the feature has local prefs (currently only onboarding / team selection)
- `data/lib/di/data_di.dart` — DI registration (which scope: `preLoginScope()` / `postLoginScope()`)
- `functions/src/index.ts` — if the feature depends on server-side logic: relevant `onRequest` endpoints, `onSchedule` jobs, Firestore triggers

**Presentation layer:**
- `features/lib/{path}/cubit/{name}_state.dart` — state fields, copyWith (`ValueGetter` for nullables), computed getters
- `features/lib/{path}/cubit/{name}_cubit.dart` — stream subscriptions, `_safeEmit` guard, `FirestoreLifecycleManager` registration, all methods
- `features/lib/{path}/screen/{name}_screen.dart` — route params, BlocProvider setup
- `features/lib/{path}/screen/{name}_form.dart` — layout structure, state handling
- `features/lib/{path}/widgets/` — every widget file, noting props, layout, animation details

**Navigation:**
- `navigation/lib/src/app_router/router_constants.dart` — route path/name constants
- `navigation/lib/src/app_router/app_router.dart` — `GoRoute` registration (top-level or inside a `StatefulShellBranch`), path/query param parsing
- `navigation/lib/src/app_router/dialog.dart` / `bottom_sheet.dart` — if the feature opens dialogs/sheets via `AppRouter` extensions

**Localization:**
- `core/resources/translations/ru-RU.json` and `en-US.json` — keys for this feature
- `core/lib/localization/locale_keys.g.dart` — corresponding constants

**Entry points:**
- Search for where this feature's route is opened from (grep for the `RouterConstants.*Route` constant, `appLocator<AppRouter>().router.go/push`, and `context.push` with the path)

### Step 3: Write the document

Use the template below as the reference format. If feature docs already exist in `.claude/my_docs/`, match their level of detail. For widget and design-token naming, cross-check `.claude/shared/ui_reference.md`.

The document structure adapts to what exists — include sections only for layers that are present. A feature without server-side logic won't have a Cloud Functions section; a feature without local prefs won't have a Hive section.

#### Document template

```markdown
# {Feature Name} — Full Architecture & Mechanics

## Overview
Brief description. Key capabilities as bullet list.
Entry points (how users reach this feature).

---

## 1. Backend (Firestore & Cloud Functions, if used)
Firestore collections touched (reads/writes/streams) and relevant security rules.
Table for Cloud Functions calls: Function | Type (onRequest/trigger/schedule) | Description.
Composite indexes the feature relies on (firestore.indexes.json).

---

## 2. Domain Layer

### Models
For each model: file path, all fields with types and defaults, business logic methods declared in the freezed class body (private-constructor pattern).

### Enums
Enum name, values, serialization pattern.

### Repository Interface
Methods with signatures (Future getters and Stream watchers).

### Service (if exists)
Singleton pattern (`XService.instance`), ValueNotifier caches, key methods.

---

## 3. Data Layer (if exists)

### DTOs
File paths, fields, @Default/@JsonKey annotations, `fromFirestore` factory,
TimestampConverter / sanitizeFirestoreNumbers usage.

### Mappers
Static toModel/toDto/toFirestore methods, any special conversion logic.

### Repository Implementation
Firestore queries and snapshots() streams (collection names, doc id schemes, .limit()),
http calls to Cloud Functions, AppException mapping, retry wrappers.

### Hive Providers (if applicable)
Entity, adapter, what is cached locally and why.

### DI Registration
Which scope (preLoginScope/postLoginScope in data_di.dart), registration style.

---

## 4. Localization
JSON keys added (show the actual JSON block, both ru-RU and en-US).
Locale key constants (show the dart constants).

---

## 5. State Management

### State class
File path. All fields with types and defaults.
copyWith method details (ValueGetter for nullable fields).
Computed getters.

---

## 6. Cubit
File path. Constructor params (usually none — singletons grabbed directly).

### Subscriptions & Lifecycle
Which service/repository streams it subscribes to.
FirestoreLifecycleManager registration (onPause/onResume), _safeEmit guard.

### Methods table
Table: Method | Trigger | Description
Cover every public and significant private method.

---

## 7. Screen & Navigation
Screen file: route params, BlocProvider setup.
RouterConstants constant + GoRoute registration in app_router.dart
(top-level route or which StatefulShellBranch).
Path/query parameter parsing (state.pathParameters / state.uri.queryParameters).
Dialogs/bottom sheets opened via AppRouter extensions.
Entry points (which cubits/screens navigate here).

---

## 8. Form
Layout structure — what's the top-level widget (AppScaffold or plain Scaffold), how states are handled.
Controllers owned (PageController, ScrollController, AnimationController, TabController, etc.).
Loading skeletons and MascotMessage empty/error states.

---

## 9. Widgets

### Folder Structure
Show the tree of widget files.

### Per widget
For each significant widget:
- File path
- StatelessWidget vs StatefulWidget (and why if stateful)
- Props (field order: required → defaults → nullable → key)
- Layout description (what's the widget tree, key containers, spacing)
- Animation mechanics if any
- Interaction handling

---

## 10. User Flow
ASCII flow diagrams showing step-by-step user journeys.
Separate flows for distinct scenarios (e.g., "Making a prediction" vs "Viewing results").

---

## 11. Key File Index
Tables grouping files by layer:
- Data Layer (file | purpose)
- Domain Layer (file | purpose)
- Presentation Layer (file | purpose)
- Modified/Reused Files (file | change)
- Reused Widgets & Utilities (widget | file)

---

## 12. Feature Flags & Stubs (if applicable)
Flags in core/lib/constants/feature_flags.dart affecting this feature
(e.g., premiumGatingEnabled).
Any mock/placeholder data still active and what real source should replace it.

---

## 13. Not Yet Implemented
Bullet list of TODOs, stubs, and missing functionality.
Use strikethrough for items that have been implemented since initial planning.
```

### Step 4: Save the document

Write to `.claude/my_docs/{feature_name}.md` where `feature_name` is snake_case (e.g., `predictions.md`, `leaderboard.md`, `match_detail.md`).

## Important guidelines

- **Be exhaustive about file paths** — every file mentioned should have its full path from project root. This is critical for context restoration.
- **Include actual field names and types** — don't summarize "it has several fields", list them all.
- **Firestore details matter** — collection names, doc id schemes (e.g., `'${userId}_$matchId'`), query limits, and whether reads are one-shot or `snapshots()` streams.
- **Widget props matter** — list every prop with its type. Someone reading this doc should be able to understand the widget's API without opening the file.
- **Layout descriptions should be spatial** — describe what's at the top, bottom, left, right. Mention specific padding values, sizes, colors when they're architecturally significant (e.g., `AppDimens.padding16`, `colors.whiteWhite`, `colors.grey1a`).
- **User flow should be step-by-step** — use `→` arrows showing the exact sequence of actions and state changes.
- **Don't skip "boring" parts** — DI registration, barrel exports, localization keys, `FirestoreLifecycleManager` registration. These are often the things people forget and need most.
