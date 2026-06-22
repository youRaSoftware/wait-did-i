---
name: audit-section
description: "RVACH Flutter project skill for full pre-production audit of a feature section across all layers: vertical analysis (Cloud Functions → Firestore → Repository impl → DTO → Mapper → Model → Domain Service → Cubit → State → UI) PLUS horizontal analysis (duplicate logic, dead/useless code, suboptimal patterns, architecture questions). Triggers when user asks to: audit a section, аудит раздела, проверь раздел перед продом, audit before production, pre-release check, полный аудит фичи, проверь поток данных раздела, check section data flow correctness. User provides: feature path, technical documentation paths (.md/.pdf), and optionally a local doc path for results."
argument-hint: "<section_name> — docs: <path_to_docs> feature: <path_to_feature> [output: <path_to_local_doc>]"
---

# Audit Section — Full Pre-Production Audit

This skill performs a comprehensive audit of a feature section before production release. Think like a senior engineer with 10 years of experience in feature design.

**Two analysis dimensions:**
1. **Vertical analysis** (Steps 2-5) — trace the data chain through ALL layers: Cloud Functions (server-side sync from football-data.org), Firestore collections + security rules + indexes, Repository impl, DTO (Firestore converters), Mapper, Domain Model, Domain Service, Cubit, State, UI. Verify field completeness, query correctness, lifecycle safety, spec conformance.
2. **Horizontal analysis** (Steps 6-9) — compare the section against sibling implementations and best practices. Detect duplicate logic, dead code, suboptimal patterns, and raise questions about unclear architectural decisions.

## Why this matters

A single missed field in a mapper causes silent data loss on every `set()`. A compound Firestore query without a composite index throws `failed-precondition` only at runtime. A snapshot subscription that isn't registered with `FirestoreLifecycleManager` crashes on backgrounding (firebase-ios-sdk #10026). A client write that `firestore.rules` rejects produces `permission-denied` storms. A proxy service with zero value-add adds maintenance burden. Fetching all documents then filtering in Dart when a `.where()` query exists wastes reads and money. This audit catches ALL of these issues — both correctness bugs and engineering quality problems — systematically before they reach production.

## Required inputs

Before starting, ensure you have:
1. **Section name** — e.g., "Predictions", "Leaderboard", "Leagues", "MatchDetail"
2. **Feature path** — e.g., `features/lib/predictions/`
3. **Technical documentation** — paths to `.md` and/or `.pdf` spec files
4. **UI conventions reference** — always reference `@.claude/shared/ui_reference.md`
5. **Output doc path** (optional) — where to save audit results, e.g., `.claude/my_docs/predictions_audit.md`

If the user did not provide all required inputs, ask for them before proceeding.

## The RVACH vertical chain

```
football-data.org v4 → Cloud Functions (functions/src/index.ts: axios + onSchedule/onRequest/onDocument*) → Firestore
→ [app] RepositoryImpl (cloud_firestore snapshots/get, or http → onRequest function)
→ DTO.fromFirestore (sanitizeFirestoreNumbers + @TimestampConverter)
→ Mapper.toModel → freezed Domain Model → Domain Service singleton (ValueNotifier cache)
→ Cubit (stream subscriptions, _safeEmit, FirestoreLifecycleManager) → Equatable State
→ Screen (BlocProvider) → Form (BlocBuilder) → widgets
[side track: hive_ce only for pre-auth prefs — onboarding, team selection]
```

## Process

### Step 0: Parse arguments and gather context

Extract from user input:
- `SECTION_NAME` — the section being audited
- `FEATURE_PATH` — path to feature code
- `DOC_PATHS` — list of documentation files (.md, .pdf)
- `OUTPUT_PATH` — where to save results (default: `.claude/my_docs/{section_name}_audit.md`)

Read ALL documentation files provided by the user. Read the UI conventions reference (`@.claude/shared/ui_reference.md`). Build a mental model of what the section SHOULD look like according to spec.

### Step 1: Identify all related files

Use Explore agents (up to 3 in parallel) to find ALL files related to this section across every layer:

**Agent 1 — Data layer:**
- DTOs in `data/lib/dto/<feature>/` (+ shared converters `data/lib/dto/converters/timestamp_converter.dart`, `firestore_sanitizer.dart`)
- Mapper in `data/lib/mappers/`
- Repository impl in `data/lib/repositories/`
- Firestore infra usage: `data/lib/services/firestore_retry.dart`, `firestore_lifecycle_manager.dart`, `firestore_network_controller.dart`
- Hive side (only if the section touches pre-auth prefs): entity in `data/lib/entities/`, adapter spec in `data/lib/providers/hive/hive_adapters.dart`, provider in `data/lib/providers/hive/`

**Agent 2 — Backend + infrastructure:**
- Cloud Functions that write/maintain the section's collections: exports in `functions/src/index.ts` (`onRequest`, `onSchedule`, `onDocumentCreated/Updated` triggers)
- Security rules for the collections in `firestore.rules`
- Composite indexes in `firestore.indexes.json`
- DI registration in `data/lib/di/data_di.dart` (`_initRepositories()`)
- Per-user lifecycle wiring in `features/lib/services/auth_bootstrap.dart` (if the section needs start/stop on login/logout)

**Agent 3 — Domain + UI + siblings for horizontal analysis:**
- Domain model in `domain/lib/models/<feature>/`, enums in `domain/lib/models/enums/`
- Repository interface in `domain/lib/repositories/`
- Domain service in `domain/lib/service/`
- Cubit and State files, screens, forms, widgets in the feature path
- Route wiring: `navigation/lib/src/app_router/router_constants.dart` + `navigation/lib/src/app_router/app_router.dart`
- **Sibling discovery (for horizontal analysis):** Find 2-3 sibling sections of the same type for comparison. Sibling = same data pattern: live-stream sections (`snapshots()` watch — Predictions, Leaderboard, Leagues, Statistics, MatchDetail) vs one-shot fetch sections (`get()` or http→Cloud Function — TeamDetail). MatchDetail is a hybrid: a `watchMatch` snapshots stream plus an http `fetchMatchDetails` trigger whose output arrives via the stream. Collect paths to sibling RepositoryImpl, Mapper, Service, and Cubit files. These will be used in Steps 6-8.

### Step 2: Audit backend data path (Cloud Functions + Firestore)

Read and verify each artifact. Check:

#### 2.1 Collections and ownership
- List ALL Firestore collections the section reads/writes (known set: `matches`, `seasons`, `userSeasonStats`, `userLeagueSeasonStats`, `teams`, `users`, `predictions`, `globalLeaderboards/{competitionId}/entries`, `competitions`, `achievements`, `userAchievements`, `userAchievementStats`, `userCounters`, `leagues`)
- For each collection: who writes it — Cloud Functions only, the client, or both? Document the contract
- Verify the relevant functions exist in `functions/src/index.ts` and their trigger paths match the collections the app reads (e.g. `onPredictionCreated`, `onMatchFinished`, `updateTournamentScores`)

#### 2.2 Security rules conformance
- Every client read/write the RepositoryImpl performs MUST be permitted by the matching `match /...` block in `firestore.rules`
- **CRITICAL CHECK:** a client write to a collection whose rules only allow server-side writes = guaranteed `permission-denied` at runtime
- Per-user data: rules typically key on `request.auth.uid` — verify the repo writes documents under the correct owner id

#### 2.3 Composite indexes
- For every Firestore query combining `.where()` + `.orderBy()` (or multiple `.where()` on different fields), verify a matching composite index exists in `firestore.indexes.json`
- Missing index = runtime `failed-precondition` — flag as CRITICAL

#### 2.4 HTTP Cloud Function calls
- Repos call functions via `package:http` against `https://europe-west1-rvach-app.cloudfunctions.net/<fn>` (see `data/lib/repositories/match_repository_impl.dart`)
- Verify: the function name exists in `functions/src/index.ts`; query params match what the function parses; non-200 status codes are handled (not just `jsonDecode` on whatever came back); response shape matches the DTO

### Step 3: Audit data layer (DTO → Mapper → RepositoryImpl)

#### 3.1 DTO (freezed + json_serializable)
- `fromFirestore(DocumentSnapshot)` factory exists and injects `'id': doc.id` before `fromJson`
- **CRITICAL CHECK:** raw map is wrapped in `sanitizeFirestoreNumbers(...)` (real bug: server-side NaN/Infinity crashed login until sanitized)
- Every `DateTime` field annotated with `@TimestampConverter()`
- Non-nullable fields with server-optional values use `@Default(...)` — a missing Firestore field on a `required` non-nullable field throws at parse time

#### 3.2 Mapper field chain (DTO ↔ Model)
- List ALL fields in the DTO
- Verify `toModel()` maps EVERY DTO field to Model
- Verify `toDto()` maps EVERY Model field back to DTO
- Verify `toFirestore()` follows the convention `toDto(model).toJson()..remove('id')` (doc id lives in the path, not the payload)
- **CRITICAL CHECK:** `toModel` and `toDto` MUST cover the SAME set of fields. A field missing from `toDto` is silently nulled on the next `set()` — data loss
- Some repos map raw maps inline without a DTO (e.g. `global_leaderboard_repository_impl.dart`) — verify field names against the Cloud Function that writes the documents

#### 3.3 RepositoryImpl
- Implements the domain interface from `domain/lib/repositories/` (no extra public surface)
- Document id conventions are deterministic where the spec needs idempotent upserts (e.g. predictions: `'${userId}_$matchId'`)
- Partial updates use `SetOptions(merge: true)`; full overwrites are intentional
- `snapshots()` streams `.map()` docs through `DTO.fromFirestore` + `Mapper.toModel` — a single malformed doc must not kill the whole stream (check for per-doc try/catch or sanitization)
- Queries are bounded: explicit `.limit(n)` (project norm: leaderboard top 100, upcoming 20, recent 10). Unbounded collection reads = MEDIUM
- Flaky one-shot reads wrapped in `retryOnTransientFirestoreError()` where user-blocking (pattern: `user_repository_impl.dart`)
- Errors surfaced as `AppException` with a human message (pattern: `auth_repository_impl.dart` `_mapFirebaseAuthException` + `AuthErrorCode` enum)

#### 3.4 Hive cache (only if applicable)
- hive_ce is ONLY for pre-auth prefs (onboarding done, favorite team). If the section caches live match/prediction data in Hive — flag it: that contradicts the live-Firestore architecture
- Entity in `data/lib/entities/` + `AdapterSpec` in `hive_adapters.dart` + regenerated `hive_adapters.g.dart`; thin provider in `data/lib/providers/hive/`
- Hive↔Firestore reconciliation (e.g. favorite team) happens in `AuthBootstrap.onPostLogin` — verify both directions

### Step 4: Audit domain layer + DI

#### 4.1 Domain Model
- freezed `abstract class XModel with _$XModel` in `domain/lib/models/<feature>/`, exported via `models/models.dart` barrel
- Business logic lives ON the model, not in the cubit (reference: `PredictionModel.calculatePoints` — 3/2/1/0 scoring + playoff bonus)
- Enums in `domain/lib/models/enums/` (`MatchStatus`, `MatchStage`, `LeagueStatus`, ...) — verify enum parsing has a fallback for unknown server values

#### 4.2 Repository interface
- Plain `abstract class XRepository` in `domain/lib/repositories/`, exported via `repositories.dart` barrel
- `Future<...> get...` for one-shot, `Stream<...> watch...` for live data — naming matches behavior

#### 4.3 Domain Service
- Singleton facade: `static XService get instance` over the repository, exported via `services.dart` barrel
- Cross-cubit shared state via `ValueNotifier` caches fanned out from watch streams (reference: `PredictionService.userPredictions`)
- If the service adds NOTHING over the repository — record it for Step 7.1 (proxy detection)

#### 4.4 DI registration
- Interface→impl lazy singleton in `data/lib/di/data_di.dart` `_initRepositories()`: `appLocator.registerLazySingleton<XRepository>(XRepositoryImpl.new);`
- Service registered alongside: `appLocator.registerLazySingleton<XService>(() => XService.instance);`
- Missing registration = runtime crash on first `appLocator<X>()` — CRITICAL
- Per-user services that must start/stop with the session (pattern: `AchievementNotificationService`) are registered/unregistered in `AuthBootstrap.onPostLogin`/`onLogout`, NOT in `preLoginScope()`

### Step 5: Audit Cubit / State / UI

#### 5.1 Specification conformance
- Screen/form contains ALL fields, buttons, and actions from technical documentation
- Input validations match spec (lengths, score ranges, allowed characters)
- Texts come from `LocaleKeys` and exist in BOTH `core/resources/translations/ru-RU.json` AND `en-US.json` (ru-RU is the fallback) — hardcoded strings = MEDIUM
- Visual conventions match `@.claude/shared/ui_reference.md` (tokens via `context.currentTokens`, `AppDimens`, `AppScaffold`, `MascotMessage`, skeletons)

#### 5.2 Cubit
- `init()` subscribes to service/repository streams; flags set via `_safeEmit` (`if (isClosed) return;` guard MUST exist — late stream events after close otherwise throw)
- **Firestore lifecycle:** if the cubit holds `snapshots()` subscriptions, it MUST call `FirestoreLifecycleManager.instance.register(onPause: ..., onResume: ...)` and invoke the returned disposer in `close()`; `onPause` cancels and nulls every subscription, `onResume` re-subscribes
- ALL `StreamSubscription`s cancelled in `close()`
- Double-catch convention: `on AppException catch (e)` → `errorMessage: () => e.message`; generic `catch` → `e.toString()`; stream `onError` callbacks also set `errorMessage`
- Navigation via DI-injected router, NOT BuildContext: `appLocator<AppRouter>().router.go(RouterConstants.xRoute)` / `.push(...)` / `.pop()`
- Dialogs/sheets via `AppRouter` extensions: `appLocator<AppRouter>().showFullScreenDialog<T>(widget: ...)`, `.showBottomSheet<T>(contentWidget: ...)`
- Action feedback via `ToastService().init(context).showToast(message: ...)` (`core/lib/service/toast_service.dart`)
- No manual reload after create/update if a watch stream already delivers the change (see Step 8.4)

#### 5.3 State
- Single Equatable class in a `part of '..._cubit.dart'` file (no sealed states, no status enum — project convention)
- All necessary fields for UI; non-nullable with defaults where possible
- `copyWith()` covers all fields; nullable fields resettable via `ValueGetter<String?>?` (reference: `predictions_state.dart` `errorMessage`)
- `props` contains ALL fields — a field missing from `props` silently suppresses rebuilds
- Initial state: `isLoading` default, empty const collections

#### 5.4 Form / Widgets
- Screen = thin `BlocProvider<XCubit>(create: (_) => XCubit()..init(), child: const XForm())`; Form owns layout with `BlocBuilder`
- Loading = skeletons (`ShimmerBox`, `MatchListSkeleton`, ...) kept up until data actually lands — no empty-state flash between loading and first snapshot
- Empty/error state = `MascotMessage` (sad mascot + retry `AppButton` calling `cubit.init`)
- Correct `BlocBuilder`/`BlocListener` usage; one public widget per file

#### 5.5 Routing integration
- Route constant in `RouterConstants` + `GoRoute` in `navigation/lib/src/app_router/app_router.dart` (top-level, or nested under the correct `StatefulShellBranch` of the 5-tab shell)
- Path/query params read via `state.pathParameters` / `state.uri.queryParameters` with null-safe fallbacks
- Pop with result if the screen returns data to a parent; parent reacts to the result

### Step 6: Horizontal — Duplicate Logic Detection

**Goal:** Identify copy-paste boilerplate within the section's files by comparing against 2-3 sibling sections discovered in Step 1.

**Sibling selection rule:** Pick sections with the same data pattern. Live-stream sections (Predictions, Leaderboard, Leagues, Statistics, MatchDetail — the latter a hybrid whose http trigger result arrives via its stream) compare against each other; one-shot fetch sections (TeamDetail) likewise. State which siblings were used for comparison.

#### 6.1 RepositoryImpl boilerplate comparison
Read the section's RepositoryImpl and ONE sibling's. Check:
- Is the `snapshots().map(docs → fromFirestore → toModel)` pipeline structurally identical with only collection/type names changed?
- Is the `get()` → `exists`/`data() == null` check → DTO → Model sequence copy-pasted?
- Is the `_functionsBaseUrl` + `http.get` + status check + `jsonDecode` block duplicated across http-calling repos (`match`, `team`, `league`, `auth`, `achievements`)?

#### 6.2 Mapper structure comparison
Check if `toModel`, `toDto`, `toFirestore` are trivial field-by-field copies with no transformation beyond the converters. Identical trivial mappers across many sections are acceptable project convention — only flag when a freezed `fromJson` could replace the mapper entirely or when transformation logic is duplicated (e.g. the same name-normalization in two mappers; reference: `competition_name_normalizer.dart` exists precisely to share this).

#### 6.3 Domain Service comparison
- Is the singleton skeleton (`_instance`, `get instance`, `_internal()`) + `ValueNotifier` fan-out copy-pasted from a sibling with only types changed?
- Is stream-to-cache plumbing identical?

#### 6.4 Cubit comparison
- Are `_safeEmit`, the `FirestoreLifecycleManager.register` block, and `_pauseStreams`/`_resumeStreams` copy-pasted identically across sibling cubits? (Candidate for a shared mixin)
- Is the double-catch error block identical everywhere?

**Output format:**

| File | Duplicated Methods | Boilerplate % | Recommendation |
|------|-------------------|---------------|----------------|
| prediction_repository_impl.dart | watchUserPredictions, getUserPredictions | ~50% | Extract shared `snapshots→models` helper |

### Step 7: Horizontal — Dead/Useless Logic Detection

**Goal:** Find methods, classes, or fields that serve no purpose in the audited section.

#### 7.1 Service proxy detection
Read the domain Service for this section. For EACH method:
- Does it do ANYTHING beyond `return _repository.methodName(sameArgs)`?
- Does it add: error handling? `ValueNotifier` caching? transformation? notification? business rules?
- If ALL methods are pure proxies → flag the entire service as "zero-value-add proxy" (MEDIUM severity)
- If SOME methods add value but others are proxies → flag individual proxy methods (LOW severity)
- A method that adds ONLY `try/catch` that rethrows without transformation is still a proxy

#### 7.2 Unused repository method detection
For each method in the domain Repository interface:
- Grep for calls across ALL files found in Step 1 + the feature directory + domain services
- If a method has 0 callers outside its own declaration → flag as "potentially dead" (LOW)
- Note: methods called only from tests should be noted as "test-only, not dead" (currently no `test/` dirs exist — so any such method is fully dead)

#### 7.3 Unused cubit method detection
For each public method in the Cubit:
- Search for references in the Form/Screen/Widget files
- Empty method bodies (`async {}` or just `{}`) → flag as "stub" (LOW)
- Methods defined but never referenced from UI → flag as "unreachable" (LOW)

#### 7.4 Unused mapper/DTO surface detection
- `toDto`/`toFirestore` on read-only sections (client never writes the collection) → flag as "dead write path" (VERY LOW)
- `fromJson` factories never invoked outside `fromFirestore` are fine (json_serializable plumbing) — do NOT flag

#### 7.5 Carried-but-unused fields
For each field in the domain Model:
- Is it ever READ in the Cubit, Form, or Widgets? (not just passed through)
- Fields mapped through ALL layers (Firestore → DTO → Model) but never displayed or used in any business logic → flag as "carried but unused" (VERY LOW)
- These might be consumed server-side by Cloud Functions triggers or planned for future UI — note this possibility

### Step 8: Horizontal — Suboptimal Logic Detection

**Goal:** Find patterns that work correctly but are inefficient, fragile, or unnecessarily complex. Think like a senior engineer reviewing a PR.

#### 8.1 In-memory filtering vs Firestore query
In the Cubit, Service, and Repository:
- Find any pattern: fetch a whole collection/list then `.where()` / `.firstWhere()` / `.any()` filter in Dart
- Check if the Repository already exposes (or Firestore trivially supports) a `.where()` query for the same purpose
- If yes → flag: "Fetches all N docs then filters in-memory; a `.where()` query exists/is trivial — wasted reads = wasted money" (MEDIUM)
- Caveat: Firestore can't do everything (no OR across fields pre-`Filter.or`, no inequality on two fields) — if the filter genuinely can't be a query, dismiss in section C

#### 8.2 N+1 document reads and sequential awaits
- Find loops doing `await collection.doc(id).get()` per item → suggest batched `whereIn` (chunks of 30) or restructuring (MEDIUM if user-facing latency)
- Find sequences of 2+ `await` calls with NO data dependency → flag: "Could use `Future.wait([...])`" (LOW). Common spot: loading multiple independent sources sequentially in `init()`

#### 8.3 Redundant error handling chains
Trace the error path through the section's layers:
- Does the Repository catch and rethrow (beyond `retryOnTransientFirestoreError` / `AppException` mapping)?
- Does the Service catch and rethrow? Does the Cubit catch?
- If error is caught at 3+ levels without any transformation, added context, or different handling → flag: "Triple error handling without added context" (LOW)
- If a Service swallows errors (catches but returns empty/default instead of rethrowing) → flag: "Service swallows errors — caller has no way to detect failure" (MEDIUM)
- Stream `onError` that only `debugPrint`s without setting `errorMessage` → UI shows stale data silently (MEDIUM)

#### 8.4 Manual reload alongside live streams
The project norm is live `snapshots()` streams — there is no pull-to-refresh anywhere:
- After `create()`/`update()`/`delete()` — does the Cubit call `loadAll()`/re-fetch when a `watch...` stream on the same data is already active? → flag: "Redundant manual reload — the snapshot stream already delivers this change" (LOW)
- Conversely: one-shot `get()` for data the user watches change in real time (live scores) → flag as a UX/architecture question for Step 9

#### 8.5 Passthrough DTO
Check if the DTO is structurally identical to the Model:
- In RVACH the DTO earns its keep via `fromFirestore` + `sanitizeFirestoreNumbers` + `@TimestampConverter` — that is NOT passthrough even if fields match
- Flag only DTOs with no Firestore factory and no converters that mirror the Model 1:1 → "Passthrough DTO — consider if this indirection is justified" (VERY LOW)

#### 8.6 Verbose production logging
In RepositoryImpl, Service, and Cubit:
- Check for per-document `debugPrint`/`AppLogger` calls inside `snapshots().map()` or loops (fires on every snapshot for every doc)
- Flag: "Per-doc logging in a live stream — log spam and CPU waste on busy collections" (LOW)
- Single entry/exit or error logs are fine — only flag per-item logging

#### 8.7 Unnecessary rebuilds in UI
In Form/Widgets:
- `BlocBuilder` without `buildWhen` when only a subset of state fields matter for this widget
- Entire form rebuilds when only one field changes
- Flag: "BlocBuilder without buildWhen — rebuilds on every state change, consider narrowing" (VERY LOW)
- Only flag if the state has 5+ fields and the widget uses 1-2

#### 8.8 Firestore-specific resource leaks
- Subscriptions created in `init()` but not cancelled in `close()` → leak + crash risk (CRITICAL)
- `snapshots()` cubit not registered with `FirestoreLifecycleManager` → background-terminate crash path (CRITICAL)
- Unbounded queries (no `.limit()`) on growing collections (`predictions`, `matches`) → cost and memory growth over seasons (MEDIUM)

### Step 9: Horizontal — Flow Questions

**Goal:** When something is unclear, suspicious, or ambiguous — formulate a SPECIFIC question for the user rather than making assumptions. This step collects all ambiguities found during Steps 6-8 into a structured table.

**Question categories:**

1. **Architecture intent** — Why does this code exist in this form?
   - "Service X has N methods, all are pure proxies to Repository. Is this an extension point for future business logic, or should it be bypassed?"
   - "This repo exposes both `watchX()` and `getX()` for the same data and the cubit uses both. Which is the intended pattern?"

2. **Performance intent** — Is the inefficiency deliberate?
   - "Service fetches ALL items then filters in-memory. Is this for `ValueNotifier` cache reuse across multiple cubits, or should it use a `.where()` query?"
   - "This screen does a one-shot `get()` for live-score data while siblings use `snapshots()`. Is the static read intentional (cost control), or an oversight?"

3. **Dead code safety** — Is it safe to remove?
   - "Methods X, Y, Z are defined in the Repository interface but have 0 callers. Are they planned for an upcoming feature, or safe to remove?"
   - "`toFirestore()` exists for a collection only Cloud Functions write. Was client-side write planned?"

4. **Pattern deviation** — Why does this section differ from siblings?
   - "This Cubit skips `FirestoreLifecycleManager` registration that all sibling stream-cubits have. Is its subscription short-lived by design, or is this a missed crash path?"
   - "This section's Mapper has a special null-coalescing fallback that others don't. Is there a data quality issue specific to this collection?"

5. **Data flow clarity** — When the flow is hard to trace
   - "The Cubit calls Service which calls Repository — but the Service adds nothing. Is the intent to keep the Service as a stable interface even if Repository changes?"
   - "This field is mapped through all layers but never used in UI. Is it consumed by a Cloud Functions trigger (e.g. scoring), or was the UI not implemented yet?"

**Format:** Present questions BEFORE the issues table so the team can answer them, potentially changing issue severity.

### Step 10: Compile results

Generate the audit report with the following structure:

```markdown
# Audit: {SECTION_NAME}

**Date:** {current date}
**Feature:** {FEATURE_PATH}
**Documentation:** {DOC_PATHS}
**Sibling sections used for comparison:** {list of siblings}

## A. What works correctly
- (brief bullet list of verified items from vertical AND horizontal analysis)

## B. Issues found

### CRITICAL
For each issue:
- **File:** path:line_numbers
- **Issue:** description
- **Fix:** what needs to change
- **Why:** consequences without fix

### MEDIUM
(same format)

### LOW
(same format)

### VERY LOW
(same format)

### RECOMMENDATION
For each item (technical debt, not bugs):
- **File:** path:line_numbers
- **Pattern:** what was detected (duplicate, passthrough, verbose logging, etc.)
- **Suggestion:** what could be improved
- **Impact:** maintenance cost / performance / readability

## C. What is NOT an issue (false alarm dismissals)
- (items that look suspicious but are actually correct, with explanation)

## D. Fix summary table

| # | Severity | File | Issue | Fix |
|---|----------|------|-------|-----|
| 1 | CRITICAL | path:line | ... | ... |

## E. Implementation status
- Backend data path (Functions/rules/indexes): status
- Data layer (DTO/Mapper/RepositoryImpl/DI): status
- Domain layer (Model/Service): status
- UI (Cubit/State/Form/Route): status
- Spec conformance: status

## F. Horizontal Analysis

### F.1 Duplicate Logic
| File | Duplicated Methods | Boilerplate % | Recommendation |
|------|-------------------|---------------|----------------|

### F.2 Dead/Useless Logic
| File | Item | Type | Evidence |
|------|------|------|----------|

### F.3 Suboptimal Logic
| File:Line | Pattern | Impact | Suggestion |
|-----------|---------|--------|------------|

## G. Questions for the Team

| # | Category | Question | Context |
|---|----------|----------|---------|
| Q1 | Architecture | ... | file:line |
```

Severity criteria:
- **CRITICAL** — data loss in mapper, `permission-denied` write path, missing composite index, missing DI registration, subscription leak / missing `FirestoreLifecycleManager` registration, crash
- **MEDIUM** — incorrect UI behavior, missed validation, incomplete mapping, error swallowing, silent stream `onError`, in-memory filtering when a query exists, unbounded queries, N+1 reads, hardcoded strings instead of LocaleKeys
- **LOW** — spec mismatch without data impact, UX improvements, sequential awaits, triple error handling, redundant manual reload, verbose logging
- **VERY LOW** — code style, passthrough DTO, carried-but-unused fields, unnecessary rebuilds
- **RECOMMENDATION** — not a bug, works correctly, but accumulates technical debt (boilerplate duplication, proxy services, redundant layers)

### Step 11: Save results

Write the audit report to the output path (default: `.claude/my_docs/{section_name}_audit.md`).

If the user provided a local documentation path, also update that document with:
- Updated implementation status
- Found and fixed bugs
- Spec divergences
